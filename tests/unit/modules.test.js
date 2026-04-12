/**
 * Unit tests for module system functions.
 *
 *   get_module_condition / set_module_condition
 *   is_module_active
 *   get_drone_capacity
 *   get_module_max_condition
 *   get_module_repair_cost
 *   ModuleData
 *   module_name
 *   install_module
 *   DroneBayTierName / DroneBayTierPrice
 */

import { describe, it, expect, beforeAll, beforeEach } from "vitest";
import { InkList } from "inkjs/full";
import { createStory, L } from "../helpers/story.js";

let story;

beforeAll(() => {
  story = createStory();
});

beforeEach(() => {
  story.ResetState();
});

describe("get_module_condition / set_module_condition", () => {
  it("returns 0 for uninstalled modules", () => {
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.DroneBay")])).toBe(0);
  });

  it("round-trips DroneBay condition", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.DroneBay"), 75]);
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.DroneBay")])).toBe(75);
  });

  it("round-trips AutoNav condition", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.AutoNav"), 80]);
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.AutoNav")])).toBe(80);
  });

  it("round-trips CargoMgmt condition", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.CargoMgmt"), 65]);
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.CargoMgmt")])).toBe(65);
  });

});

describe("is_module_active", () => {
  it("returns false when module is not installed", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.DroneBay"), 100]);
    expect(story.EvaluateFunction("is_module_active", [L(story, "ShipModules.DroneBay")])).toBe(false);
  });

  it("returns false when installed but condition below 50", () => {
    story.variablesState["InstalledModules"] = L(story, "ShipModules.DroneBay");
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.DroneBay"), 49]);
    expect(story.EvaluateFunction("is_module_active", [L(story, "ShipModules.DroneBay")])).toBe(false);
  });

  it("returns true when installed and condition is exactly 50", () => {
    story.variablesState["InstalledModules"] = L(story, "ShipModules.DroneBay");
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.DroneBay"), 50]);
    expect(story.EvaluateFunction("is_module_active", [L(story, "ShipModules.DroneBay")])).toBe(true);
  });

  it("returns true when installed and condition is 100", () => {
    story.variablesState["InstalledModules"] = L(story, "ShipModules.DroneBay");
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.DroneBay"), 100]);
    expect(story.EvaluateFunction("is_module_active", [L(story, "ShipModules.DroneBay")])).toBe(true);
  });
});

describe("get_drone_capacity", () => {
  it("returns 2 at 100% condition with tier 1 (1 drone × 2 per-drone)", () => {
    story.variablesState["DroneBayCondition"] = 100;
    story.variablesState["DroneBayTier"] = 1;
    expect(story.EvaluateFunction("get_drone_capacity")).toBe(2);
  });

  it("returns 2 at 75% condition threshold with tier 1", () => {
    story.variablesState["DroneBayCondition"] = 75;
    story.variablesState["DroneBayTier"] = 1;
    expect(story.EvaluateFunction("get_drone_capacity")).toBe(2);
  });

  it("returns 1 at 74% condition with tier 1", () => {
    story.variablesState["DroneBayCondition"] = 74;
    story.variablesState["DroneBayTier"] = 1;
    expect(story.EvaluateFunction("get_drone_capacity")).toBe(1);
  });

  it("returns 1 at 50% condition threshold with tier 1", () => {
    story.variablesState["DroneBayCondition"] = 50;
    story.variablesState["DroneBayTier"] = 1;
    expect(story.EvaluateFunction("get_drone_capacity")).toBe(1);
  });

  it("returns 0 at 49% condition (offline)", () => {
    story.variablesState["DroneBayCondition"] = 49;
    story.variablesState["DroneBayTier"] = 1;
    expect(story.EvaluateFunction("get_drone_capacity")).toBe(0);
  });

  it("returns 0 when not installed (tier 0)", () => {
    story.variablesState["DroneBayCondition"] = 0;
    story.variablesState["DroneBayTier"] = 0;
    expect(story.EvaluateFunction("get_drone_capacity")).toBe(0);
  });

  it("returns 4 at 100% condition with tier 2 (2 drones × 2 per-drone)", () => {
    story.variablesState["DroneBayCondition"] = 100;
    story.variablesState["DroneBayTier"] = 2;
    expect(story.EvaluateFunction("get_drone_capacity")).toBe(4);
  });

  it("returns 2 at 50-74% condition with tier 2", () => {
    story.variablesState["DroneBayCondition"] = 60;
    story.variablesState["DroneBayTier"] = 2;
    expect(story.EvaluateFunction("get_drone_capacity")).toBe(2);
  });
});

describe("get_module_max_condition", () => {
  it("returns 100 for all modules", () => {
    expect(story.EvaluateFunction("get_module_max_condition", [L(story, "ShipModules.DroneBay")])).toBe(100);
    expect(story.EvaluateFunction("get_module_max_condition", [L(story, "ShipModules.AutoNav")])).toBe(100);
  });
});

describe("get_module_repair_cost", () => {
  it("returns correct cost for DroneBay at 50%", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.DroneBay"), 50]);
    // (100 - 50) * 600 / 100 = 300
    expect(story.EvaluateFunction("get_module_repair_cost", [L(story, "ShipModules.DroneBay")])).toBe(300);
  });

  it("returns 0 when module is at max condition", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.DroneBay"), 100]);
    expect(story.EvaluateFunction("get_module_repair_cost", [L(story, "ShipModules.DroneBay")])).toBe(0);
  });
});

describe("ModuleData", () => {
  it("returns correct price for DroneBay", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.DroneBay"), L(story, "ModuleStats.ModPrice")])).toBe(600);
  });

  it("returns correct name for DroneBay", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.DroneBay"), L(story, "ModuleStats.ModName")])).toBe("Drone Bay");
  });

  it("returns correct price for AutoNav", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.AutoNav"), L(story, "ModuleStats.ModPrice")])).toBe(500);
  });

  it("returns correct price for CargoMgmt", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.CargoMgmt"), L(story, "ModuleStats.ModPrice")])).toBe(700);
  });

  it("returns correct name for AutoNav", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.AutoNav"), L(story, "ModuleStats.ModName")])).toBe("Auto-Nav Computer");
  });
});

describe("module_name", () => {
  it("returns the display name for DroneBay", () => {
    expect(story.EvaluateFunction("module_name", [L(story, "ShipModules.DroneBay")])).toBe("Drone Bay");
  });
});

describe("install_module", () => {
  it("adds module to InstalledModules and sets condition", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.DroneBay"), 100]);
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.DroneBay")])).toBe(100);
    expect(story.EvaluateFunction("is_module_active", [L(story, "ShipModules.DroneBay")])).toBe(true);
  });
});

describe("DroneBayTierName", () => {
  it("returns Single Drone for tier 1", () => {
    expect(story.EvaluateFunction("DroneBayTierName", [1])).toBe("Single Drone");
  });

  it("returns Dual Drones for tier 2", () => {
    expect(story.EvaluateFunction("DroneBayTierName", [2])).toBe("Dual Drones");
  });

  it("returns None for tier 0", () => {
    expect(story.EvaluateFunction("DroneBayTierName", [0])).toBe("None");
  });
});

describe("DroneBayTierPrice", () => {
  it("returns 600 for tier 1", () => {
    expect(story.EvaluateFunction("DroneBayTierPrice", [1])).toBe(600);
  });

  it("returns 1000 for tier 2", () => {
    expect(story.EvaluateFunction("DroneBayTierPrice", [2])).toBe(1000);
  });

  it("upgrade T1→T2 costs 400 (delta)", () => {
    const t1 = story.EvaluateFunction("DroneBayTierPrice", [1]);
    const t2 = story.EvaluateFunction("DroneBayTierPrice", [2]);
    expect(t2 - t1).toBe(400);
  });
});

describe("has_damaged_modules", () => {
  it("returns false when no modules are installed", () => {
    expect(story.EvaluateFunction("has_damaged_modules")).toBe(false);
  });

  it("returns false when all installed modules are at max condition", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.DroneBay"), 100]);
    expect(story.EvaluateFunction("has_damaged_modules")).toBe(false);
  });

  it("returns true when an installed module is below max condition", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.DroneBay"), 80]);
    expect(story.EvaluateFunction("has_damaged_modules")).toBe(true);
  });
});
