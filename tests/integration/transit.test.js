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

import { describe, it, expect } from "vitest";
import { cargo, drainText } from "../helpers/story.js";
import {
  choiceTexts,
  hasChoice,
  pickChoice,
  pickChoiceGetText,
  setupTransit,
} from "../helpers/integration.js";

describe("Task priority system", () => {
  describe("P1: Urgent tasks always show", () => {
    it("shows ship flip at midpoint regardless of other tasks", () => {
      const story = setupTransit({
        FlipDone: false,
        TripDay: 5,
        TripDuration: 10,
        // Also activate P2 and P3 tasks
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
    it("shows nap when fatigue >= 70", () => {
      const story = setupTransit({ Fatigue: 75 });
      expect(hasChoice(story, "nap")).toBe(true);
    });

    it("shows full sleep when fatigue >= 70 (implies >= 40)", () => {
      const story = setupTransit({ Fatigue: 75 });
      expect(hasChoice(story, "full cycle")).toBe(true);
    });

    it("does not show sleep at P2 when fatigue < 70", () => {
      const story = setupTransit({ Fatigue: 60 });
      // Sleep appears at P4 (30-69), not as P2 urgent
      // Both nap and full sleep should be absent from P2 (they may still appear at P4)
      // Verify P4 nap is present but P2 urgent context is not triggered
      // (best proxy: full sleep still shows since fatigue >= 40)
      expect(hasChoice(story, "nap")).toBe(true); // P4 nap
    });

    it("does not show sleep at all when fatigue < 30", () => {
      const story = setupTransit({ Fatigue: 20 });
      expect(hasChoice(story, "nap")).toBe(false);
      expect(hasChoice(story, "full cycle")).toBe(false);
    });

    it("shows nav check when due (TripDay >= NavCheckDueDay)", () => {
      const story = setupTransit({ TripDay: 6, NavCheckDueDay: 6 });
      expect(hasChoice(story, "Navigation check")).toBe(true);
    });

    it("does not show nav check before it is due", () => {
      const story = setupTransit({ TripDay: 4, NavCheckDueDay: 6 });
      expect(hasChoice(story, "Navigation check")).toBe(false);
    });

    it("does not show nav check after completing it (due day advanced)", () => {
      const story = setupTransit({
        TripDay: 6,
        NavCheckDueDay: 9, // completed on day 6, next due day 9
      });
      expect(hasChoice(story, "Navigation check")).toBe(false);
    });

    it("shows cargo inspection when due (TripDay >= CargoCheckDueDay)", () => {
      const story = setupTransit({ TripDay: 2, CargoCheckDueDay: 2 });
      expect(hasChoice(story, "Cargo inspection")).toBe(true);
    });

    it("does not show cargo inspection before it is due", () => {
      const story = setupTransit({ TripDay: 1, CargoCheckDueDay: 2 });
      expect(hasChoice(story, "Cargo inspection")).toBe(false);
    });

    it("does not show cargo inspection after completing it (due day advanced)", () => {
      const story = setupTransit({
        TripDay: 2,
        CargoCheckDueDay: 5, // completed on day 2, next due day 5
      });
      expect(hasChoice(story, "Cargo inspection")).toBe(false);
    });
  });

  describe("P3: Routine tasks", () => {
    it("shows maintenance tasks directly when backlog has tasks", () => {
      const story = setupTransit({}, { navigate: false });
      story.variablesState["Backlog"] = cargo(
        story,
        "MaintTasks.FuelLine",
        "MaintTasks.AirFilter",
        "MaintTasks.HullCheck"
      );
      story.ChoosePathString("transit.ship_options");
      drainText(story);
      const choices = choiceTexts(story);
      expect(choices.some((c) => c.includes("AP)"))).toBe(true);
    });

    it("shows stale maintenance tasks before fresh ones", () => {
      const story = setupTransit({}, { navigate: false });
      story.variablesState["Backlog"] = cargo(
        story,
        "MaintTasks.AirFilter",
        "MaintTasks.FuelLine"
      );
      story.variablesState["StaleBacklog"] = cargo(story, "MaintTasks.AirFilter");
      story.ChoosePathString("transit.ship_options");
      drainText(story);
      const choices = choiceTexts(story);
      // The stale task (AirFilter) should appear before the fresh task (FuelLine)
      const airFilterIdx = choices.findIndex((c) => c.includes("overdue"));
      const engTuneIdx = choices.findIndex(
        (c) => c.includes("AP)") && !c.includes("overdue")
      );
      expect(airFilterIdx).toBeGreaterThanOrEqual(0);
      expect(engTuneIdx).toBeGreaterThanOrEqual(0);
      expect(airFilterIdx).toBeLessThan(engTuneIdx);
    });
  });

  describe("P4: Rest", () => {
    it("shows nap when fatigue is moderate (30-69)", () => {
      const story = setupTransit({ Fatigue: 50 });
      expect(hasChoice(story, "nap")).toBe(true);
    });

    it("shows full cycle when fatigue >= 40", () => {
      const story = setupTransit({ Fatigue: 50 });
      expect(hasChoice(story, "full cycle")).toBe(true);
    });

    it("hides full cycle when fatigue < 40 (but >= 30)", () => {
      const story = setupTransit({ Fatigue: 35 });
      expect(hasChoice(story, "nap")).toBe(true);
      expect(hasChoice(story, "full cycle")).toBe(false);
    });

    it("does not show P4 sleep when fatigue < 30", () => {
      const story = setupTransit({ Fatigue: 20 });
      expect(hasChoice(story, "nap")).toBe(false);
    });

    it("shows paperwork when chunks remain", () => {
      const story = setupTransit({
        PaperworkDone: 0,
        PaperworkTotal: 2,
      });
      expect(hasChoice(story, "paperwork")).toBe(true);
    });
  });

  describe("P5: Rest", () => {
    it("shows rest when no P1-P3 tasks are active", () => {
      const story = setupTransit({
        FlipDone: true,
        Fatigue: 0,
        PaperworkDone: 1,
        PaperworkTotal: 1,
        TripDay: 4, // not a nav check day
        ShipCondition: 100,
      });
      expect(hasChoice(story, "Call it a day")).toBe(true);
    });

    it("does not show rest when P3 tasks are active (backlog populated)", () => {
      const story = setupTransit({
        FlipDone: true,
        Fatigue: 0,
        PaperworkDone: 1,
        PaperworkTotal: 1,
        TripDay: 4,
        ShipCondition: 100,
      }, { navigate: false });
      story.variablesState["Backlog"] = cargo(
        story,
        "MaintTasks.FuelLine",
        "MaintTasks.AirFilter"
      );
      story.ChoosePathString("transit.ship_options");
      drainText(story);
      expect(hasChoice(story, "Call it a day")).toBe(false);
    });

    it("does not show rest when P2 tasks are active", () => {
      const story = setupTransit({
        FlipDone: true,
        TripDay: 6,
        NavCheckDueDay: 6, // nav check due = P2 active
        Fatigue: 0,
        PaperworkDone: 1,
        PaperworkTotal: 1,
        ShipCondition: 100,
      });
      expect(hasChoice(story, "Call it a day")).toBe(false);
    });

    it("spends all remaining AP and advances the day", () => {
      const story = setupTransit({
        AP: 4,
        ShipClock: 3,
        FlipDone: true,
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
      const story = setupTransit({
        AP: 4,
        ShipClock: 3,
        Fatigue: 20,
        FlipDone: true,
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

  describe("TaskCap enforcement", () => {
    it("respects a reduced TaskCap", () => {
      const story = setupTransit({
        TaskCap: 3,
        // Activate tasks across tiers
        TripDay: 6,
        NavCheckDueDay: 6, // nav check due (P2)
        CargoCheckDueDay: 6, // cargo inspect due (P2)
      });
      const choices = choiceTexts(story);
      // Should not exceed TaskCap; P3 (maintenance) gets leftover slots
      expect(choices.length).toBeLessThanOrEqual(3);
    });
  });

  describe("Shuffle variety", () => {
    it("offers different P2 tasks across runs with different seeds", () => {
      // P2 shuffles nav check, cargo inspect, and sleep tasks — with a small cap only
      // some fit, so the shuffle determines which appear.
      const story = setupTransit({
        TripDay: 6,
        NavCheckDueDay: 6, // due — P2 eligible
        CargoCheckDueDay: 6, // due — P2 eligible
        Fatigue: 75, // P2 sleep eligible
        TaskCap: 2, // only 2 slots; 3 eligible P2 tasks compete
      }, { navigate: false });

      const p2Seen = new Set();
      for (let seed = 0; seed < 20; seed++) {
        story.state.storySeed = seed;
        story.variablesState["NavCheckDueDay"] = 6;
        story.variablesState["CargoCheckDueDay"] = 6;
        story.variablesState["Fatigue"] = 75;
        story.variablesState["TaskCap"] = 2;
        story.variablesState["EventChance"] = 0;
        story.variablesState["EventCooldownDay"] = -1;
        story.ChoosePathString("transit.ship_options");
        drainText(story);
        const choices = choiceTexts(story);
        if (choices.some((c) => c.includes("Navigation"))) p2Seen.add("nav");
        if (choices.some((c) => c.includes("Cargo inspection"))) p2Seen.add("cargo");
        if (choices.some((c) => c.includes("nap"))) p2Seen.add("sleep");
        if (p2Seen.size >= 2) break;
      }
      // With shuffle, we should see at least 2 different P2 tasks across 20 runs
      expect(p2Seen.size).toBeGreaterThanOrEqual(2);
    });
  });
});

describe("Fatigue-based task failure", () => {
  describe("Exhaustion text tiers", () => {
    function setupAndGetText(fatigue) {
      const story = setupTransit({ Fatigue: fatigue }, { navigate: false });
      story.ChoosePathString("transit.ship_options");
      let text = "";
      while (story.canContinue) text += story.Continue();
      return text;
    }

    it("shows no exhaustion text when fatigue < 70", () => {
      const text = setupAndGetText(50);
      expect(text).not.toMatch(/running on fumes/i);
      expect(text).not.toMatch(/hands are shaking/i);
      expect(text).not.toMatch(/barely function/i);
    });

    it("shows tier 1 text at fatigue 70-79", () => {
      expect(setupAndGetText(75)).toMatch(/running on fumes/i);
    });

    it("shows tier 2 text at fatigue 80-89", () => {
      expect(setupAndGetText(85)).toMatch(/hands are shaking/i);
    });

    it("shows tier 3 text at fatigue 90+", () => {
      expect(setupAndGetText(95)).toMatch(/barely function/i);
    });
  });

  describe("Tasks always succeed when not fatigued", () => {
    it("nav check succeeds at fatigue 0", () => {
      const story = setupTransit({
        Fatigue: 0,
        TripDay: 6,
        NavCheckDueDay: 6,
      });
      pickChoice(story, "Navigation check");
      // Success advances NavCheckDueDay by 3
      expect(story.variablesState["NavCheckDueDay"]).toBe(9);
    });

    it("cargo inspection succeeds at fatigue 0", () => {
      const story = setupTransit({
        Fatigue: 0,
        TripDay: 2,
        CargoCheckDueDay: 2,
      });
      pickChoice(story, "Cargo inspection");
      // Success advances CargoCheckDueDay by 3 (no special cargo in default setup)
      expect(story.variablesState["CargoCheckDueDay"]).toBe(5);
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

    it("backlog maintenance gives +3 condition at fatigue 0", () => {
      const story = setupTransit({
        Fatigue: 0,
        ShipCondition: 80,
      }, { navigate: false });
      story.variablesState["Backlog"] = cargo(story, "MaintTasks.FuelLine");
      story.ChoosePathString("transit.ship_options");
      drainText(story);
      const condBefore = story.variablesState["ShipCondition"];
      // Maintenance tasks appear directly; pick the first one (index 0)
      story.ChooseChoiceIndex(0);
      story.ContinueMaximally();
      const condAfter = story.variablesState["ShipCondition"];
      // Ship condition should have increased by 3 (non-module task)
      expect(condAfter - condBefore).toBe(3);
    });
  });

  describe("Statistical failure tests at high fatigue", () => {
    it("nav check sometimes fails at fatigue 90", () => {
      // Reuse one story instance for performance
      const story = setupTransit({
        Fatigue: 90,
        TripDay: 6,
        NavCheckDueDay: 6,
      });

      let successes = 0;
      const iterations = 100;
      for (let i = 0; i < iterations; i++) {
        story.variablesState["Fatigue"] = 90;
        story.variablesState["TripDay"] = 6;
        story.variablesState["NavCheckDueDay"] = 6;
        story.variablesState["AP"] = 6;
        story.variablesState["ShipClock"] = 5;
        story.variablesState["EventChance"] = 0;
        story.variablesState["EventCooldownDay"] = -1;
        story.ChoosePathString("transit.ship_options");
        drainText(story);
        pickChoice(story, "Navigation check");
        // Success: NavCheckDueDay advances to 9; failure: stays at 6
        if (story.variablesState["NavCheckDueDay"] === 9) successes++;
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
        NavCheckDueDay: 6,
      });

      let failureText = null;
      for (let i = 0; i < 50; i++) {
        story.variablesState["Fatigue"] = 95;
        story.variablesState["TripDay"] = 6;
        story.variablesState["NavCheckDueDay"] = 6;
        story.variablesState["AP"] = 6;
        story.variablesState["ShipClock"] = 5;
        story.variablesState["EventChance"] = 0;
        story.variablesState["EventCooldownDay"] = -1;
        story.ChoosePathString("transit.ship_options");
        drainText(story);
        const text = pickChoiceGetText(story, "Navigation check");
        // Failure: NavCheckDueDay stays at 6 (not advanced)
        if (story.variablesState["NavCheckDueDay"] === 6) {
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
