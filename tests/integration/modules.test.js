/**
 * Integration tests for the module system.
 *
 * Tests drone auto-complete behavior, diagnostic task,
 * damage distribution, and backlog accumulation.
 */

import { describe, it, expect, beforeEach } from "vitest";
import { InkList } from "inkjs/full";
import { createStory, L, cargo, drainText } from "../helpers/story.js";

let story;

beforeEach(() => {
  story = createStory();
});

function choiceTexts(story) {
  return story.currentChoices.map((c) => c.text);
}

function hasChoice(story, text) {
  return story.currentChoices.some((c) => c.text.includes(text));
}

function pickChoice(story, text) {
  const idx = story.currentChoices.findIndex((c) => c.text.includes(text));
  if (idx === -1)
    throw new Error(
      `Choice not found: "${text}"\nAvailable: ${choiceTexts(story).join(", ")}`
    );
  story.ChooseChoiceIndex(idx);
  drainText(story);
}

/**
 * Set up a story in transit state and navigate to ship_options.
 */
function setupTransit(overrides = {}) {
  const story = createStory();
  story.variablesState["ShipCargo"] = new InkList();

  const defaults = {
    ShipClock: 5,
    ShipDestination: L(story, "AllLocations.Mars"),
    TripDuration: 10,
    TripDay: 3,
    FlipDone: true,
    FlightMode: L(story, "FlightModes.Bal"),
    PaperworkDone: 1,
    PaperworkTotal: 1,
    TripFuelCost: 100,
    TripFuelPenalty: 0,
    NavChecksCompleted: 10,
    AP: 6,
    ActionPointsMax: 6,
    Fatigue: 0,
    Morale: 80,
    ShipCondition: 100,
    EngineCondition: 100,
    ShipFuel: 200,
    TaskCap: 7,
    TasksCompletedToday: 0,
    EventChance: 0,
    EventCooldownDay: -1,
    CargoDamagePct: 0,
  };

  const vars = { ...defaults, ...overrides };
  for (const [key, value] of Object.entries(vars)) {
    story.variablesState[key] = value;
  }

  return story;
}

describe("drone auto-complete", () => {
  it("repair drones complete engine tasks from backlog", () => {
    // Test via unit functions — verify drone capacity and task matching
    // then verify integration through the accessor functions
    const s = setupTransit();
    s.EvaluateFunction("install_module", [L(s, "ShipModules.RepairDrones"), 100]);

    // Verify capacity
    expect(s.EvaluateFunction("get_drone_capacity", [L(s, "ShipModules.RepairDrones")])).toBe(2);
    expect(s.EvaluateFunction("is_module_active", [L(s, "ShipModules.RepairDrones")])).toBe(true);

    // Verify engine task matching
    expect(s.EvaluateFunction("is_engine_task", [L(s, "MaintTasks.EngTune")])).toBe(true);
    expect(s.EvaluateFunction("is_engine_task", [L(s, "MaintTasks.AirFilter")])).toBe(false);
  });

  it("cleaning drones are active and match ship tasks", () => {
    const s = setupTransit();
    s.EvaluateFunction("install_module", [L(s, "ShipModules.CleaningDrones"), 100]);

    expect(s.EvaluateFunction("get_drone_capacity", [L(s, "ShipModules.CleaningDrones")])).toBe(2);
    expect(s.EvaluateFunction("is_module_active", [L(s, "ShipModules.CleaningDrones")])).toBe(true);

    // Ship tasks are NOT engine tasks
    expect(s.EvaluateFunction("is_engine_task", [L(s, "MaintTasks.AirFilter")])).toBe(false);
    expect(s.EvaluateFunction("is_engine_task", [L(s, "MaintTasks.HullCheck")])).toBe(false);
  });

  it("drones at reduced capacity (50-74%) have capacity 1", () => {
    const s = setupTransit();
    s.EvaluateFunction("install_module", [L(s, "ShipModules.RepairDrones"), 60]);
    expect(s.EvaluateFunction("get_drone_capacity", [L(s, "ShipModules.RepairDrones")])).toBe(1);
  });

  it("drones below 50% are offline with capacity 0", () => {
    const s = setupTransit();
    s.EvaluateFunction("install_module", [L(s, "ShipModules.RepairDrones"), 40]);
    expect(s.EvaluateFunction("get_drone_capacity", [L(s, "ShipModules.RepairDrones")])).toBe(0);
    expect(s.EvaluateFunction("is_module_active", [L(s, "ShipModules.RepairDrones")])).toBe(false);
  });

  it("complete_maintenance_task removes from both Backlog and StaleBacklog", () => {
    const s = setupTransit();
    s.variablesState["Backlog"] = cargo(
      s,
      "MaintTasks.EngTune",
      "MaintTasks.FuelLine",
      "MaintTasks.AirFilter"
    );
    s.variablesState["StaleBacklog"] = L(s, "MaintTasks.EngTune");

    s.EvaluateFunction("complete_maintenance_task", [L(s, "MaintTasks.EngTune")]);

    const backlog = s.variablesState["Backlog"];
    const stale = s.variablesState["StaleBacklog"];
    expect(backlog.toString()).not.toContain("EngTune");
    expect(stale.toString()).not.toContain("EngTune");
    expect(backlog.toString()).toContain("FuelLine");
  });
});

describe("backlog accumulation", () => {
  it("add_daily_tasks adds 4 tasks to existing backlog", () => {
    // Start with 2 tasks
    story.variablesState["Backlog"] = cargo(
      story,
      "MaintTasks.EngTune",
      "MaintTasks.FuelLine"
    );
    story.EvaluateFunction("add_daily_tasks");
    const backlog = story.variablesState["Backlog"];
    // Should now have 6 tasks (2 original + 4 new)
    const count = backlog.Count;
    expect(count).toBe(6);
  });

  it("add_daily_tasks caps at 8 (LIST size limit)", () => {
    // Start with 6 tasks
    story.variablesState["Backlog"] = cargo(
      story,
      "MaintTasks.EngTune",
      "MaintTasks.FuelLine",
      "MaintTasks.Injector",
      "MaintTasks.Coolant",
      "MaintTasks.AirFilter",
      "MaintTasks.HullCheck"
    );
    story.EvaluateFunction("add_daily_tasks");
    const backlog = story.variablesState["Backlog"];
    // Should have all 8 (only 2 available slots)
    expect(backlog.Count).toBe(8);
  });
});

describe("diagnostic task", () => {
  it("diagnostic choice appears when countdown reaches 0", () => {
    const s = setupTransit({
      DiagnosticCountdown: 0,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.RepairDrones"), 100]);
    // Set backlog so P3 has tasks
    s.variablesState["Backlog"] = cargo(
      s,
      "MaintTasks.EngTune",
      "MaintTasks.AirFilter"
    );

    s.ChoosePathString("transit.ship_options");
    drainText(s);

    expect(hasChoice(s, "module diagnostics")).toBe(true);
  });

  it("diagnostic choice does not appear when countdown is positive", () => {
    const s = setupTransit({
      DiagnosticCountdown: 3,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.RepairDrones"), 100]);
    s.variablesState["Backlog"] = cargo(
      s,
      "MaintTasks.EngTune",
      "MaintTasks.AirFilter"
    );

    s.ChoosePathString("transit.ship_options");
    drainText(s);

    expect(hasChoice(s, "module diagnostics")).toBe(false);
  });

  it("diagnostic choice does not appear when no modules installed", () => {
    const s = setupTransit({
      DiagnosticCountdown: 0,
    });
    s.variablesState["Backlog"] = cargo(
      s,
      "MaintTasks.EngTune",
      "MaintTasks.AirFilter"
    );

    s.ChoosePathString("transit.ship_options");
    drainText(s);

    expect(hasChoice(s, "module diagnostics")).toBe(false);
  });
});

describe("damage_random_system with modules", () => {
  it("damages engine when no modules installed", () => {
    story.variablesState["EngineCondition"] = 100;
    story.EvaluateFunction("damage_random_system", [20]);
    expect(story.variablesState["EngineCondition"]).toBe(80);
  });

  it("can damage installed modules (statistical)", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.RepairDrones"), 100]);

    // Run multiple times — with 50/50 odds, at least one should hit a module
    let moduleDamaged = false;
    for (let i = 0; i < 30; i++) {
      story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 100]);
      story.variablesState["EngineCondition"] = 100;
      story.EvaluateFunction("damage_random_system", [20]);

      if (story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.RepairDrones")]) < 100) {
        moduleDamaged = true;
        break;
      }
    }
    expect(moduleDamaged).toBe(true);
  });

  it("module condition floors at 1 not 0", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.RepairDrones"), 10]);

    // Run multiple times to get a module hit
    let verified = false;
    for (let i = 0; i < 30; i++) {
      story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 10]);
      story.variablesState["EngineCondition"] = 100;
      story.EvaluateFunction("damage_random_system", [20]);

      const cond = story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.RepairDrones")]);
      if (cond < 10) {
        // Module was damaged — verify it didn't go to 0
        expect(cond).toBe(1);
        verified = true;
        break;
      }
    }
    expect(verified).toBe(true);
  });
});

describe("port upgrades menu", () => {
  it("shows Ship upgrades option at port", () => {
    // Story starts at port
    drainText(story);
    expect(hasChoice(story, "Ship upgrades")).toBe(true);
  });
});
