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
 */

import { describe, it, expect, beforeEach } from "vitest";
import { InkList } from "inkjs/full";
import { createStory, L } from "../helpers/story.js";

let story;

beforeEach(() => {
  story = createStory();
});

describe("get_module_condition / set_module_condition", () => {
  it("returns 0 for uninstalled modules", () => {
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.RepairDrones")])).toBe(0);
  });

  it("round-trips RepairDrones condition", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 75]);
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.RepairDrones")])).toBe(75);
  });

  it("round-trips CleaningDrones condition", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.CleaningDrones"), 60]);
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.CleaningDrones")])).toBe(60);
  });

  it("round-trips AutoNav condition", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.AutoNav"), 80]);
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.AutoNav")])).toBe(80);
  });

  it("round-trips CargoMgmt condition", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.CargoMgmt"), 65]);
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.CargoMgmt")])).toBe(65);
  });

  it("round-trips Entertainment condition", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.Entertainment"), 90]);
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.Entertainment")])).toBe(90);
  });

  it("round-trips WellnessSuite condition", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.WellnessSuite"), 55]);
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.WellnessSuite")])).toBe(55);
  });
});

describe("is_module_active", () => {
  it("returns false when module is not installed", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 100]);
    expect(story.EvaluateFunction("is_module_active", [L(story, "ShipModules.RepairDrones")])).toBe(false);
  });

  it("returns false when installed but condition below 50", () => {
    story.variablesState["InstalledModules"] = L(story, "ShipModules.RepairDrones");
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 49]);
    expect(story.EvaluateFunction("is_module_active", [L(story, "ShipModules.RepairDrones")])).toBe(false);
  });

  it("returns true when installed and condition is exactly 50", () => {
    story.variablesState["InstalledModules"] = L(story, "ShipModules.RepairDrones");
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 50]);
    expect(story.EvaluateFunction("is_module_active", [L(story, "ShipModules.RepairDrones")])).toBe(true);
  });

  it("returns true when installed and condition is 100", () => {
    story.variablesState["InstalledModules"] = L(story, "ShipModules.RepairDrones");
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 100]);
    expect(story.EvaluateFunction("is_module_active", [L(story, "ShipModules.RepairDrones")])).toBe(true);
  });
});

describe("get_drone_capacity", () => {
  it("returns 2 at 100% condition", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 100]);
    expect(story.EvaluateFunction("get_drone_capacity", [L(story, "ShipModules.RepairDrones")])).toBe(2);
  });

  it("returns 2 at 75% condition (threshold)", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 75]);
    expect(story.EvaluateFunction("get_drone_capacity", [L(story, "ShipModules.RepairDrones")])).toBe(2);
  });

  it("returns 1 at 74% condition", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 74]);
    expect(story.EvaluateFunction("get_drone_capacity", [L(story, "ShipModules.RepairDrones")])).toBe(1);
  });

  it("returns 1 at 50% condition (threshold)", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 50]);
    expect(story.EvaluateFunction("get_drone_capacity", [L(story, "ShipModules.RepairDrones")])).toBe(1);
  });

  it("returns 0 at 49% condition (offline)", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 49]);
    expect(story.EvaluateFunction("get_drone_capacity", [L(story, "ShipModules.RepairDrones")])).toBe(0);
  });

  it("returns 0 at 0% condition (not installed)", () => {
    expect(story.EvaluateFunction("get_drone_capacity", [L(story, "ShipModules.RepairDrones")])).toBe(0);
  });
});

describe("get_module_max_condition", () => {
  it("returns 100 for new modules", () => {
    expect(story.EvaluateFunction("get_module_max_condition", [L(story, "ShipModules.RepairDrones")])).toBe(100);
  });

  it("returns 80 for refurbished modules", () => {
    story.variablesState["RefurbishedModules"] = L(story, "ShipModules.RepairDrones");
    expect(story.EvaluateFunction("get_module_max_condition", [L(story, "ShipModules.RepairDrones")])).toBe(80);
  });
});

describe("get_module_repair_cost", () => {
  it("returns correct cost for new RepairDrones at 50%", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 50]);
    // (100 - 50) * 800 / 100 = 400
    expect(story.EvaluateFunction("get_module_repair_cost", [L(story, "ShipModules.RepairDrones")])).toBe(400);
  });

  it("returns correct cost for refurbished RepairDrones at 60%", () => {
    story.variablesState["RefurbishedModules"] = L(story, "ShipModules.RepairDrones");
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 60]);
    // (80 - 60) * 800 / 100 = 160
    expect(story.EvaluateFunction("get_module_repair_cost", [L(story, "ShipModules.RepairDrones")])).toBe(160);
  });

  it("returns 0 when module is at max condition", () => {
    story.EvaluateFunction("set_module_condition", [L(story, "ShipModules.RepairDrones"), 100]);
    expect(story.EvaluateFunction("get_module_repair_cost", [L(story, "ShipModules.RepairDrones")])).toBe(0);
  });
});

describe("ModuleData", () => {
  it("returns correct price for RepairDrones", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.RepairDrones"), L(story, "ModuleStats.ModPrice")])).toBe(800);
  });

  it("returns correct price for CleaningDrones", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.CleaningDrones"), L(story, "ModuleStats.ModPrice")])).toBe(600);
  });

  it("returns correct name for RepairDrones", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.RepairDrones"), L(story, "ModuleStats.ModName")])).toBe("Repair Drones");
  });

  it("returns correct name for CleaningDrones", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.CleaningDrones"), L(story, "ModuleStats.ModName")])).toBe("Cleaning Drones");
  });

  it("returns correct price for AutoNav", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.AutoNav"), L(story, "ModuleStats.ModPrice")])).toBe(500);
  });

  it("returns correct price for CargoMgmt", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.CargoMgmt"), L(story, "ModuleStats.ModPrice")])).toBe(700);
  });

  it("returns correct price for Entertainment", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.Entertainment"), L(story, "ModuleStats.ModPrice")])).toBe(400);
  });

  it("returns correct price for WellnessSuite", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.WellnessSuite"), L(story, "ModuleStats.ModPrice")])).toBe(500);
  });

  it("returns correct name for AutoNav", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.AutoNav"), L(story, "ModuleStats.ModName")])).toBe("Auto-Nav Computer");
  });

  it("returns correct name for WellnessSuite", () => {
    expect(story.EvaluateFunction("ModuleData", [L(story, "ShipModules.WellnessSuite"), L(story, "ModuleStats.ModName")])).toBe("Wellness Suite");
  });
});

describe("module_name", () => {
  it("returns the display name for a module", () => {
    expect(story.EvaluateFunction("module_name", [L(story, "ShipModules.RepairDrones")])).toBe("Repair Drones");
  });
});

describe("install_module", () => {
  it("adds module to InstalledModules and sets condition", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.RepairDrones"), 100]);
    expect(story.EvaluateFunction("get_module_condition", [L(story, "ShipModules.RepairDrones")])).toBe(100);
    expect(story.EvaluateFunction("is_module_active", [L(story, "ShipModules.RepairDrones")])).toBe(true);
  });
});

describe("has_medical_module", () => {
  it("returns false when WellnessSuite not installed", () => {
    expect(story.EvaluateFunction("has_medical_module")).toBe(false);
  });

  it("returns false when WellnessSuite installed but below 50%", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.WellnessSuite"), 49]);
    expect(story.EvaluateFunction("has_medical_module")).toBe(false);
  });

  it("returns true when WellnessSuite installed and active (50%+)", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.WellnessSuite"), 50]);
    expect(story.EvaluateFunction("has_medical_module")).toBe(true);
  });

  it("returns true when WellnessSuite installed at full condition", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.WellnessSuite"), 100]);
    expect(story.EvaluateFunction("has_medical_module")).toBe(true);
  });
});

describe("apply_recreation_bonus", () => {
  it("returns base boost when Entertainment not installed", () => {
    expect(story.EvaluateFunction("apply_recreation_bonus", [10])).toBe(10);
  });

  it("returns base boost when Entertainment installed but below 75%", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.Entertainment"), 74]);
    expect(story.EvaluateFunction("apply_recreation_bonus", [10])).toBe(10);
  });

  it("returns +50% bonus when Entertainment is at 75%+", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.Entertainment"), 75]);
    // 10 + 10/2 = 15
    expect(story.EvaluateFunction("apply_recreation_bonus", [10])).toBe(15);
  });

  it("applies integer truncation correctly for odd base values", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.Entertainment"), 100]);
    // 3 + 3/2 = 3 + 1 = 4 (integer division)
    expect(story.EvaluateFunction("apply_recreation_bonus", [3])).toBe(4);
    // 5 + 5/2 = 5 + 2 = 7
    expect(story.EvaluateFunction("apply_recreation_bonus", [5])).toBe(7);
    // 8 + 8/2 = 8 + 4 = 12
    expect(story.EvaluateFunction("apply_recreation_bonus", [8])).toBe(12);
    // 15 + 15/2 = 15 + 7 = 22
    expect(story.EvaluateFunction("apply_recreation_bonus", [15])).toBe(22);
  });
});
