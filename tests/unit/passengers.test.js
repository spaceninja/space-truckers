/**
 * Unit tests for the passenger module and satisfaction system.
 *
 *   PassengerTierPrice / PassengerTierName
 *   get_module_condition / set_module_condition for PassengerModule
 *   PassengerTaskName
 *   pick_passenger_task — weighted category selection
 */

import { describe, it, expect, beforeEach } from "vitest";
import { InkList } from "inkjs/full";
import { createStory, L } from "../helpers/story.js";

let story;

beforeEach(() => {
  story = createStory();
});

describe("PassengerTierPrice", () => {
  it("returns 200 for tier 1", () => {
    expect(story.EvaluateFunction("PassengerTierPrice", [1])).toBe(200);
  });

  it("returns 400 for tier 2", () => {
    expect(story.EvaluateFunction("PassengerTierPrice", [2])).toBe(400);
  });

  it("returns 800 for tier 3", () => {
    expect(story.EvaluateFunction("PassengerTierPrice", [3])).toBe(800);
  });

  it("returns 0 for unknown tier", () => {
    expect(story.EvaluateFunction("PassengerTierPrice", [0])).toBe(0);
  });

  it("upgrade T1→T2 costs 200 (delta)", () => {
    const t1 = story.EvaluateFunction("PassengerTierPrice", [1]);
    const t2 = story.EvaluateFunction("PassengerTierPrice", [2]);
    expect(t2 - t1).toBe(200);
  });

  it("upgrade T2→T3 costs 400 (delta)", () => {
    const t2 = story.EvaluateFunction("PassengerTierPrice", [2]);
    const t3 = story.EvaluateFunction("PassengerTierPrice", [3]);
    expect(t3 - t2).toBe(400);
  });
});

describe("PassengerTierName", () => {
  it("returns Basic Berths for tier 1", () => {
    expect(story.EvaluateFunction("PassengerTierName", [1])).toBe("Basic Berths");
  });

  it("returns Standard Cabin for tier 2", () => {
    expect(story.EvaluateFunction("PassengerTierName", [2])).toBe("Standard Cabin");
  });

  it("returns Luxury Suite for tier 3", () => {
    expect(story.EvaluateFunction("PassengerTierName", [3])).toBe("Luxury Suite");
  });
});

describe("PassengerModule condition accessors", () => {
  it("returns 0 for uninstalled PassengerModule", () => {
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.PassengerModule")])).toBe(0);
  });

  it("round-trips PassengerModule condition", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.PassengerModule"), 85]);
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.PassengerModule")])).toBe(85);
  });
});

describe("PassengerModule maint_task_module", () => {
  it("maps PaxLifeSupp to PassengerModule", () => {
    const result = story.EvaluateFunction("maint_task_module", [L(story, "ModuleMaintTasks.PaxLifeSupp")]);
    expect(result.Equals(L(story, "ShipModules.PassengerModule"))).toBe(true);
  });

  it("maps PaxBerthClean to PassengerModule", () => {
    const result = story.EvaluateFunction("maint_task_module", [L(story, "ModuleMaintTasks.PaxBerthClean")]);
    expect(result.Equals(L(story, "ShipModules.PassengerModule"))).toBe(true);
  });
});

describe("PassengerTaskName", () => {
  it("returns a non-empty string for each task", () => {
    const tasks = [
      "PaxShower", "PaxQuarters", "PaxAirQuality", "PaxRations",
      "PaxMovieNight", "PaxMealService", "PaxGameNight", "PaxExercise",
      "PaxObsDeck", "PaxKaraoke", "PaxStargazing", "PaxCocktails",
    ];
    for (const task of tasks) {
      const name = story.EvaluateFunction("PassengerTaskName", [L(story, `PassengerTasks.${task}`)]);
      expect(typeof name).toBe("string");
      expect(name.length).toBeGreaterThan(0);
    }
  });
});

describe("pick_passenger_task — weighted category selection", () => {
  const ITERATIONS = 80;

  const NEGATIVE_TASKS = ["PaxShower", "PaxQuarters", "PaxAirQuality", "PaxRations"];
  const MIXED_TASKS = ["PaxMovieNight", "PaxMealService", "PaxGameNight", "PaxExercise"];
  const POSITIVE_TASKS = ["PaxObsDeck", "PaxKaraoke", "PaxStargazing", "PaxCocktails"];

  function classifyTask(s, task) {
    if (NEGATIVE_TASKS.some(t => task.Equals(L(s, `PassengerTasks.${t}`)))) return "negative";
    if (MIXED_TASKS.some(t => task.Equals(L(s, `PassengerTasks.${t}`)))) return "mixed";
    if (POSITIVE_TASKS.some(t => task.Equals(L(s, `PassengerTasks.${t}`)))) return "positive";
    return "unknown";
  }

  function countCategories(tier) {
    const s = createStory();
    const counts = { negative: 0, mixed: 0, positive: 0, unknown: 0 };

    for (let i = 0; i < ITERATIONS; i++) {
      s.ResetState();
      s.variablesState["PassengerModuleTier"] = tier;
      s.EvaluateFunction("pick_passenger_task");
      const task = s.variablesState["DailyPassengerTask"];
      counts[classifyTask(s, task)]++;
    }
    return counts;
  }

  it("tier 1 draws more negative than positive tasks", () => {
    const counts = countCategories(1);
    expect(counts.negative).toBeGreaterThan(counts.positive);
  });

  it("tier 3 draws more mixed than negative tasks", () => {
    const counts = countCategories(3);
    expect(counts.mixed).toBeGreaterThan(counts.negative);
  });

  it("all tiers produce tasks from all three categories over many draws", () => {
    for (const tier of [1, 2, 3]) {
      const counts = countCategories(tier);
      expect(counts.negative, `tier ${tier} negative`).toBeGreaterThan(0);
      expect(counts.mixed, `tier ${tier} mixed`).toBeGreaterThan(0);
      expect(counts.positive, `tier ${tier} positive`).toBeGreaterThan(0);
      expect(counts.unknown, `tier ${tier} unknown`).toBe(0);
    }
  });

  it("sets PassengerTaskCompleted to false", () => {
    story.variablesState["PassengerModuleTier"] = 1;
    story.variablesState["PassengerTaskCompleted"] = true;
    story.EvaluateFunction("pick_passenger_task");
    expect(story.variablesState["PassengerTaskCompleted"]).toBe(false);
  });

  it("rarely draws the same task two days in a row", () => {
    const s = createStory();
    let repeats = 0;
    const ITERATIONS = 100;

    for (let i = 0; i < ITERATIONS; i++) {
      s.ResetState();
      s.variablesState["PassengerModuleTier"] = 1;
      // Set a known previous task
      s.variablesState["DailyPassengerTask"] = L(s, "PassengerTasks.PaxShower");
      s.EvaluateFunction("pick_passenger_task");
      if (s.variablesState["DailyPassengerTask"].Equals(L(s, "PassengerTasks.PaxShower"))) {
        repeats++;
      }
    }
    // With redraw, repeat rate should be ~6.25% (1/16), not ~25% (1/4)
    // Allow up to 15% to avoid flaky tests
    expect(repeats).toBeLessThan(ITERATIONS * 0.15);
  });
});
