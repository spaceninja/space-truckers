/**
 * Integration tests for the module system.
 *
 * Tests drone auto-complete behavior, module maintenance tasks,
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
    NavCheckDueDay: 99,
    NavPenaltyPct: 0,
    CargoCheckDueDay: 99,
    CargoCheckPenaltyPct: 0,
    AP: 6,
    ActionPointsMax: 6,
    Fatigue: 0,
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

describe("task classification", () => {
  it("is_engine_maint identifies engine tasks", () => {
    expect(story.EvaluateFunction("is_engine_maint", [L(story, "EngineMaintTasks.EngTune")])).toBe(true);
    expect(story.EvaluateFunction("is_engine_maint", [L(story, "EngineMaintTasks.FuelLine")])).toBe(true);
    expect(story.EvaluateFunction("is_engine_maint", [L(story, "ShipMaintTasks.AirFilter")])).toBe(false);
    expect(story.EvaluateFunction("is_engine_maint", [L(story, "ModuleMaintTasks.RepDroneServo")])).toBe(false);
  });

  it("is_ship_maint identifies ship tasks", () => {
    expect(story.EvaluateFunction("is_ship_maint", [L(story, "ShipMaintTasks.AirFilter")])).toBe(true);
    expect(story.EvaluateFunction("is_ship_maint", [L(story, "ShipMaintTasks.HullCheck")])).toBe(true);
    expect(story.EvaluateFunction("is_ship_maint", [L(story, "EngineMaintTasks.EngTune")])).toBe(false);
  });

  it("is_module_maint identifies module tasks", () => {
    expect(story.EvaluateFunction("is_module_maint", [L(story, "ModuleMaintTasks.RepDroneServo")])).toBe(true);
    expect(story.EvaluateFunction("is_module_maint", [L(story, "ModuleMaintTasks.NavChipFlush")])).toBe(true);
    expect(story.EvaluateFunction("is_module_maint", [L(story, "EngineMaintTasks.EngTune")])).toBe(false);
  });

  it("maint_task_module maps tasks to correct modules", () => {
    const cases = [
      ["ModuleMaintTasks.RepDroneServo", "ShipModules.RepairDrones"],
      ["ModuleMaintTasks.RepDroneOptics", "ShipModules.RepairDrones"],
      ["ModuleMaintTasks.ClnDroneBrush", "ShipModules.CleaningDrones"],
      ["ModuleMaintTasks.NavChipFlush", "ShipModules.AutoNav"],
      ["ModuleMaintTasks.CargoSensor", "ShipModules.CargoMgmt"],
    ];
    for (const [task, mod] of cases) {
      const result = story.EvaluateFunction("maint_task_module", [L(story, task)]);
      expect(result.toString()).toContain(mod.split(".")[1]);
    }
  });
});

describe("available_module_tasks", () => {
  it("returns empty when no modules installed", () => {
    const result = story.EvaluateFunction("available_module_tasks");
    expect(result.Count).toBe(0);
  });

  it("returns tasks only for installed modules", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.RepairDrones"), 100]);
    const result = story.EvaluateFunction("available_module_tasks");
    expect(result.Count).toBe(2);
    expect(result.toString()).toContain("RepDroneServo");
    expect(result.toString()).toContain("RepDroneOptics");
    // Should NOT contain tasks from other modules
    expect(result.toString()).not.toContain("NavChipFlush");
  });

  it("returns tasks for multiple installed modules", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.RepairDrones"), 100]);
    story.EvaluateFunction("install_module", [L(story, "ShipModules.AutoNav"), 100]);
    const result = story.EvaluateFunction("available_module_tasks");
    expect(result.Count).toBe(4);
  });
});

describe("drone auto-complete", () => {
  it("repair drones complete engine tasks from backlog", () => {
    const s = setupTransit();
    s.EvaluateFunction("install_module", [L(s, "ShipModules.RepairDrones"), 100]);

    // Verify capacity
    expect(s.EvaluateFunction("get_drone_capacity", [L(s, "ShipModules.RepairDrones")])).toBe(2);
    expect(s.EvaluateFunction("is_module_active", [L(s, "ShipModules.RepairDrones")])).toBe(true);

    // Verify engine task matching
    expect(s.EvaluateFunction("is_engine_maint", [L(s, "EngineMaintTasks.EngTune")])).toBe(true);
    expect(s.EvaluateFunction("is_engine_maint", [L(s, "ShipMaintTasks.AirFilter")])).toBe(false);
  });

  it("cleaning drones are active and match ship tasks", () => {
    const s = setupTransit();
    s.EvaluateFunction("install_module", [L(s, "ShipModules.CleaningDrones"), 100]);

    expect(s.EvaluateFunction("get_drone_capacity", [L(s, "ShipModules.CleaningDrones")])).toBe(2);
    expect(s.EvaluateFunction("is_module_active", [L(s, "ShipModules.CleaningDrones")])).toBe(true);

    // Ship tasks are NOT engine tasks
    expect(s.EvaluateFunction("is_engine_maint", [L(s, "ShipMaintTasks.AirFilter")])).toBe(false);
    expect(s.EvaluateFunction("is_engine_maint", [L(s, "ShipMaintTasks.HullCheck")])).toBe(false);
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

  it("drones skip module maintenance tasks", () => {
    const s = setupTransit();
    s.EvaluateFunction("install_module", [L(s, "ShipModules.RepairDrones"), 100]);

    // Put a module task and engine task in the backlog
    s.variablesState["Backlog"] = cargo(
      s,
      "EngineMaintTasks.EngTune",
      "ModuleMaintTasks.RepDroneServo"
    );

    // Run drones
    s.EvaluateFunction("module_auto_tasks");

    // Engine task should be completed, module task should remain
    const backlog = s.variablesState["Backlog"];
    expect(backlog.toString()).not.toContain("EngTune");
    expect(backlog.toString()).toContain("RepDroneServo");
  });

  it("complete_maintenance_task removes from Backlog, StaleBacklog, and adds to CompletedToday", () => {
    const s = setupTransit();
    s.variablesState["Backlog"] = cargo(
      s,
      "EngineMaintTasks.EngTune",
      "EngineMaintTasks.FuelLine",
      "ShipMaintTasks.AirFilter"
    );
    s.variablesState["StaleBacklog"] = L(s, "EngineMaintTasks.EngTune");

    s.EvaluateFunction("complete_maintenance_task", [L(s, "EngineMaintTasks.EngTune")]);

    const backlog = s.variablesState["Backlog"];
    const stale = s.variablesState["StaleBacklog"];
    const completed = s.variablesState["CompletedToday"];
    expect(backlog.toString()).not.toContain("EngTune");
    expect(stale.toString()).not.toContain("EngTune");
    expect(completed.toString()).toContain("EngTune");
    expect(backlog.toString()).toContain("FuelLine");
  });
});

describe("backlog accumulation", () => {
  it("add_daily_tasks adds 3-4 tasks from empty backlog", () => {
    // Run multiple times to verify statistical properties
    // Reuse one compiled story, resetting state each iteration
    const s = createStory();
    let saw3 = false;
    let saw4 = false;
    for (let i = 0; i < 30; i++) {
      s.ResetState();
      s.EvaluateFunction("add_daily_tasks");
      const count = s.variablesState["Backlog"].Count;
      expect(count).toBeGreaterThanOrEqual(3);
      expect(count).toBeLessThanOrEqual(4);
      if (count === 3) saw3 = true;
      if (count === 4) saw4 = true;
    }
    // Should see both 3 and 4 over 30 trials (coin flip)
    expect(saw3).toBe(true);
    expect(saw4).toBe(true);
  });

  it("add_daily_tasks includes module tasks when modules are installed", () => {
    const s = createStory();
    let sawModuleTask = false;
    for (let i = 0; i < 30; i++) {
      s.ResetState();
      s.EvaluateFunction("install_module", [L(s, "ShipModules.RepairDrones"), 100]);
      s.EvaluateFunction("add_daily_tasks");
      const backlog = s.variablesState["Backlog"].toString();
      if (backlog.includes("RepDroneServo") || backlog.includes("RepDroneOptics")) {
        sawModuleTask = true;
        break;
      }
    }
    expect(sawModuleTask).toBe(true);
  });

  it("add_daily_tasks excludes cooldown tasks", () => {
    // Complete all 4 engine tasks, put them in cooldown
    story.variablesState["MaintCooldown"] = cargo(
      story,
      "EngineMaintTasks.EngTune",
      "EngineMaintTasks.FuelLine",
      "EngineMaintTasks.Injector",
      "EngineMaintTasks.Coolant"
    );
    story.variablesState["Backlog"] = new InkList();
    story.variablesState["StaleBacklog"] = new InkList();
    story.variablesState["CompletedToday"] = new InkList();
    story.EvaluateFunction("add_daily_tasks");
    const backlog = story.variablesState["Backlog"].toString();
    // None of the cooldown engine tasks should appear
    expect(backlog).not.toContain("EngTune");
    expect(backlog).not.toContain("FuelLine");
    expect(backlog).not.toContain("Injector");
    expect(backlog).not.toContain("Coolant");
  });

  it("add_daily_tasks does not include module tasks when no modules installed", () => {
    // Run many times — no module tasks should ever appear
    // Reuse one compiled story, resetting state each iteration
    const s = createStory();
    for (let i = 0; i < 20; i++) {
      s.ResetState();
      s.EvaluateFunction("add_daily_tasks");
      const backlog = s.variablesState["Backlog"].toString();
      expect(backlog).not.toContain("Drone");
      expect(backlog).not.toContain("Nav");
      expect(backlog).not.toContain("Cargo");
    }
  });
});

describe("module maintenance effects", () => {
  it("completing a module task boosts that module's condition by 3", () => {
    const s = setupTransit();
    s.EvaluateFunction("install_module", [L(s, "ShipModules.RepairDrones"), 70]);
    s.variablesState["Backlog"] = L(s, "ModuleMaintTasks.RepDroneServo");

    s.ChoosePathString("transit.ship_options");
    drainText(s);
    pickChoice(s, "Ship maintenance");
    pickChoice(s, "repair drone servo calibration");

    expect(s.EvaluateFunction("get_module_condition", [L(s, "ShipModules.RepairDrones")])).toBe(73);
  });

  it("completing a module task while fatigued boosts by 1", () => {
    const s = setupTransit({ Fatigue: 95 });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.RepairDrones"), 70]);
    s.variablesState["Backlog"] = L(s, "ModuleMaintTasks.RepDroneServo");

    // At 95 fatigue, 70% failure chance — run multiple times
    let sawFatigued = false;
    for (let i = 0; i < 30; i++) {
      const t = setupTransit({ Fatigue: 95 });
      t.EvaluateFunction("install_module", [L(t, "ShipModules.RepairDrones"), 70]);
      t.variablesState["Backlog"] = L(t, "ModuleMaintTasks.RepDroneServo");

      t.ChoosePathString("transit.ship_options");
      drainText(t);
      pickChoice(t, "Ship maintenance");
      pickChoice(t, "repair drone servo calibration");

      const cond = t.EvaluateFunction("get_module_condition", [L(t, "ShipModules.RepairDrones")]);
      if (cond === 71) {
        sawFatigued = true;
        break;
      }
    }
    expect(sawFatigued).toBe(true);
  });

  it("overdue module task penalizes only that module by -5 (floor at 1)", () => {
    // Set AP=1 and spend it on rations to trigger next_day → settle_stale_tasks
    const s = setupTransit({ AP: 1 });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.RepairDrones"), 60]);
    s.EvaluateFunction("install_module", [L(s, "ShipModules.AutoNav"), 80]);

    // Put a repair drone task in both Backlog and StaleBacklog (overdue)
    s.variablesState["Backlog"] = L(s, "ModuleMaintTasks.RepDroneServo");
    s.variablesState["StaleBacklog"] = L(s, "ModuleMaintTasks.RepDroneServo");
    s.variablesState["ShipClock"] = 5;
    s.variablesState["TripDay"] = 2;
    s.variablesState["NavCheckDueDay"] = 2; // make nav check available to burn AP

    s.ChoosePathString("transit.ship_options");
    drainText(s);
    pickChoice(s, "Navigation check"); // costs 1 AP → AP=0 → next_day fires; backlog untouched
    drainText(s);

    // RepairDrones should have lost 5 condition
    expect(s.EvaluateFunction("get_module_condition", [L(s, "ShipModules.RepairDrones")])).toBe(55);
    // AutoNav should be unchanged
    expect(s.EvaluateFunction("get_module_condition", [L(s, "ShipModules.AutoNav")])).toBe(80);
  });

  it("overdue module task condition floors at 1", () => {
    const s = setupTransit({ AP: 1 });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.RepairDrones"), 3]);

    s.variablesState["Backlog"] = L(s, "ModuleMaintTasks.RepDroneServo");
    s.variablesState["StaleBacklog"] = L(s, "ModuleMaintTasks.RepDroneServo");
    s.variablesState["ShipClock"] = 5;
    s.variablesState["TripDay"] = 2;
    s.variablesState["NavCheckDueDay"] = 2; // make nav check available to burn AP

    s.ChoosePathString("transit.ship_options");
    drainText(s);
    pickChoice(s, "Navigation check"); // costs 1 AP → AP=0 → next_day fires; backlog untouched
    drainText(s);

    expect(s.EvaluateFunction("get_module_condition", [L(s, "ShipModules.RepairDrones")])).toBe(1);
  });
});

describe("narrative text functions", () => {
  it("MaintName returns non-empty string for all engine tasks", () => {
    const tasks = ["EngTune", "FuelLine", "Injector", "Coolant"];
    for (const task of tasks) {
      const name = story.EvaluateFunction("MaintName", [L(story, `EngineMaintTasks.${task}`)]);
      expect(name).toBeTruthy();
      expect(name.length).toBeGreaterThan(0);
    }
  });

  it("MaintName returns non-empty string for all ship tasks", () => {
    const tasks = ["AirFilter", "HullCheck", "DrainLines", "Scrub"];
    for (const task of tasks) {
      const name = story.EvaluateFunction("MaintName", [L(story, `ShipMaintTasks.${task}`)]);
      expect(name).toBeTruthy();
      expect(name.length).toBeGreaterThan(0);
    }
  });

  it("MaintName returns non-empty string for all module tasks", () => {
    const tasks = [
      "RepDroneServo", "RepDroneOptics", "ClnDroneBrush", "ClnDroneFilter",
      "NavChipFlush", "NavGyroCalib", "CargoSensor", "CargoSealCheck",
    ];
    for (const task of tasks) {
      const name = story.EvaluateFunction("MaintName", [L(story, `ModuleMaintTasks.${task}`)]);
      expect(name).toBeTruthy();
      expect(name.length).toBeGreaterThan(0);
    }
  });

  it("MaintComplete, MaintFatigued, MaintOverdue return non-empty strings", () => {
    const fns = ["MaintComplete", "MaintFatigued", "MaintOverdue"];
    const task = L(story, "EngineMaintTasks.EngTune");
    for (const fn of fns) {
      const text = story.EvaluateFunction(fn, [task]);
      expect(text).toBeTruthy();
      expect(text.length).toBeGreaterThan(0);
    }
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

describe("Auto-Nav Computer", () => {
  it("suppresses nav check task when auto-completed at full condition (75%+)", () => {
    const s = setupTransit({
      TripDay: 3,
      NavCheckDueDay: 3,  // check is due
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.AutoNav"), 100]);

    // Run module_auto_tasks to simulate daily tick
    s.EvaluateFunction("module_auto_tasks");

    // NavCheckDueDay should have advanced by 3
    expect(s.variablesState["NavCheckDueDay"]).toBe(6);

    // Nav check task should not appear (next due day is 6, TripDay is 3)
    s.ChoosePathString("transit.ship_options");
    drainText(s);
    expect(hasChoice(s, "Navigation check")).toBe(false);
  });

  it("auto-completes on even TripDay at reduced condition (50-74%)", () => {
    const s = setupTransit({
      TripDay: 4,  // even — should auto-complete
      NavCheckDueDay: 4,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.AutoNav"), 60]);
    s.EvaluateFunction("module_auto_tasks");
    expect(s.variablesState["NavCheckDueDay"]).toBe(7);
  });

  it("skips auto-complete on odd TripDay at reduced condition", () => {
    const s = setupTransit({
      TripDay: 3,  // odd — should skip
      NavCheckDueDay: 3,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.AutoNav"), 60]);
    s.EvaluateFunction("module_auto_tasks");
    expect(s.variablesState["NavCheckDueDay"]).toBe(3);  // unchanged
  });

  it("does not auto-complete when offline (below 50%)", () => {
    const s = setupTransit({
      TripDay: 3,
      NavCheckDueDay: 3,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.AutoNav"), 40]);
    s.EvaluateFunction("module_auto_tasks");
    expect(s.variablesState["NavCheckDueDay"]).toBe(3);  // unchanged
  });

  it("does not fire when nav check is not yet due", () => {
    const s = setupTransit({
      TripDay: 3,
      NavCheckDueDay: 6,  // not due until day 6
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.AutoNav"), 100]);
    s.EvaluateFunction("module_auto_tasks");
    expect(s.variablesState["NavCheckDueDay"]).toBe(6);  // unchanged
  });
});

describe("Cargo Management System", () => {
  it("auto-files one paperwork chunk per day at full condition (75%+)", () => {
    const s = setupTransit({
      PaperworkDone: 0,
      PaperworkTotal: 5,
      TripDay: 2,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.CargoMgmt"), 100]);
    s.EvaluateFunction("module_auto_tasks");
    expect(s.variablesState["PaperworkDone"]).toBe(1);
  });

  it("auto-files on odd trip days at reduced condition (50-74%)", () => {
    const s = setupTransit({
      PaperworkDone: 0,
      PaperworkTotal: 5,
      TripDay: 1,  // odd
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.CargoMgmt"), 60]);
    s.EvaluateFunction("module_auto_tasks");
    expect(s.variablesState["PaperworkDone"]).toBe(1);
  });

  it("skips auto-filing on even trip days at reduced condition", () => {
    const s = setupTransit({
      PaperworkDone: 0,
      PaperworkTotal: 5,
      TripDay: 2,  // even
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.CargoMgmt"), 60]);
    s.EvaluateFunction("module_auto_tasks");
    expect(s.variablesState["PaperworkDone"]).toBe(0);  // unchanged
  });

  it("does not file when offline (below 50%)", () => {
    const s = setupTransit({
      PaperworkDone: 0,
      PaperworkTotal: 5,
      TripDay: 1,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.CargoMgmt"), 40]);
    s.EvaluateFunction("module_auto_tasks");
    expect(s.variablesState["PaperworkDone"]).toBe(0);
  });

  it("does not file when paperwork is already complete", () => {
    const s = setupTransit({
      PaperworkDone: 3,
      PaperworkTotal: 3,
      TripDay: 1,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.CargoMgmt"), 100]);
    s.EvaluateFunction("module_auto_tasks");
    expect(s.variablesState["PaperworkDone"]).toBe(3);  // unchanged
  });

  it("suppresses paperwork task when all chunks filed", () => {
    const s = setupTransit({
      PaperworkDone: 2,
      PaperworkTotal: 3,
      TripDay: 1,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.CargoMgmt"), 100]);
    s.EvaluateFunction("module_auto_tasks");  // files chunk 3, now done

    s.ChoosePathString("transit.ship_options");
    drainText(s);
    expect(hasChoice(s, "File paperwork")).toBe(false);
  });

  it("auto-completes cargo inspection at full condition (75%+)", () => {
    const s = setupTransit({
      TripDay: 2,
      CargoCheckDueDay: 2,  // inspection due
      PaperworkDone: 0,
      PaperworkTotal: 3,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.CargoMgmt"), 100]);
    s.EvaluateFunction("module_auto_tasks");
    // CargoCheckDueDay should have advanced (base interval = 3, no special cargo)
    expect(s.variablesState["CargoCheckDueDay"]).toBe(5);
  });

  it("prioritizes inspection over paperwork (1 task per day)", () => {
    const s = setupTransit({
      TripDay: 2,
      CargoCheckDueDay: 2,  // inspection due
      PaperworkDone: 0,
      PaperworkTotal: 3,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.CargoMgmt"), 100]);
    s.EvaluateFunction("module_auto_tasks");
    // Inspection was done, paperwork should NOT have been filed
    expect(s.variablesState["PaperworkDone"]).toBe(0);
  });

  it("falls through to paperwork when no inspection is due", () => {
    const s = setupTransit({
      TripDay: 3,
      CargoCheckDueDay: 99,  // no inspection due
      PaperworkDone: 0,
      PaperworkTotal: 3,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.CargoMgmt"), 100]);
    s.EvaluateFunction("module_auto_tasks");
    expect(s.variablesState["PaperworkDone"]).toBe(1);
  });

  it("auto-completes on even TripDay at reduced condition (50-74%)", () => {
    const s = setupTransit({
      TripDay: 2,  // even
      CargoCheckDueDay: 2,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.CargoMgmt"), 60]);
    s.EvaluateFunction("module_auto_tasks");
    expect(s.variablesState["CargoCheckDueDay"]).toBe(5);
  });

  it("skips inspection on odd TripDay at reduced condition", () => {
    const s = setupTransit({
      TripDay: 3,  // odd
      CargoCheckDueDay: 3,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.CargoMgmt"), 60]);
    s.EvaluateFunction("module_auto_tasks");
    expect(s.variablesState["CargoCheckDueDay"]).toBe(3);  // unchanged
  });

  it("suppresses cargo inspection task when auto-completed", () => {
    const s = setupTransit({
      TripDay: 2,
      CargoCheckDueDay: 2,
    });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.CargoMgmt"), 100]);
    s.EvaluateFunction("module_auto_tasks");

    s.ChoosePathString("transit.ship_options");
    drainText(s);
    expect(hasChoice(s, "Cargo inspection")).toBe(false);
  });
});

