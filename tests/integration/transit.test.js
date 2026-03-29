/**
 * Integration tests for the transit task priority system and
 * fatigue-based task failure.
 *
 * These tests drive ship_options via ChoosePathString and assert on
 * which choices appear based on game state. Each test creates a fresh
 * story instance.
 *
 * Choice matching uses text includes so tests are robust to minor
 * phrasing changes.
 */

import { describe, it, expect, beforeEach } from "vitest";
import { InkList } from "inkjs/full";
import { createStory, L, cargo, drainText } from "../helpers/story.js";

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
 * Pick a choice and return the output text (before draining to next choice point).
 */
function pickChoiceGetText(story, text) {
  const idx = story.currentChoices.findIndex((c) => c.text.includes(text));
  if (idx === -1)
    throw new Error(
      `Choice not found: "${text}"\nAvailable: ${choiceTexts(story).join(", ")}`
    );
  story.ChooseChoiceIndex(idx);
  let output = "";
  while (story.canContinue) {
    output += story.Continue();
  }
  return output;
}

/**
 * Set up a story in transit state and navigate to ship_options.
 * Returns the story at the first choice point.
 */
function setupTransit(overrides = {}) {
  const story = createStory();
  // Initialize required list variables
  story.variablesState["ShipCargo"] = new InkList();
  // Populate maintenance backlog (transit() does this via generate_backlog(),
  // but setupTransit jumps directly to ship_options)
  story.variablesState["Backlog"] = cargo(
    story,
    "MaintTasks.EngTune",
    "MaintTasks.AirFilter",
    "MaintTasks.FuelLine",
    "MaintTasks.HullCheck"
  );

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
    NavChecksCompleted: 0,
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

  story.ChoosePathString("transit.ship_options");
  drainText(story);
  return story;
}

describe("Task priority system", () => {
  describe("P1: Urgent tasks always show", () => {
    it("shows ship flip at midpoint regardless of other tasks", () => {
      const story = setupTransit({
        FlipDone: false,
        TripDay: 5,
        TripDuration: 10,
        // Also activate P2 and P3 tasks
        EngineCondition: 70,
        Fatigue: 75,
        PaperworkDone: 0,
        PaperworkTotal: 3,
        ShipCondition: 70,
      });
      expect(hasChoice(story, "ship flip")).toBe(true);
    });

    it("does not show flip before midpoint", () => {
      const story = setupTransit({
        FlipDone: false,
        TripDay: 2,
        TripDuration: 10,
      });
      expect(hasChoice(story, "ship flip")).toBe(false);
    });

    it("does not show flip when already done", () => {
      const story = setupTransit({
        FlipDone: true,
        TripDay: 5,
        TripDuration: 10,
      });
      expect(hasChoice(story, "ship flip")).toBe(false);
    });
  });

  describe("P2: Important tasks", () => {
    it("shows engine check when condition < 80", () => {
      const story = setupTransit({ EngineCondition: 70 });
      expect(hasChoice(story, "engine")).toBe(true);
    });

    it("does not show engine check when condition >= 80", () => {
      const story = setupTransit({ EngineCondition: 80 });
      expect(hasChoice(story, "engine")).toBe(false);
    });

    it("shows urgent sleep when fatigue >= 70", () => {
      const story = setupTransit({ Fatigue: 75 });
      expect(hasChoice(story, "barely keep your eyes open")).toBe(true);
    });

    it("does not show urgent sleep when fatigue < 70", () => {
      const story = setupTransit({ Fatigue: 60 });
      expect(hasChoice(story, "barely keep your eyes open")).toBe(false);
    });
  });

  describe("P3: Routine tasks", () => {
    it("shows paperwork when chunks remain", () => {
      const story = setupTransit({
        PaperworkDone: 0,
        PaperworkTotal: 2,
      });
      expect(hasChoice(story, "paperwork")).toBe(true);
    });

    it("shows nav check on schedule (day divisible by 3)", () => {
      const story = setupTransit({ TripDay: 6 });
      expect(hasChoice(story, "Navigation check")).toBe(true);
    });

    it("does not show nav check off schedule", () => {
      const story = setupTransit({ TripDay: 4 });
      expect(hasChoice(story, "Navigation check")).toBe(false);
    });

    it("does not show nav check after completing it", () => {
      const story = setupTransit({
        TripDay: 6,
        NavChecksCompleted: 2, // already done checks for day 3 and day 6
      });
      expect(hasChoice(story, "Navigation check")).toBe(false);
    });

    it("shows ship maintenance when backlog has tasks", () => {
      const story = setupTransit();
      // Backlog is always populated at trip start
      expect(hasChoice(story, "Ship maintenance")).toBe(true);
    });
  });

  describe("P4: Recreation", () => {
    it("shows relax option on a quiet day", () => {
      const story = setupTransit();
      expect(hasChoice(story, "Take a break")).toBe(true);
    });

    it("shows sleep rest when fatigue is moderate (30-69)", () => {
      const story = setupTransit({ Fatigue: 50 });
      expect(hasChoice(story, "Get some rest")).toBe(true);
      // Should NOT show the urgent version
      expect(hasChoice(story, "barely keep your eyes open")).toBe(false);
    });

    it("does not show P4 sleep when fatigue < 30", () => {
      const story = setupTransit({ Fatigue: 20 });
      // "Get some rest" should not appear at all (neither P2 nor P4)
      expect(hasChoice(story, "Get some rest")).toBe(false);
    });
  });

  describe("P4 floor guarantee", () => {
    it("shows at least 1 P4 task even when many P1-P3 are active", () => {
      const story = setupTransit({
        FlipDone: false,
        TripDay: 6, // midpoint AND nav check day
        TripDuration: 10,
        EngineCondition: 70,
        Fatigue: 75,
        PaperworkDone: 0,
        PaperworkTotal: 3,
        ShipCondition: 70,
      });
      // With 6 P1-P3 tasks, P4 should still have at least 1 slot
      expect(hasChoice(story, "Take a break")).toBe(true);
    });
  });

  describe("P3 floor guarantee", () => {
    it("shows at least 1 P3 task when P2 tasks would fill the cap", () => {
      // With only 2 P2 tasks currently this won't hit the cap,
      // but verify P3 tasks appear alongside P2
      const story = setupTransit({
        EngineCondition: 70,
        Fatigue: 75,
        PaperworkDone: 0,
        PaperworkTotal: 2,
        ShipCondition: 70,
      });
      // At least one P3 task should appear
      const choices = choiceTexts(story);
      const hasP3 =
        choices.some((c) => c.includes("paperwork")) ||
        choices.some((c) => c.includes("Ship maintenance")) ||
        choices.some((c) => c.includes("Navigation"));
      expect(hasP3).toBe(true);
    });
  });

  describe("P5: Rest", () => {
    // Rest only shows when no P1-P3 tasks are active. Since the backlog
    // is always populated in setupTransit, clear it for Rest tests.
    function setupRestTransit(overrides = {}) {
      const story = setupTransit(overrides);
      story.variablesState["Backlog"] = new InkList();
      // Re-enter ship_options after clearing backlog
      story.ChoosePathString("transit.ship_options");
      drainText(story);
      return story;
    }

    it("shows rest when no P1-P3 tasks are active", () => {
      const story = setupRestTransit({
        FlipDone: true,
        EngineCondition: 100,
        Fatigue: 0,
        PaperworkDone: 1,
        PaperworkTotal: 1,
        TripDay: 4, // not a nav check day
        ShipCondition: 100,
      });
      expect(hasChoice(story, "Call it a day")).toBe(true);
    });

    it("does not show rest when P3 tasks are active (backlog populated)", () => {
      // Default setupTransit has backlog = P3 active
      const story = setupTransit({
        FlipDone: true,
        EngineCondition: 100,
        Fatigue: 0,
        PaperworkDone: 1,
        PaperworkTotal: 1,
        TripDay: 4,
        ShipCondition: 100,
      });
      expect(hasChoice(story, "Call it a day")).toBe(false);
    });

    it("does not show rest when P2 tasks are active", () => {
      const story = setupRestTransit({
        FlipDone: true,
        EngineCondition: 70, // engine degraded = P2 active
        Fatigue: 0,
        PaperworkDone: 1,
        PaperworkTotal: 1,
        TripDay: 4,
        ShipCondition: 100,
      });
      expect(hasChoice(story, "Call it a day")).toBe(false);
    });

    it("spends all remaining AP and advances the day", () => {
      const story = setupRestTransit({
        AP: 4,
        ShipClock: 3,
        FlipDone: true,
        EngineCondition: 100,
        Fatigue: 20,
        PaperworkDone: 1,
        PaperworkTotal: 1,
        TripDay: 4,
        ShipCondition: 100,
      });
      pickChoice(story, "Call it a day");
      // Day should have advanced (ShipClock decremented)
      expect(story.variablesState["ShipClock"]).toBe(2);
    });

    it("does not accumulate fatigue when resting", () => {
      const story = setupRestTransit({
        AP: 4,
        ShipClock: 3,
        Fatigue: 20,
        FlipDone: true,
        EngineCondition: 100,
        PaperworkDone: 1,
        PaperworkTotal: 1,
        TripDay: 4,
        ShipCondition: 100,
      });
      pickChoice(story, "Call it a day");
      // Fatigue should decrease by 10 (mild rest benefit), not increase
      expect(story.variablesState["Fatigue"]).toBe(10);
    });
  });

  describe("Sub-menus", () => {
    it("relax sub-menu shows rations, workout, and movie", () => {
      const story = setupTransit();
      pickChoice(story, "Take a break");
      expect(hasChoice(story, "rations")).toBe(true);
      expect(hasChoice(story, "workout")).toBe(true);
      expect(hasChoice(story, "movie")).toBe(true);
      expect(hasChoice(story, "Never mind")).toBe(true);
    });

    it("relax Never mind returns to top-level without spending AP", () => {
      const story = setupTransit({ AP: 6 });
      pickChoice(story, "Take a break");
      pickChoice(story, "Never mind");
      expect(story.variablesState["AP"]).toBe(6);
      // Should be back at ship_options with choices available
      expect(story.currentChoices.length).toBeGreaterThan(0);
    });

    it("sleep sub-menu shows nap when fatigue >= 30", () => {
      const story = setupTransit({ Fatigue: 50 });
      pickChoice(story, "Get some rest");
      expect(hasChoice(story, "nap")).toBe(true);
      expect(hasChoice(story, "full cycle")).toBe(true);
    });

    it("sleep sub-menu hides full sleep when fatigue < 40", () => {
      const story = setupTransit({ Fatigue: 35 });
      pickChoice(story, "Get some rest");
      expect(hasChoice(story, "nap")).toBe(true);
      expect(hasChoice(story, "full cycle")).toBe(false);
    });

    it("engine sub-menu shows diagnostics option", () => {
      const story = setupTransit({ EngineCondition: 70 });
      pickChoice(story, "engine");
      expect(hasChoice(story, "diagnostics")).toBe(true);
      expect(hasChoice(story, "Never mind")).toBe(true);
    });

    it("maintenance sub-menu shows backlog tasks", () => {
      const story = setupTransit();
      pickChoice(story, "Ship maintenance");
      // Should show at least one maintenance task and a back option
      const choices = choiceTexts(story);
      expect(choices.length).toBeGreaterThanOrEqual(2); // at least 1 task + Never mind
      expect(hasChoice(story, "Never mind")).toBe(true);
    });
  });

  describe("TaskCap enforcement", () => {
    it("respects a reduced TaskCap", () => {
      const story = setupTransit({
        TaskCap: 3,
        // Activate several tasks across tiers
        PaperworkDone: 0,
        PaperworkTotal: 2,
        TripDay: 6, // nav check day
      });
      const choices = choiceTexts(story);
      // Should not exceed TaskCap + possible Rest
      // Rest won't show since P3 tasks are active
      expect(choices.length).toBeLessThanOrEqual(3);
    });
  });

  describe("Shuffle variety", () => {
    it("offers different P3 tasks across runs with different seeds", () => {
      // Reuse a single story instance across seeds to avoid repeated compilation
      const story = setupTransit({
        TaskCap: 3, // Force only 1 P3 slot (cap 3, floor p4=1, so p3_cap=2, p2_cap=1)
        PaperworkDone: 0,
        PaperworkTotal: 2,
        ShipCondition: 70,
        TripDay: 6, // nav check day — all 3 P3 tasks eligible
      });

      const p3Seen = new Set();
      for (let seed = 0; seed < 20; seed++) {
        story.state.storySeed = seed;
        // Reset variables and re-navigate with this seed
        story.variablesState["PaperworkDone"] = 0;
        story.variablesState["PaperworkTotal"] = 2;
        story.variablesState["ShipCondition"] = 70;
        story.variablesState["TripDay"] = 6;
        story.variablesState["TaskCap"] = 3;
        story.variablesState["EventChance"] = 0;
        story.variablesState["EventCooldownDay"] = -1;
        story.ChoosePathString("transit.ship_options");
        drainText(story);
        const choices = choiceTexts(story);
        if (choices.some((c) => c.includes("paperwork"))) p3Seen.add("paperwork");
        if (choices.some((c) => c.includes("Navigation"))) p3Seen.add("nav");
        if (choices.some((c) => c.includes("Tidy"))) p3Seen.add("ship_maint");
        // Early exit once variety is confirmed
        if (p3Seen.size >= 2) break;
      }
      // With shuffle, we should see at least 2 different P3 tasks across 20 runs
      expect(p3Seen.size).toBeGreaterThanOrEqual(2);
    });
  });
});

describe("Fatigue-based task failure", () => {
  describe("Exhaustion text tiers", () => {
    it("shows no exhaustion text when fatigue < 70", () => {
      const story = createStory();
      story.variablesState["ShipCargo"] = new InkList();
      story.variablesState["Fatigue"] = 50;
      story.variablesState["ShipClock"] = 5;
      story.variablesState["ShipDestination"] = L(story, "AllLocations.Mars");
      story.variablesState["AP"] = 6;
      story.ChoosePathString("transit.ship_options");
      let text = "";
      while (story.canContinue) text += story.Continue();
      expect(text).not.toMatch(/running on fumes/i);
      expect(text).not.toMatch(/hands are shaking/i);
      expect(text).not.toMatch(/barely function/i);
    });

    it("shows tier 1 text at fatigue 70-79", () => {
      const story = createStory();
      story.variablesState["ShipCargo"] = new InkList();
      story.variablesState["Fatigue"] = 75;
      story.variablesState["ShipClock"] = 5;
      story.variablesState["ShipDestination"] = L(story, "AllLocations.Mars");
      story.variablesState["AP"] = 6;
      story.ChoosePathString("transit.ship_options");
      let text = "";
      while (story.canContinue) text += story.Continue();
      expect(text).toMatch(/running on fumes/i);
    });

    it("shows tier 2 text at fatigue 80-89", () => {
      const story = createStory();
      story.variablesState["ShipCargo"] = new InkList();
      story.variablesState["Fatigue"] = 85;
      story.variablesState["ShipClock"] = 5;
      story.variablesState["ShipDestination"] = L(story, "AllLocations.Mars");
      story.variablesState["AP"] = 6;
      story.ChoosePathString("transit.ship_options");
      let text = "";
      while (story.canContinue) text += story.Continue();
      expect(text).toMatch(/hands are shaking/i);
    });

    it("shows tier 3 text at fatigue 90+", () => {
      const story = createStory();
      story.variablesState["ShipCargo"] = new InkList();
      story.variablesState["Fatigue"] = 95;
      story.variablesState["ShipClock"] = 5;
      story.variablesState["ShipDestination"] = L(story, "AllLocations.Mars");
      story.variablesState["AP"] = 6;
      story.ChoosePathString("transit.ship_options");
      let text = "";
      while (story.canContinue) text += story.Continue();
      expect(text).toMatch(/barely function/i);
    });
  });

  describe("Tasks always succeed when not fatigued", () => {
    it("nav check succeeds at fatigue 0", () => {
      const story = setupTransit({
        Fatigue: 0,
        TripDay: 6,
        NavChecksCompleted: 1,
      });
      pickChoice(story, "Navigation check");
      expect(story.variablesState["NavChecksCompleted"]).toBe(2);
    });

    it("paperwork succeeds at fatigue 0", () => {
      const story = setupTransit({
        Fatigue: 0,
        PaperworkDone: 0,
        PaperworkTotal: 3,
      });
      pickChoice(story, "paperwork");
      expect(story.variablesState["PaperworkDone"]).toBe(1);
    });

    it("engine maintenance gives full +15 at fatigue 0", () => {
      const story = setupTransit({
        Fatigue: 0,
        EngineCondition: 70,
      });
      pickChoice(story, "engine");
      pickChoice(story, "diagnostics");
      expect(story.variablesState["EngineCondition"]).toBe(85);
    });

    it("backlog maintenance gives +5 condition at fatigue 0", () => {
      const story = setupTransit({
        Fatigue: 0,
        ShipCondition: 80,
        EngineCondition: 80,
      });
      const condBefore = story.variablesState["ShipCondition"];
      const engBefore = story.variablesState["EngineCondition"];
      pickChoice(story, "Ship maintenance");
      // Pick the first maintenance task (index 0)
      story.ChooseChoiceIndex(0);
      story.ContinueMaximally();
      const condAfter = story.variablesState["ShipCondition"];
      const engAfter = story.variablesState["EngineCondition"];
      // One of the two conditions should have increased by 5
      expect(condAfter - condBefore + engAfter - engBefore).toBe(5);
    });
  });

  describe("Statistical failure tests at high fatigue", () => {
    it("nav check sometimes fails at fatigue 90", () => {
      // Reuse one story instance for performance
      const story = setupTransit({
        Fatigue: 90,
        TripDay: 6,
        NavChecksCompleted: 0,
      });

      let successes = 0;
      const iterations = 100;
      for (let i = 0; i < iterations; i++) {
        story.variablesState["Fatigue"] = 90;
        story.variablesState["TripDay"] = 6;
        story.variablesState["NavChecksCompleted"] = 0;
        story.variablesState["AP"] = 6;
        story.variablesState["ShipClock"] = 5;
        story.variablesState["EventChance"] = 0;
        story.variablesState["EventCooldownDay"] = -1;
        story.ChoosePathString("transit.ship_options");
        drainText(story);
        pickChoice(story, "Navigation check");
        if (story.variablesState["NavChecksCompleted"] === 1) successes++;
        // Early exit: once we've seen both success and failure, variety is confirmed
        if (successes > 0 && successes < i + 1) break;
      }
      // At 70% failure rate, we should see both successes and failures
      expect(successes).toBeGreaterThan(0);
      expect(successes).toBeLessThan(iterations);
    });

    it("paperwork sometimes fails at fatigue 90", () => {
      const story = setupTransit({
        Fatigue: 90,
        PaperworkDone: 0,
        PaperworkTotal: 5,
      });

      let successes = 0;
      const iterations = 100;
      for (let i = 0; i < iterations; i++) {
        story.variablesState["Fatigue"] = 90;
        story.variablesState["PaperworkDone"] = 0;
        story.variablesState["PaperworkTotal"] = 5;
        story.variablesState["AP"] = 6;
        story.variablesState["ShipClock"] = 5;
        story.variablesState["EventChance"] = 0;
        story.variablesState["EventCooldownDay"] = -1;
        story.ChoosePathString("transit.ship_options");
        drainText(story);
        pickChoice(story, "paperwork");
        if (story.variablesState["PaperworkDone"] === 1) successes++;
        if (successes > 0 && successes < i + 1) break;
      }
      expect(successes).toBeGreaterThan(0);
      expect(successes).toBeLessThan(iterations);
    });

    it("engine maintenance sometimes gives degraded result at fatigue 90", () => {
      const story = setupTransit({
        Fatigue: 90,
        EngineCondition: 60,
      });

      let fullBoosts = 0;
      let degradedBoosts = 0;
      for (let i = 0; i < 50; i++) {
        story.variablesState["Fatigue"] = 90;
        story.variablesState["EngineCondition"] = 60;
        story.variablesState["AP"] = 6;
        story.variablesState["ShipClock"] = 5;
        story.variablesState["EventChance"] = 0;
        story.variablesState["EventCooldownDay"] = -1;
        story.ChoosePathString("transit.ship_options");
        drainText(story);
        pickChoice(story, "engine");
        pickChoice(story, "diagnostics");
        const cond = story.variablesState["EngineCondition"];
        if (cond === 75) fullBoosts++;
        else if (cond === 68) degradedBoosts++;
        if (fullBoosts > 0 && degradedBoosts > 0) break;
      }
      expect(fullBoosts).toBeGreaterThan(0);
      expect(degradedBoosts).toBeGreaterThan(0);
    });

    it("ship flip sometimes degrades at fatigue 90 (no longer deterministic)", () => {
      const story = setupTransit({
        Fatigue: 90,
        FlipDone: false,
        TripDay: 5,
        TripDuration: 10,
        TripFuelCost: 100,
        TripFuelPenalty: 0,
      });

      let cleanFlips = 0;
      let sloppyFlips = 0;
      for (let i = 0; i < 50; i++) {
        story.variablesState["Fatigue"] = 90;
        story.variablesState["FlipDone"] = false;
        story.variablesState["TripDay"] = 5;
        story.variablesState["TripDuration"] = 10;
        story.variablesState["TripFuelCost"] = 100;
        story.variablesState["TripFuelPenalty"] = 0;
        story.variablesState["AP"] = 6;
        story.variablesState["ShipClock"] = 5;
        story.variablesState["EventChance"] = 0;
        story.variablesState["EventCooldownDay"] = -1;
        story.ChoosePathString("transit.ship_options");
        drainText(story);
        pickChoice(story, "ship flip");
        const penalty = story.variablesState["TripFuelPenalty"];
        if (penalty === 0) cleanFlips++;
        else sloppyFlips++;
        if (cleanFlips > 0 && sloppyFlips > 0) break;
      }
      // Should see both outcomes — no longer deterministic
      expect(cleanFlips).toBeGreaterThan(0);
      expect(sloppyFlips).toBeGreaterThan(0);
    });
  });

  describe("Failure narrative text", () => {
    it("nav check failure tells player to try again", () => {
      // Run until we get a failure
      const story = setupTransit({
        Fatigue: 95,
        TripDay: 6,
        NavChecksCompleted: 0,
      });

      let failureText = null;
      for (let i = 0; i < 50; i++) {
        story.variablesState["Fatigue"] = 95;
        story.variablesState["TripDay"] = 6;
        story.variablesState["NavChecksCompleted"] = 0;
        story.variablesState["AP"] = 6;
        story.variablesState["ShipClock"] = 5;
        story.variablesState["EventChance"] = 0;
        story.variablesState["EventCooldownDay"] = -1;
        story.ChoosePathString("transit.ship_options");
        drainText(story);
        const text = pickChoiceGetText(story, "Navigation check");
        if (story.variablesState["NavChecksCompleted"] === 0) {
          failureText = text;
          break;
        }
      }
      expect(failureText).not.toBeNull();
      expect(failureText).toMatch(/try this again/i);
    });

    it("paperwork failure tells player to try again", () => {
      const story = setupTransit({
        Fatigue: 95,
        PaperworkDone: 0,
        PaperworkTotal: 3,
      });

      let failureText = null;
      for (let i = 0; i < 50; i++) {
        story.variablesState["Fatigue"] = 95;
        story.variablesState["PaperworkDone"] = 0;
        story.variablesState["PaperworkTotal"] = 3;
        story.variablesState["AP"] = 6;
        story.variablesState["ShipClock"] = 5;
        story.variablesState["EventChance"] = 0;
        story.variablesState["EventCooldownDay"] = -1;
        story.ChoosePathString("transit.ship_options");
        drainText(story);
        const text = pickChoiceGetText(story, "paperwork");
        if (story.variablesState["PaperworkDone"] === 0) {
          failureText = text;
          break;
        }
      }
      expect(failureText).not.toBeNull();
      expect(failureText).toMatch(/wait|rest/i);
    });
  });
});
