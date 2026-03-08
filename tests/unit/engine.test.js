/**
 * Unit tests for EngineData — verifies all 4 engine tiers return the correct
 * stats from the database defined in space-truckers.ink.
 *
 * Source of truth:
 *   Tier 1: engine_db(stat, 300, 1.1, 1.0, 1.8, 1.5, 4.0, 2.5)
 *   Tier 2: engine_db(stat, 500, 0.8, 1.0, 1.5, 2.0, 3.0, 3.0)
 *   Tier 3: engine_db(stat, 650, 0.5, 1.5, 0.9, 2.5, 1.8, 4.0)
 *   Tier 4: engine_db(stat, 800, 0.3, 2.0, 0.6, 3.5, 1.2, 5.0)
 */

import { describe, it, expect, beforeAll } from "vitest";
import { createStory, L } from "../helpers/story.js";

let story;

beforeAll(() => {
  story = createStory();
});

function engine(tier, stat) {
  return story.EvaluateFunction("EngineData", [tier, L(story, `EngineStats.${stat}`)]);
}

describe("EngineData", () => {
  describe("Tier 1", () => {
    it("FuelCap = 300", () => expect(engine(1, "FuelCap")).toBe(300));
    it("EcoFuel = 1.1", () => expect(engine(1, "EcoFuel")).toBeCloseTo(1.1));
    it("EcoSpeed = 1.0", () => expect(engine(1, "EcoSpeed")).toBeCloseTo(1.0));
    it("BalFuel = 1.8", () => expect(engine(1, "BalFuel")).toBeCloseTo(1.8));
    it("BalSpeed = 1.5", () => expect(engine(1, "BalSpeed")).toBeCloseTo(1.5));
    it("TurboFuel = 4.0", () => expect(engine(1, "TurboFuel")).toBeCloseTo(4.0));
    it("TurboSpeed = 2.5", () => expect(engine(1, "TurboSpeed")).toBeCloseTo(2.5));
  });

  describe("Tier 2", () => {
    it("FuelCap = 500", () => expect(engine(2, "FuelCap")).toBe(500));
    it("EcoFuel = 0.8", () => expect(engine(2, "EcoFuel")).toBeCloseTo(0.8));
    it("EcoSpeed = 1.0", () => expect(engine(2, "EcoSpeed")).toBeCloseTo(1.0));
    it("BalFuel = 1.5", () => expect(engine(2, "BalFuel")).toBeCloseTo(1.5));
    it("BalSpeed = 2.0", () => expect(engine(2, "BalSpeed")).toBeCloseTo(2.0));
    it("TurboFuel = 3.0", () => expect(engine(2, "TurboFuel")).toBeCloseTo(3.0));
    it("TurboSpeed = 3.0", () => expect(engine(2, "TurboSpeed")).toBeCloseTo(3.0));
  });

  describe("Tier 3", () => {
    it("FuelCap = 650", () => expect(engine(3, "FuelCap")).toBe(650));
    it("EcoFuel = 0.5", () => expect(engine(3, "EcoFuel")).toBeCloseTo(0.5));
    it("EcoSpeed = 1.5", () => expect(engine(3, "EcoSpeed")).toBeCloseTo(1.5));
    it("BalFuel = 0.9", () => expect(engine(3, "BalFuel")).toBeCloseTo(0.9));
    it("BalSpeed = 2.5", () => expect(engine(3, "BalSpeed")).toBeCloseTo(2.5));
    it("TurboFuel = 1.8", () => expect(engine(3, "TurboFuel")).toBeCloseTo(1.8));
    it("TurboSpeed = 4.0", () => expect(engine(3, "TurboSpeed")).toBeCloseTo(4.0));
  });

  describe("Tier 4", () => {
    it("FuelCap = 800", () => expect(engine(4, "FuelCap")).toBe(800));
    it("EcoFuel = 0.3", () => expect(engine(4, "EcoFuel")).toBeCloseTo(0.3));
    it("EcoSpeed = 2.0", () => expect(engine(4, "EcoSpeed")).toBeCloseTo(2.0));
    it("BalFuel = 0.6", () => expect(engine(4, "BalFuel")).toBeCloseTo(0.6));
    it("BalSpeed = 3.5", () => expect(engine(4, "BalSpeed")).toBeCloseTo(3.5));
    it("TurboFuel = 1.2", () => expect(engine(4, "TurboFuel")).toBeCloseTo(1.2));
    it("TurboSpeed = 5.0", () => expect(engine(4, "TurboSpeed")).toBeCloseTo(5.0));
  });
});
