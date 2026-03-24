/**
 * Unit tests for cargo functions.
 *
 * Cargo data reference (from cargo.ink):
 *   001_Plums:   Earth→Luna,     mass=10, Express=1
 *   002_Fish:    Earth→Luna,     mass=20, Express=1
 *   003_Water:   Earth→Mars,     mass=40
 *   004_Seafood: Earth→Mars,     mass=20, Express=1
 *   101_Helium:  Luna→Earth,     mass=20
 *   303_Samples: Ceres→Luna,     mass=10, Fragile=1
 *   304_Colonists: Ceres→Mars,   mass=10, Passengers=1
 *   404_Team:    Ganymede→Ceres, mass=10, Passengers=1
 *   501_Methane: Titan→Ganymede, mass=40, Hazardous=1
 *   503_Samples: Titan→Mars,     mass=10, Fragile=1
 *
 * Pay formula: base = FLOOR(mass × distance × PayRate)
 *              +50% of base per flag (Express / Fragile / Hazardous / Passengers)
 * PayRate = 3 (default from space-truckers.ink)
 */

import { describe, it, expect, beforeAll } from "vitest";
import { InkList } from "inkjs/full";
import { createStory, L, cargo } from "../helpers/story.js";

let story;

beforeAll(() => {
  story = createStory();
});

function cargoField(id, field) {
  return story.EvaluateFunction("CargoData", [
    L(story, `AllCargo.${id}`),
    L(story, `CargoStats.${field}`),
  ]);
}

describe("CargoData lookups", () => {
  it("001_Plums: mass=10, Express=1, Fragile=0, Hazardous=0, Passengers=0", () => {
    expect(cargoField("001_Plums", "Mass")).toBe(10);
    expect(cargoField("001_Plums", "Express")).toBe(1);
    expect(cargoField("001_Plums", "Fragile")).toBe(0);
    expect(cargoField("001_Plums", "Hazardous")).toBe(0);
    expect(cargoField("001_Plums", "Passengers")).toBe(0);
  });

  it("003_Water: mass=40, no flags", () => {
    expect(cargoField("003_Water", "Mass")).toBe(40);
    expect(cargoField("003_Water", "Express")).toBe(0);
    expect(cargoField("003_Water", "Fragile")).toBe(0);
    expect(cargoField("003_Water", "Hazardous")).toBe(0);
    expect(cargoField("003_Water", "Passengers")).toBe(0);
  });

  it("303_Samples: mass=10, Fragile=1", () => {
    expect(cargoField("303_Samples", "Mass")).toBe(10);
    expect(cargoField("303_Samples", "Fragile")).toBe(1);
    expect(cargoField("303_Samples", "Express")).toBe(0);
    expect(cargoField("303_Samples", "Hazardous")).toBe(0);
    expect(cargoField("303_Samples", "Passengers")).toBe(0);
  });

  it("304_Colonists: mass=10, Passengers=1", () => {
    expect(cargoField("304_Colonists", "Mass")).toBe(10);
    expect(cargoField("304_Colonists", "Passengers")).toBe(1);
    expect(cargoField("304_Colonists", "Express")).toBe(0);
  });

  it("501_Methane: mass=40, Hazardous=1", () => {
    expect(cargoField("501_Methane", "Mass")).toBe(40);
    expect(cargoField("501_Methane", "Hazardous")).toBe(1);
    expect(cargoField("501_Methane", "Express")).toBe(0);
    expect(cargoField("501_Methane", "Fragile")).toBe(0);
  });
});

describe("total_mass", () => {
  it("empty list = 0", () => {
    const result = story.EvaluateFunction("total_mass", [new InkList()]);
    expect(result).toBe(0);
  });

  it("single item: 001_Plums = 10", () => {
    const result = story.EvaluateFunction("total_mass", [L(story, "AllCargo.001_Plums")]);
    expect(result).toBe(10);
  });

  it("single item: 003_Water = 40", () => {
    const result = story.EvaluateFunction("total_mass", [L(story, "AllCargo.003_Water")]);
    expect(result).toBe(40);
  });

  it("two items: 001_Plums (10) + 003_Water (40) = 50", () => {
    const items = cargo(story, "AllCargo.001_Plums", "AllCargo.003_Water");
    expect(story.EvaluateFunction("total_mass", [items])).toBe(50);
  });

  it("three items: 001_Plums (10) + 002_Fish (20) + 003_Water (40) = 70", () => {
    const items = cargo(story, "AllCargo.001_Plums", "AllCargo.002_Fish", "AllCargo.003_Water");
    expect(story.EvaluateFunction("total_mass", [items])).toBe(70);
  });

  it("two heavy items: 501_Methane (40) + 003_Water (40) = 80", () => {
    const items = cargo(story, "AllCargo.501_Methane", "AllCargo.003_Water");
    expect(story.EvaluateFunction("total_mass", [items])).toBe(80);
  });
});

describe("get_cargo_pay", () => {
  // base_pay = FLOOR(mass × distance × 3)

  it("plain cargo (003_Water, mass=40, dist=14): FLOOR(40×14×3)=1680", () => {
    const pay = story.EvaluateFunction("get_cargo_pay", [L(story, "AllCargo.003_Water"), 14]);
    expect(pay).toBe(1680);
  });

  it("express cargo (001_Plums, mass=10, dist=5): base=150, +50%=225", () => {
    // FLOOR(10×5×3)=150, +50%=225
    const pay = story.EvaluateFunction("get_cargo_pay", [L(story, "AllCargo.001_Plums"), 5]);
    expect(pay).toBe(225);
  });

  it("express cargo (002_Fish, mass=20, dist=5): base=300, +50%=450", () => {
    const pay = story.EvaluateFunction("get_cargo_pay", [L(story, "AllCargo.002_Fish"), 5]);
    expect(pay).toBe(450);
  });

  it("fragile cargo (303_Samples, mass=10, dist=18): base=540, +50%=810", () => {
    // Ceres→Luna dist=18
    const pay = story.EvaluateFunction("get_cargo_pay", [L(story, "AllCargo.303_Samples"), 18]);
    expect(pay).toBe(810);
  });

  it("passengers (304_Colonists, mass=10, dist=10): base=300, +50%=450", () => {
    // Ceres→Mars dist=10
    const pay = story.EvaluateFunction("get_cargo_pay", [L(story, "AllCargo.304_Colonists"), 10]);
    expect(pay).toBe(450);
  });

  it("hazardous (501_Methane, mass=40, dist=16): base=1920, +50%=2880", () => {
    // Titan→Ganymede dist=16
    const pay = story.EvaluateFunction("get_cargo_pay", [L(story, "AllCargo.501_Methane"), 16]);
    expect(pay).toBe(2880);
  });

  it("pay scales with distance", () => {
    const payShort = story.EvaluateFunction("get_cargo_pay", [L(story, "AllCargo.003_Water"), 5]);
    const payLong = story.EvaluateFunction("get_cargo_pay", [L(story, "AllCargo.003_Water"), 52]);
    expect(payLong).toBeGreaterThan(payShort);
  });
});

describe("cargo_has_express", () => {
  it("returns true for a single express item (001_Plums)", () => {
    const result = story.EvaluateFunction("cargo_has_express", [L(story, "AllCargo.001_Plums")]);
    expect(result).toBe(true);
  });

  it("returns false for a single non-express item (003_Water)", () => {
    const result = story.EvaluateFunction("cargo_has_express", [L(story, "AllCargo.003_Water")]);
    expect(result).toBe(false);
  });

  it("returns true when mixed hold contains at least one express item", () => {
    const items = cargo(story, "AllCargo.003_Water", "AllCargo.001_Plums");
    const result = story.EvaluateFunction("cargo_has_express", [items]);
    expect(result).toBe(true);
  });

  it("returns false for empty hold", () => {
    const result = story.EvaluateFunction("cargo_has_express", [new InkList()]);
    expect(result).toBe(false);
  });
});

describe("cargo_blocks_turbo", () => {
  it("returns true for fragile cargo (303_Samples)", () => {
    const result = story.EvaluateFunction("cargo_blocks_turbo", [L(story, "AllCargo.303_Samples")]);
    expect(result).toBe(true);
  });

  it("returns true for passengers (304_Colonists)", () => {
    const result = story.EvaluateFunction("cargo_blocks_turbo", [L(story, "AllCargo.304_Colonists")]);
    expect(result).toBe(true);
  });

  it("returns false for plain cargo (003_Water)", () => {
    const result = story.EvaluateFunction("cargo_blocks_turbo", [L(story, "AllCargo.003_Water")]);
    expect(result).toBe(false);
  });

  it("returns false for hazardous cargo (501_Methane) — hazardous is not a turbo blocker", () => {
    const result = story.EvaluateFunction("cargo_blocks_turbo", [L(story, "AllCargo.501_Methane")]);
    expect(result).toBe(false);
  });

  it("returns true when hold contains at least one fragile item alongside plain cargo", () => {
    const items = cargo(story, "AllCargo.003_Water", "AllCargo.303_Samples");
    const result = story.EvaluateFunction("cargo_blocks_turbo", [items]);
    expect(result).toBe(true);
  });

  it("returns false for empty hold", () => {
    const result = story.EvaluateFunction("cargo_blocks_turbo", [new InkList()]);
    expect(result).toBe(false);
  });
});

describe("cargo_is_mixed_hazardous", () => {
  it("returns false for a single hazardous item only", () => {
    const result = story.EvaluateFunction("cargo_is_mixed_hazardous", [L(story, "AllCargo.501_Methane")]);
    expect(result).toBe(false);
  });

  it("returns false for a single clean item only", () => {
    const result = story.EvaluateFunction("cargo_is_mixed_hazardous", [L(story, "AllCargo.003_Water")]);
    expect(result).toBe(false);
  });

  it("returns true when hold has both hazardous and non-hazardous cargo", () => {
    const items = cargo(story, "AllCargo.501_Methane", "AllCargo.003_Water");
    const result = story.EvaluateFunction("cargo_is_mixed_hazardous", [items]);
    expect(result).toBe(true);
  });

  it("returns false for empty hold", () => {
    const result = story.EvaluateFunction("cargo_is_mixed_hazardous", [new InkList()]);
    expect(result).toBe(false);
  });
});

describe("cargo_express_destination", () => {
  it("returns None for hold with no express cargo", () => {
    const result = story.EvaluateFunction("cargo_express_destination", [L(story, "AllCargo.003_Water")]);
    // None is a list item in AllLocations, not an empty list
    expect(result.Equals(L(story, "AllLocations.None"))).toBe(true);
  });

  it("returns Luna when all express cargo is bound for Luna (001_Plums + 002_Fish)", () => {
    const items = cargo(story, "AllCargo.001_Plums", "AllCargo.002_Fish");
    const result = story.EvaluateFunction("cargo_express_destination", [items]);
    const lunaList = L(story, "AllLocations.Luna");
    expect(result.Equals(lunaList)).toBe(true);
  });

  it("returns None when express cargo has conflicting destinations", () => {
    // 001_Plums → Luna (express), 004_Seafood → Mars (express)
    const items = cargo(story, "AllCargo.001_Plums", "AllCargo.004_Seafood");
    const result = story.EvaluateFunction("cargo_express_destination", [items]);
    expect(result.Equals(L(story, "AllLocations.None"))).toBe(true);
  });
});

describe("count_paperwork_chunks", () => {
  it("returns 1 (base chunk) for empty cargo", () => {
    const result = story.EvaluateFunction("count_paperwork_chunks", [new InkList()]);
    expect(result).toBe(1);
  });

  it("returns 1 (base chunk) for unflagged cargo only", () => {
    const items = cargo(story, "AllCargo.003_Water", "AllCargo.101_Helium");
    const result = story.EvaluateFunction("count_paperwork_chunks", [items]);
    expect(result).toBe(1);
  });

  it("returns 2 for one hazardous item (base + 1 flagged)", () => {
    const result = story.EvaluateFunction("count_paperwork_chunks", [L(story, "AllCargo.501_Methane")]);
    expect(result).toBe(2);
  });

  it("returns 2 for one passenger item (base + 1 flagged)", () => {
    const result = story.EvaluateFunction("count_paperwork_chunks", [L(story, "AllCargo.304_Colonists")]);
    expect(result).toBe(2);
  });

  it("returns 2 for one express item (base + 1 flagged)", () => {
    const result = story.EvaluateFunction("count_paperwork_chunks", [L(story, "AllCargo.001_Plums")]);
    expect(result).toBe(2);
  });

  it("returns 3 for two flagged items among unflagged cargo", () => {
    // 003_Water (plain) + 501_Methane (hazardous) + 304_Colonists (passengers)
    const items = cargo(story, "AllCargo.003_Water", "AllCargo.501_Methane", "AllCargo.304_Colonists");
    const result = story.EvaluateFunction("count_paperwork_chunks", [items]);
    expect(result).toBe(3);
  });
});

describe("get_paperwork_penalty_pct", () => {
  // Formula: MIN(missing × 10, 50) where missing = total - done
  // 10% per missing chunk, capped at 50%

  function penaltyPct(done, total) {
    return story.EvaluateFunction("get_paperwork_penalty_pct", [done, total]);
  }

  it("returns 0 when all paperwork is done", () => {
    expect(penaltyPct(3, 3)).toBe(0);
  });

  it("returns 0 when done exceeds total", () => {
    expect(penaltyPct(5, 3)).toBe(0);
  });

  it("returns 10 for 1 missing chunk", () => {
    expect(penaltyPct(2, 3)).toBe(10);
  });

  it("returns 20 for 2 missing chunks", () => {
    expect(penaltyPct(1, 3)).toBe(20);
  });

  it("returns 30 for 3 missing chunks", () => {
    expect(penaltyPct(0, 3)).toBe(30);
  });

  it("caps at 50 for 5+ missing chunks", () => {
    expect(penaltyPct(0, 6)).toBe(50);
  });

  it("returns 0 when total is 0 (no paperwork)", () => {
    expect(penaltyPct(0, 0)).toBe(0);
  });
});

describe("can_turbo_to", () => {
  // Tier 1: TurboFuel=4.0, FuelCap=300, ship mass=5 (no cargo)
  // Cost formula: FLOOR(distance × mass × fuel_factor)
  // Earth→Luna:  dist=5,  cost=FLOOR(5×5×4)=100  → within 300 ✓
  // Earth→Mars:  dist=14, cost=FLOOR(14×5×4)=280 → within 300 ✓
  // Earth→Ceres: dist=22, cost=FLOOR(22×5×4)=440 → exceeds 300 ✗

  it("returns true for a nearby destination (Luna) at default engine tier and capacity", () => {
    const result = story.EvaluateFunction("can_turbo_to", [L(story, "AllLocations.Luna")]);
    expect(result).toBe(true);
  });

  it("returns true for a mid-range destination (Mars) at default engine tier and capacity", () => {
    // 14×5×4 = 280 ≤ 300
    const result = story.EvaluateFunction("can_turbo_to", [L(story, "AllLocations.Mars")]);
    expect(result).toBe(true);
  });

  it("returns false for a distant destination (Ceres) that exceeds fuel capacity", () => {
    // 22×5×4 = 440 > 300
    const result = story.EvaluateFunction("can_turbo_to", [L(story, "AllLocations.Ceres")]);
    expect(result).toBe(false);
  });

  it("returns false when fuel capacity is reduced below the cost to Luna", () => {
    // Luna requires 100; set cap to 50
    story.variablesState["ShipFuelCapacity"] = 50;
    const result = story.EvaluateFunction("can_turbo_to", [L(story, "AllLocations.Luna")]);
    story.variablesState["ShipFuelCapacity"] = 300; // restore
    expect(result).toBe(false);
  });
});
