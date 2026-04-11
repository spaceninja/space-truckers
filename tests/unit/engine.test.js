/**
 * Unit tests for EngineData — verifies all engine tiers across 3 manufacturers
 * return the correct stats from the database defined in space-truckers.ink.
 *
 * Manufacturers:
 *   Kepler  (Earth)  — balanced, best Balance mode
 *   Olympus (Mars)   — turbo-optimized, best Turbo mode
 *   Huygens (Titan)  — eco-optimized, best Eco mode
 *
 * Tier 1 is a universal starter engine shared by all manufacturers.
 *
 * Also covers:
 *   manufacturer_available_here — gates which manufacturers are sold at each port
 */

import { describe, it, expect, beforeAll, beforeEach } from "vitest";
import { createStory, L } from "../helpers/story.js";

let story;

beforeAll(() => {
  story = createStory();
});

function engine(mfg, tier, stat) {
  return story.EvaluateFunction("EngineData", [
    L(story, `Manufacturers.${mfg}`),
    tier,
    L(story, `EngineStats.${stat}`),
  ]);
}

function availableAt(mfg, location) {
  story.variablesState["here"] = L(story, `AllLocations.${location}`);
  return story.EvaluateFunction("manufacturer_available_here", [
    L(story, `Manufacturers.${mfg}`),
  ]);
}

// ── Stat verification ─────────────────────────────────────────────────────

describe("EngineData", () => {
  describe("Tier 1 (universal)", () => {
    it("FuelCap = 300", () => expect(engine("Kepler", 1, "FuelCap")).toBe(300));
    it("EcoFuel = 1.1", () => expect(engine("Kepler", 1, "EcoFuel")).toBeCloseTo(1.1));
    it("EcoSpeed = 1.0", () => expect(engine("Kepler", 1, "EcoSpeed")).toBeCloseTo(1.0));
    it("BalFuel = 1.8", () => expect(engine("Kepler", 1, "BalFuel")).toBeCloseTo(1.8));
    it("BalSpeed = 1.5", () => expect(engine("Kepler", 1, "BalSpeed")).toBeCloseTo(1.5));
    it("TurboFuel = 4.0", () => expect(engine("Kepler", 1, "TurboFuel")).toBeCloseTo(4.0));
    it("TurboSpeed = 2.5", () => expect(engine("Kepler", 1, "TurboSpeed")).toBeCloseTo(2.5));

    it("is the same for all manufacturers", () => {
      const stats = ["FuelCap", "EcoFuel", "EcoSpeed", "BalFuel", "BalSpeed", "TurboFuel", "TurboSpeed"];
      for (const stat of stats) {
        expect(engine("Olympus", 1, stat)).toBeCloseTo(engine("Kepler", 1, stat));
        expect(engine("Huygens", 1, stat)).toBeCloseTo(engine("Kepler", 1, stat));
      }
    });
  });

  describe("Kepler (Earth — balanced)", () => {
    it("T2 FuelCap = 500", () => expect(engine("Kepler", 2, "FuelCap")).toBe(500));
    it("T2 EcoFuel = 0.8", () => expect(engine("Kepler", 2, "EcoFuel")).toBeCloseTo(0.8));
    it("T2 EcoSpeed = 1.1", () => expect(engine("Kepler", 2, "EcoSpeed")).toBeCloseTo(1.1));
    it("T2 BalFuel = 1.5", () => expect(engine("Kepler", 2, "BalFuel")).toBeCloseTo(1.5));
    it("T2 BalSpeed = 2.0", () => expect(engine("Kepler", 2, "BalSpeed")).toBeCloseTo(2.0));
    it("T2 TurboFuel = 3.0", () => expect(engine("Kepler", 2, "TurboFuel")).toBeCloseTo(3.0));
    it("T2 TurboSpeed = 3.0", () => expect(engine("Kepler", 2, "TurboSpeed")).toBeCloseTo(3.0));

    it("T3 FuelCap = 650", () => expect(engine("Kepler", 3, "FuelCap")).toBe(650));
    it("T3 EcoFuel = 0.5", () => expect(engine("Kepler", 3, "EcoFuel")).toBeCloseTo(0.5));
    it("T3 EcoSpeed = 1.5", () => expect(engine("Kepler", 3, "EcoSpeed")).toBeCloseTo(1.5));
    it("T3 BalFuel = 0.9", () => expect(engine("Kepler", 3, "BalFuel")).toBeCloseTo(0.9));
    it("T3 BalSpeed = 2.5", () => expect(engine("Kepler", 3, "BalSpeed")).toBeCloseTo(2.5));
    it("T3 TurboFuel = 1.8", () => expect(engine("Kepler", 3, "TurboFuel")).toBeCloseTo(1.8));
    it("T3 TurboSpeed = 4.0", () => expect(engine("Kepler", 3, "TurboSpeed")).toBeCloseTo(4.0));

    it("T4 FuelCap = 800", () => expect(engine("Kepler", 4, "FuelCap")).toBe(800));
    it("T4 EcoFuel = 0.3", () => expect(engine("Kepler", 4, "EcoFuel")).toBeCloseTo(0.3));
    it("T4 EcoSpeed = 2.0", () => expect(engine("Kepler", 4, "EcoSpeed")).toBeCloseTo(2.0));
    it("T4 BalFuel = 0.6", () => expect(engine("Kepler", 4, "BalFuel")).toBeCloseTo(0.6));
    it("T4 BalSpeed = 3.5", () => expect(engine("Kepler", 4, "BalSpeed")).toBeCloseTo(3.5));
    it("T4 TurboFuel = 1.2", () => expect(engine("Kepler", 4, "TurboFuel")).toBeCloseTo(1.2));
    it("T4 TurboSpeed = 5.0", () => expect(engine("Kepler", 4, "TurboSpeed")).toBeCloseTo(5.0));
  });

  describe("Olympus (Mars — turbo-optimized)", () => {
    it("T2 FuelCap = 500", () => expect(engine("Olympus", 2, "FuelCap")).toBe(500));
    it("T2 EcoFuel = 1.0", () => expect(engine("Olympus", 2, "EcoFuel")).toBeCloseTo(1.0));
    it("T2 EcoSpeed = 1.1", () => expect(engine("Olympus", 2, "EcoSpeed")).toBeCloseTo(1.1));
    it("T2 BalFuel = 1.6", () => expect(engine("Olympus", 2, "BalFuel")).toBeCloseTo(1.6));
    it("T2 BalSpeed = 1.8", () => expect(engine("Olympus", 2, "BalSpeed")).toBeCloseTo(1.8));
    it("T2 TurboFuel = 2.4", () => expect(engine("Olympus", 2, "TurboFuel")).toBeCloseTo(2.4));
    it("T2 TurboSpeed = 3.5", () => expect(engine("Olympus", 2, "TurboSpeed")).toBeCloseTo(3.5));

    it("T3 FuelCap = 650", () => expect(engine("Olympus", 3, "FuelCap")).toBe(650));
    it("T3 EcoFuel = 0.7", () => expect(engine("Olympus", 3, "EcoFuel")).toBeCloseTo(0.7));
    it("T3 EcoSpeed = 1.3", () => expect(engine("Olympus", 3, "EcoSpeed")).toBeCloseTo(1.3));
    it("T3 BalFuel = 1.0", () => expect(engine("Olympus", 3, "BalFuel")).toBeCloseTo(1.0));
    it("T3 BalSpeed = 2.3", () => expect(engine("Olympus", 3, "BalSpeed")).toBeCloseTo(2.3));
    it("T3 TurboFuel = 1.3", () => expect(engine("Olympus", 3, "TurboFuel")).toBeCloseTo(1.3));
    it("T3 TurboSpeed = 4.5", () => expect(engine("Olympus", 3, "TurboSpeed")).toBeCloseTo(4.5));

    it("T4 FuelCap = 800", () => expect(engine("Olympus", 4, "FuelCap")).toBe(800));
    it("T4 EcoFuel = 0.4", () => expect(engine("Olympus", 4, "EcoFuel")).toBeCloseTo(0.4));
    it("T4 EcoSpeed = 1.8", () => expect(engine("Olympus", 4, "EcoSpeed")).toBeCloseTo(1.8));
    it("T4 BalFuel = 0.7", () => expect(engine("Olympus", 4, "BalFuel")).toBeCloseTo(0.7));
    it("T4 BalSpeed = 3.2", () => expect(engine("Olympus", 4, "BalSpeed")).toBeCloseTo(3.2));
    it("T4 TurboFuel = 0.8", () => expect(engine("Olympus", 4, "TurboFuel")).toBeCloseTo(0.8));
    it("T4 TurboSpeed = 5.5", () => expect(engine("Olympus", 4, "TurboSpeed")).toBeCloseTo(5.5));
  });

  describe("Huygens (Titan — eco-optimized)", () => {
    it("T2 FuelCap = 500", () => expect(engine("Huygens", 2, "FuelCap")).toBe(500));
    it("T2 EcoFuel = 0.6", () => expect(engine("Huygens", 2, "EcoFuel")).toBeCloseTo(0.6));
    it("T2 EcoSpeed = 1.2", () => expect(engine("Huygens", 2, "EcoSpeed")).toBeCloseTo(1.2));
    it("T2 BalFuel = 1.6", () => expect(engine("Huygens", 2, "BalFuel")).toBeCloseTo(1.6));
    it("T2 BalSpeed = 1.8", () => expect(engine("Huygens", 2, "BalSpeed")).toBeCloseTo(1.8));
    it("T2 TurboFuel = 3.5", () => expect(engine("Huygens", 2, "TurboFuel")).toBeCloseTo(3.5));
    it("T2 TurboSpeed = 2.7", () => expect(engine("Huygens", 2, "TurboSpeed")).toBeCloseTo(2.7));

    it("T3 FuelCap = 650", () => expect(engine("Huygens", 3, "FuelCap")).toBe(650));
    it("T3 EcoFuel = 0.4", () => expect(engine("Huygens", 3, "EcoFuel")).toBeCloseTo(0.4));
    it("T3 EcoSpeed = 1.8", () => expect(engine("Huygens", 3, "EcoSpeed")).toBeCloseTo(1.8));
    it("T3 BalFuel = 1.0", () => expect(engine("Huygens", 3, "BalFuel")).toBeCloseTo(1.0));
    it("T3 BalSpeed = 2.3", () => expect(engine("Huygens", 3, "BalSpeed")).toBeCloseTo(2.3));
    it("T3 TurboFuel = 2.2", () => expect(engine("Huygens", 3, "TurboFuel")).toBeCloseTo(2.2));
    it("T3 TurboSpeed = 3.5", () => expect(engine("Huygens", 3, "TurboSpeed")).toBeCloseTo(3.5));

    it("T4 FuelCap = 800", () => expect(engine("Huygens", 4, "FuelCap")).toBe(800));
    it("T4 EcoFuel = 0.2", () => expect(engine("Huygens", 4, "EcoFuel")).toBeCloseTo(0.2));
    it("T4 EcoSpeed = 2.3", () => expect(engine("Huygens", 4, "EcoSpeed")).toBeCloseTo(2.3));
    it("T4 BalFuel = 0.7", () => expect(engine("Huygens", 4, "BalFuel")).toBeCloseTo(0.7));
    it("T4 BalSpeed = 3.2", () => expect(engine("Huygens", 4, "BalSpeed")).toBeCloseTo(3.2));
    it("T4 TurboFuel = 1.5", () => expect(engine("Huygens", 4, "TurboFuel")).toBeCloseTo(1.5));
    it("T4 TurboSpeed = 4.5", () => expect(engine("Huygens", 4, "TurboSpeed")).toBeCloseTo(4.5));
  });

  // ── Tier progression (monotonicity) ───────────────────────────────────────

  describe("Tier progression", () => {
    const manufacturers = ["Kepler", "Olympus", "Huygens"];
    const fuelStats = ["EcoFuel", "BalFuel", "TurboFuel"];
    const speedStats = ["EcoSpeed", "BalSpeed", "TurboSpeed"];

    for (const mfg of manufacturers) {
      describe(mfg, () => {
        for (let tier = 2; tier <= 4; tier++) {
          describe(`T${tier - 1} → T${tier}`, () => {
            it("FuelCap increases", () => {
              expect(engine(mfg, tier, "FuelCap")).toBeGreaterThanOrEqual(
                engine(mfg, tier - 1, "FuelCap"),
              );
            });

            for (const stat of fuelStats) {
              it(`${stat} improves (lower)`, () => {
                expect(engine(mfg, tier, stat)).toBeLessThan(
                  engine(mfg, tier - 1, stat),
                );
              });
            }

            for (const stat of speedStats) {
              it(`${stat} improves (higher)`, () => {
                expect(engine(mfg, tier, stat)).toBeGreaterThan(
                  engine(mfg, tier - 1, stat),
                );
              });
            }
          });
        }
      });
    }
  });

  // ── Cross-manufacturer comparisons ────────────────────────────────────────

  describe("Manufacturer comparisons", () => {
    for (let tier = 2; tier <= 4; tier++) {
      describe(`Tier ${tier}`, () => {
        it("Kepler has best BalFuel (lowest)", () => {
          expect(engine("Kepler", tier, "BalFuel")).toBeLessThanOrEqual(
            engine("Olympus", tier, "BalFuel"),
          );
          expect(engine("Kepler", tier, "BalFuel")).toBeLessThanOrEqual(
            engine("Huygens", tier, "BalFuel"),
          );
        });

        it("Kepler has best BalSpeed (highest)", () => {
          expect(engine("Kepler", tier, "BalSpeed")).toBeGreaterThanOrEqual(
            engine("Olympus", tier, "BalSpeed"),
          );
          expect(engine("Kepler", tier, "BalSpeed")).toBeGreaterThanOrEqual(
            engine("Huygens", tier, "BalSpeed"),
          );
        });

        it("Olympus has best TurboFuel (lowest)", () => {
          expect(engine("Olympus", tier, "TurboFuel")).toBeLessThan(
            engine("Kepler", tier, "TurboFuel"),
          );
          expect(engine("Olympus", tier, "TurboFuel")).toBeLessThan(
            engine("Huygens", tier, "TurboFuel"),
          );
        });

        it("Olympus has best TurboSpeed (highest)", () => {
          expect(engine("Olympus", tier, "TurboSpeed")).toBeGreaterThan(
            engine("Kepler", tier, "TurboSpeed"),
          );
          expect(engine("Olympus", tier, "TurboSpeed")).toBeGreaterThan(
            engine("Huygens", tier, "TurboSpeed"),
          );
        });

        it("Huygens has best EcoFuel (lowest)", () => {
          expect(engine("Huygens", tier, "EcoFuel")).toBeLessThan(
            engine("Kepler", tier, "EcoFuel"),
          );
          expect(engine("Huygens", tier, "EcoFuel")).toBeLessThan(
            engine("Olympus", tier, "EcoFuel"),
          );
        });

        it("Huygens has best EcoSpeed (highest)", () => {
          expect(engine("Huygens", tier, "EcoSpeed")).toBeGreaterThan(
            engine("Kepler", tier, "EcoSpeed"),
          );
          expect(engine("Huygens", tier, "EcoSpeed")).toBeGreaterThan(
            engine("Olympus", tier, "EcoSpeed"),
          );
        });
      });
    }
  });

  // ── Prices ────────────────────────────────────────────────────────────────

  describe("EngPrice", () => {
    it("Tier 1 price = 0 (starter, not purchasable)", () => {
      expect(engine("Kepler", 1, "EngPrice")).toBe(0);
    });

    it("Tier 2 price = 1500 (same across all manufacturers)", () => {
      expect(engine("Kepler",  2, "EngPrice")).toBe(1500);
      expect(engine("Olympus", 2, "EngPrice")).toBe(1500);
      expect(engine("Huygens", 2, "EngPrice")).toBe(1500);
    });

    it("Tier 3 price = 2500 (same across all manufacturers)", () => {
      expect(engine("Kepler",  3, "EngPrice")).toBe(2500);
      expect(engine("Olympus", 3, "EngPrice")).toBe(2500);
      expect(engine("Huygens", 3, "EngPrice")).toBe(2500);
    });

    it("Tier 4 price = 4000 (same across all manufacturers)", () => {
      expect(engine("Kepler",  4, "EngPrice")).toBe(4000);
      expect(engine("Olympus", 4, "EngPrice")).toBe(4000);
      expect(engine("Huygens", 4, "EngPrice")).toBe(4000);
    });
  });
});

// ── manufacturer_available_here ───────────────────────────────────────────────

describe("manufacturer_available_here", () => {
  let story;
  beforeEach(() => { story = createStory(); });

  function availableAt(mfg, location) {
    story.variablesState["here"] = L(story, `AllLocations.${location}`);
    return story.EvaluateFunction("manufacturer_available_here", [
      L(story, `Manufacturers.${mfg}`),
    ]);
  }

  describe("Kepler (Earth, Luna, Ceres)", () => {
    it("available at Earth",    () => expect(availableAt("Kepler", "Earth")).toBe(true));
    it("available at Luna",     () => expect(availableAt("Kepler", "Luna")).toBe(true));
    it("available at Ceres",    () => expect(availableAt("Kepler", "Ceres")).toBe(true));
    it("not available at Mars", () => expect(availableAt("Kepler", "Mars")).toBe(false));
    it("not available at Ganymede", () => expect(availableAt("Kepler", "Ganymede")).toBe(false));
    it("not available at Titan",    () => expect(availableAt("Kepler", "Titan")).toBe(false));
  });

  describe("Olympus (Mars, Ceres)", () => {
    it("available at Mars",  () => expect(availableAt("Olympus", "Mars")).toBe(true));
    it("available at Ceres", () => expect(availableAt("Olympus", "Ceres")).toBe(true));
    it("not available at Earth",    () => expect(availableAt("Olympus", "Earth")).toBe(false));
    it("not available at Luna",     () => expect(availableAt("Olympus", "Luna")).toBe(false));
    it("not available at Ganymede", () => expect(availableAt("Olympus", "Ganymede")).toBe(false));
    it("not available at Titan",    () => expect(availableAt("Olympus", "Titan")).toBe(false));
  });

  describe("Huygens (Ganymede, Titan, Ceres)", () => {
    it("available at Ganymede", () => expect(availableAt("Huygens", "Ganymede")).toBe(true));
    it("available at Titan",    () => expect(availableAt("Huygens", "Titan")).toBe(true));
    it("available at Ceres",    () => expect(availableAt("Huygens", "Ceres")).toBe(true));
    it("not available at Earth", () => expect(availableAt("Huygens", "Earth")).toBe(false));
    it("not available at Luna",  () => expect(availableAt("Huygens", "Luna")).toBe(false));
    it("not available at Mars",  () => expect(availableAt("Huygens", "Mars")).toBe(false));
  });
});
