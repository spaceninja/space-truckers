/**
 * Unit tests for location and travel functions.
 *
 * Distance matrix (internal units, from locations.ink comments):
 *   Earth↔Luna=5,   Earth↔Mars=14,  Earth↔Ceres=22, Earth↔Ganymede=40, Earth↔Titan=52
 *   Luna↔Mars=8,    Luna↔Ceres=18,  Luna↔Ganymede=38, Luna↔Titan=50
 *   Mars↔Ceres=10,  Mars↔Ganymede=26, Mars↔Titan=36
 *   Ceres↔Ganymede=18, Ceres↔Titan=28
 *   Ganymede↔Titan=16
 *
 * Fuel prices:
 *   Inner (Earth, Luna, Mars) = 1.2
 *   Belt  (Ceres)             = 1.0
 *   Outer (Ganymede, Titan)   = 0.8
 */

import { describe, it, expect, beforeAll } from "vitest";
import { InkList } from "inkjs/full";
import { createStory, L } from "../helpers/story.js";

let story;

beforeAll(() => {
  story = createStory();
  // Clear cargo so fuel cost tests use only the base ship mass (5)
  story.variablesState["ShipCargo"] = new InkList();
});

function loc(name) {
  return L(story, `AllLocations.${name}`);
}

function dist(from, to) {
  return story.EvaluateFunction("get_distance", [loc(from), loc(to)]);
}

describe("get_distance", () => {
  it("Earth ↔ Luna = 5", () => {
    expect(dist("Earth", "Luna")).toBe(5);
    expect(dist("Luna", "Earth")).toBe(5);
  });
  it("Earth ↔ Mars = 14", () => {
    expect(dist("Earth", "Mars")).toBe(14);
    expect(dist("Mars", "Earth")).toBe(14);
  });
  it("Earth ↔ Ceres = 22", () => {
    expect(dist("Earth", "Ceres")).toBe(22);
    expect(dist("Ceres", "Earth")).toBe(22);
  });
  it("Earth ↔ Ganymede = 40", () => {
    expect(dist("Earth", "Ganymede")).toBe(40);
    expect(dist("Ganymede", "Earth")).toBe(40);
  });
  it("Earth ↔ Titan = 52", () => {
    expect(dist("Earth", "Titan")).toBe(52);
    expect(dist("Titan", "Earth")).toBe(52);
  });
  it("Luna ↔ Mars = 8", () => {
    expect(dist("Luna", "Mars")).toBe(8);
    expect(dist("Mars", "Luna")).toBe(8);
  });
  it("Luna ↔ Ceres = 18", () => {
    expect(dist("Luna", "Ceres")).toBe(18);
    expect(dist("Ceres", "Luna")).toBe(18);
  });
  it("Luna ↔ Ganymede = 38", () => {
    expect(dist("Luna", "Ganymede")).toBe(38);
    expect(dist("Ganymede", "Luna")).toBe(38);
  });
  it("Luna ↔ Titan = 50", () => {
    expect(dist("Luna", "Titan")).toBe(50);
    expect(dist("Titan", "Luna")).toBe(50);
  });
  it("Mars ↔ Ceres = 10", () => {
    expect(dist("Mars", "Ceres")).toBe(10);
    expect(dist("Ceres", "Mars")).toBe(10);
  });
  it("Mars ↔ Ganymede = 26", () => {
    expect(dist("Mars", "Ganymede")).toBe(26);
    expect(dist("Ganymede", "Mars")).toBe(26);
  });
  it("Mars ↔ Titan = 36", () => {
    expect(dist("Mars", "Titan")).toBe(36);
    expect(dist("Titan", "Mars")).toBe(36);
  });
  it("Ceres ↔ Ganymede = 18", () => {
    expect(dist("Ceres", "Ganymede")).toBe(18);
    expect(dist("Ganymede", "Ceres")).toBe(18);
  });
  it("Ceres ↔ Titan = 28", () => {
    expect(dist("Ceres", "Titan")).toBe(28);
    expect(dist("Titan", "Ceres")).toBe(28);
  });
  it("Ganymede ↔ Titan = 16", () => {
    expect(dist("Ganymede", "Titan")).toBe(16);
    expect(dist("Titan", "Ganymede")).toBe(16);
  });
});

describe("get_trip_duration", () => {
  // Formula: MAX(FLOOR(distance / speed), 1)

  it("Earth→Luna at speed 1.0: FLOOR(5/1.0)=5 days", () => {
    const dur = story.EvaluateFunction("get_trip_duration", [loc("Earth"), loc("Luna"), 1.0]);
    expect(dur).toBe(5);
  });

  it("Earth→Luna at speed 2.5 (Tier 1 Turbo): FLOOR(5/2.5)=2 days", () => {
    const dur = story.EvaluateFunction("get_trip_duration", [loc("Earth"), loc("Luna"), 2.5]);
    expect(dur).toBe(2);
  });

  it("Earth→Luna at speed 1.5 (Tier 1 Balance): FLOOR(5/1.5)=3 days", () => {
    const dur = story.EvaluateFunction("get_trip_duration", [loc("Earth"), loc("Luna"), 1.5]);
    expect(dur).toBe(3);
  });

  it("Earth→Titan at speed 2.0 (Tier 4 Eco): FLOOR(52/2.0)=26 days", () => {
    const dur = story.EvaluateFunction("get_trip_duration", [loc("Earth"), loc("Titan"), 2.0]);
    expect(dur).toBe(26);
  });

  it("minimum duration is 1 day even for very high speed", () => {
    // Earth→Luna dist=5 at speed 100 → FLOOR(5/100)=0, clamped to 1
    const dur = story.EvaluateFunction("get_trip_duration", [loc("Earth"), loc("Luna"), 100.0]);
    expect(dur).toBe(1);
  });
});

describe("get_trip_fuel_cost", () => {
  // Formula: FLOOR(distance × total_mass × fuel_factor)
  // total_mass = ShipCargo mass + 5 (ship hull)
  // ShipCargo is empty in beforeAll, so total_mass = 5

  it("Earth→Luna, factor 1.1, empty cargo: FLOOR(5×5×1.1)=27", () => {
    const cost = story.EvaluateFunction("get_trip_fuel_cost", [loc("Earth"), loc("Luna"), 1.1]);
    expect(cost).toBe(27);
  });

  it("Earth→Mars, factor 1.8 (Tier 1 Balance), empty cargo: FLOOR(14×5×1.8)=126", () => {
    const cost = story.EvaluateFunction("get_trip_fuel_cost", [loc("Earth"), loc("Mars"), 1.8]);
    expect(cost).toBe(126);
  });

  it("Ganymede→Titan, factor 0.5 (Tier 3 Eco), empty cargo: FLOOR(16×5×0.5)=40", () => {
    const cost = story.EvaluateFunction("get_trip_fuel_cost", [loc("Ganymede"), loc("Titan"), 0.5]);
    expect(cost).toBe(40);
  });

  it("fuel cost increases with cargo mass", () => {
    // Add 001_Plums (mass=10): total_mass = 10+5 = 15
    // Earth→Luna, factor 1.1: FLOOR(5×15×1.1) = FLOOR(82.5) = 82
    story.variablesState["ShipCargo"] = L(story, "AllCargo.001_Plums");
    const cost = story.EvaluateFunction("get_trip_fuel_cost", [loc("Earth"), loc("Luna"), 1.1]);
    expect(cost).toBe(82);
    // Reset for subsequent tests
    story.variablesState["ShipCargo"] = new InkList();
  });
});

describe("get_engine_fuel_penalty", () => {
  // Formula: FLOOR(base_cost × (100 - EngineCondition) / 2 / 100)
  // +5% fuel cost per 10% degradation below 100%
  // Uses fresh story per test to avoid shared state issues with EngineCondition.

  function penalty(baseCost, condition) {
    const s = createStory();
    s.variablesState["ShipCargo"] = new InkList();
    s.variablesState["EngineCondition"] = condition;
    return s.EvaluateFunction("get_engine_fuel_penalty", [baseCost]);
  }

  it("returns 0 at 100% condition", () => {
    expect(penalty(280, 100)).toBe(0);
  });

  it("returns 5% at 90% condition: FLOOR(280 × 5 / 100) = 14", () => {
    expect(penalty(280, 90)).toBe(14);
  });

  it("returns 10% at 80% condition: FLOOR(280 × 10 / 100) = 28", () => {
    expect(penalty(280, 80)).toBe(28);
  });

  it("returns 25% at 50% condition: FLOOR(280 × 25 / 100) = 70", () => {
    expect(penalty(280, 50)).toBe(70);
  });

  it("returns 0 at 100% condition even with large base cost", () => {
    expect(penalty(10000, 100)).toBe(0);
  });

  it("floors fractional results", () => {
    // At 90%: FLOOR(100 × 5 / 100) = FLOOR(5) = 5
    expect(penalty(100, 90)).toBe(5);
    // At 90%: FLOOR(50 × 5 / 100) = FLOOR(2.5) = 2
    expect(penalty(50, 90)).toBe(2);
  });
});

describe("get_fuel_price", () => {
  it("Earth is inner system: 1.2", () => {
    expect(story.EvaluateFunction("get_fuel_price", [loc("Earth")])).toBeCloseTo(1.2);
  });
  it("Luna is inner system: 1.2", () => {
    expect(story.EvaluateFunction("get_fuel_price", [loc("Luna")])).toBeCloseTo(1.2);
  });
  it("Mars is inner system: 1.2", () => {
    expect(story.EvaluateFunction("get_fuel_price", [loc("Mars")])).toBeCloseTo(1.2);
  });
  it("Ceres is belt: 1.0", () => {
    expect(story.EvaluateFunction("get_fuel_price", [loc("Ceres")])).toBeCloseTo(1.0);
  });
  it("Ganymede is outer system: 0.8", () => {
    expect(story.EvaluateFunction("get_fuel_price", [loc("Ganymede")])).toBeCloseTo(0.8);
  });
  it("Titan is outer system: 0.8", () => {
    expect(story.EvaluateFunction("get_fuel_price", [loc("Titan")])).toBeCloseTo(0.8);
  });
});
