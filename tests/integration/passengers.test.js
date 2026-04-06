/**
 * Integration tests for the passenger module and satisfaction system.
 *
 * - Cargo gating: passenger cargo not available without module
 * - Satisfaction: task completion boost (+5/+7), skip penalty (-3), passive bonus
 * - Delivery payoff: +10% bonus / -10% penalty on passenger cargo
 * - Module purchase: passenger module appears in upgrade menu, not browse modules
 *
 * Delivery tests use 031_Diplomats (Earth→Luna, passengers) with here=Luna.
 * Passive bonus tests trigger next_day by spending AP=1 on a workout.
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
    throw new Error(`Choice not found: "${text}"\nAvailable: ${choiceTexts(story).join(", ")}`);
  story.ChooseChoiceIndex(idx);
  drainText(story);
}

/**
 * Set up a story in transit state at ship_options.
 * AP=1 so that spending 1 AP on any task triggers next_day.
 */
function setupTransit(overrides = {}) {
  const s = createStory();
  s.variablesState["ShipCargo"] = new InkList();

  const defaults = {
    ShipClock: 5,
    ShipDestination: L(s, "AllLocations.Mars"),
    TripDuration: 10,
    TripDay: 3,
    FlipDone: true,
    FlightMode: L(s, "FlightModes.Bal"),
    PaperworkDone: 1,
    PaperworkTotal: 1,
    TripFuelCost: 100,
    TripFuelPenalty: 0,
    NavCheckDueDay: 99,
    NavPenaltyPct: 0,
    CargoCheckDueDay: 99,
    CargoCheckPenaltyPct: 0,
    AP: 1, // 1 AP so next action triggers next_day
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
    s.variablesState[key] = value;
  }
  return s;
}

describe("Cargo gating", () => {
  let story;
  beforeEach(() => {
    story = createStory();
    // Use large fuel capacity so the fuel-range check never blocks these tests
    story.variablesState["ShipFuelCapacity"] = 2000;
  });

  it("passenger cargo is unavailable without the passenger module", () => {
    // 052_Scientists: Earth→Mars, passengers=1
    const available = story.EvaluateFunction(
      "cargo_is_available",
      [L(story, "AllCargo.052_Scientists"), L(story, "AllLocations.Earth")]
    );
    expect(available).toBe(false);
  });

  it("passenger cargo is available with the passenger module installed", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.PassengerModule"), 100]);
    story.variablesState["PassengerModuleTier"] = 1;
    const available = story.EvaluateFunction(
      "cargo_is_available",
      [L(story, "AllCargo.052_Scientists"), L(story, "AllLocations.Earth")]
    );
    expect(available).toBe(true);
  });

  it("non-passenger cargo is available without the passenger module", () => {
    // 003_Water: Earth→Mars, no flags
    const available = story.EvaluateFunction(
      "cargo_is_available",
      [L(story, "AllCargo.003_Water"), L(story, "AllLocations.Earth")]
    );
    expect(available).toBe(true);
  });
});

describe("Satisfaction — task completion", () => {
  it("completing the passenger task boosts satisfaction by +5 at tier 1", () => {
    const s = setupTransit({ AP: 6 });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.PassengerModule"), 100]);
    s.variablesState["PassengerModuleTier"] = 1;
    s.variablesState["PassengerSatisfaction"] = 50;
    s.variablesState["DailyPassengerTask"] = L(s, "PassengerTasks.PaxShower");
    s.variablesState["PassengerTaskCompleted"] = false;
    // Passenger cargo required for task choice to appear
    s.variablesState["ShipCargo"] = L(s, "AllCargo.052_Scientists");

    s.ChoosePathString("transit.ship_options");
    drainText(s);
    pickChoice(s, "Check on passengers");

    expect(s.variablesState["PassengerSatisfaction"]).toBe(55);
    expect(s.variablesState["PassengerTaskCompleted"]).toBe(true);
  });

  it("completing the passenger task boosts satisfaction by +7 at tier 3", () => {
    const s = setupTransit({ AP: 6 });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.PassengerModule"), 100]);
    s.variablesState["PassengerModuleTier"] = 3;
    s.variablesState["PassengerSatisfaction"] = 50;
    s.variablesState["DailyPassengerTask"] = L(s, "PassengerTasks.PaxCocktails");
    s.variablesState["PassengerTaskCompleted"] = false;
    s.variablesState["ShipCargo"] = L(s, "AllCargo.052_Scientists");

    s.ChoosePathString("transit.ship_options");
    drainText(s);
    pickChoice(s, "Check on passengers");

    expect(s.variablesState["PassengerSatisfaction"]).toBe(57);
  });

  it("satisfaction is capped at 100 on task completion", () => {
    const s = setupTransit({ AP: 6 });
    s.EvaluateFunction("install_module", [L(s, "ShipModules.PassengerModule"), 100]);
    s.variablesState["PassengerModuleTier"] = 1;
    s.variablesState["PassengerSatisfaction"] = 98;
    s.variablesState["DailyPassengerTask"] = L(s, "PassengerTasks.PaxShower");
    s.variablesState["PassengerTaskCompleted"] = false;
    s.variablesState["ShipCargo"] = L(s, "AllCargo.052_Scientists");

    s.ChoosePathString("transit.ship_options");
    drainText(s);
    pickChoice(s, "Check on passengers");

    expect(s.variablesState["PassengerSatisfaction"]).toBe(100);
  });
});

describe("Satisfaction — skip penalty and passive bonus from next_day", () => {
  /**
   * Trigger next_day by spending the only remaining AP on a quick workout.
   * Sets up AP=1 so the workout consumes all AP, triggering next_day.
   */
  function triggerNextDay(s) {
    s.ChoosePathString("transit.ship_options");
    drainText(s);
    pickChoice(s, "Take a break");
    pickChoice(s, "Quick workout"); // 1 AP → AP=0 → next_day fires
  }

  it("skipping the daily task applies -3 satisfaction penalty", () => {
    const s = setupTransit(); // AP=1
    s.EvaluateFunction("install_module", [L(s, "ShipModules.PassengerModule"), 100]);
    s.variablesState["PassengerModuleTier"] = 1;
    s.variablesState["PassengerSatisfaction"] = 50;
    s.variablesState["DailyPassengerTask"] = L(s, "PassengerTasks.PaxShower"); // task was offered
    s.variablesState["PassengerTaskCompleted"] = false; // not completed → skip penalty
    s.variablesState["ShipCargo"] = L(s, "AllCargo.052_Scientists");
    s.variablesState["Backlog"] = new InkList();
    s.variablesState["StaleBacklog"] = new InkList();

    triggerNextDay(s);

    // -3 skip penalty, no passive bonus (tier 1)
    expect(s.variablesState["PassengerSatisfaction"]).toBe(47);
  });

  it("tier 2 active module applies +1 passive bonus per day", () => {
    const s = setupTransit(); // AP=1
    s.EvaluateFunction("install_module", [L(s, "ShipModules.PassengerModule"), 100]);
    s.variablesState["PassengerModuleTier"] = 2;
    s.variablesState["PassengerSatisfaction"] = 50;
    s.variablesState["DailyPassengerTask"] = new InkList(); // no task offered
    s.variablesState["PassengerTaskCompleted"] = true; // no skip penalty
    s.variablesState["ShipCargo"] = L(s, "AllCargo.052_Scientists");
    s.variablesState["Backlog"] = new InkList();
    s.variablesState["StaleBacklog"] = new InkList();

    triggerNextDay(s);

    // +1 passive bonus (tier 2 active), no skip penalty
    expect(s.variablesState["PassengerSatisfaction"]).toBe(51);
  });

  it("tier 3 active module applies +2 passive bonus per day", () => {
    const s = setupTransit(); // AP=1
    s.EvaluateFunction("install_module", [L(s, "ShipModules.PassengerModule"), 100]);
    s.variablesState["PassengerModuleTier"] = 3;
    s.variablesState["PassengerSatisfaction"] = 50;
    s.variablesState["DailyPassengerTask"] = new InkList();
    s.variablesState["PassengerTaskCompleted"] = true;
    s.variablesState["ShipCargo"] = L(s, "AllCargo.052_Scientists");
    s.variablesState["Backlog"] = new InkList();
    s.variablesState["StaleBacklog"] = new InkList();

    triggerNextDay(s);

    // +2 passive bonus (tier 3 active), no skip penalty
    expect(s.variablesState["PassengerSatisfaction"]).toBe(52);
  });

  it("tier 3 at low condition (below 50%) provides no passive bonus", () => {
    const s = setupTransit(); // AP=1
    s.EvaluateFunction("install_module", [L(s, "ShipModules.PassengerModule"), 40]);
    s.variablesState["PassengerModuleTier"] = 3;
    s.variablesState["PassengerSatisfaction"] = 50;
    s.variablesState["DailyPassengerTask"] = new InkList();
    s.variablesState["PassengerTaskCompleted"] = true;
    s.variablesState["ShipCargo"] = L(s, "AllCargo.052_Scientists");
    s.variablesState["Backlog"] = new InkList();
    s.variablesState["StaleBacklog"] = new InkList();

    triggerNextDay(s);

    // T3 base=2, below 50% → -2 → passive=0
    expect(s.variablesState["PassengerSatisfaction"]).toBe(50);
  });

  it("tier 1 at low condition (below 50%) applies -2 passive penalty", () => {
    const s = setupTransit(); // AP=1
    s.EvaluateFunction("install_module", [L(s, "ShipModules.PassengerModule"), 40]);
    s.variablesState["PassengerModuleTier"] = 1;
    s.variablesState["PassengerSatisfaction"] = 50;
    s.variablesState["DailyPassengerTask"] = new InkList();
    s.variablesState["PassengerTaskCompleted"] = true;
    s.variablesState["ShipCargo"] = L(s, "AllCargo.052_Scientists");
    s.variablesState["Backlog"] = new InkList();
    s.variablesState["StaleBacklog"] = new InkList();

    triggerNextDay(s);

    // T1 base=0, below 50% → -2 → passive=-2
    expect(s.variablesState["PassengerSatisfaction"]).toBe(48);
  });

  it("tier 2 at reduced condition (50-79%) provides no passive bonus", () => {
    const s = setupTransit(); // AP=1
    s.EvaluateFunction("install_module", [L(s, "ShipModules.PassengerModule"), 60]);
    s.variablesState["PassengerModuleTier"] = 2;
    s.variablesState["PassengerSatisfaction"] = 50;
    s.variablesState["DailyPassengerTask"] = new InkList();
    s.variablesState["PassengerTaskCompleted"] = true;
    s.variablesState["ShipCargo"] = L(s, "AllCargo.052_Scientists");
    s.variablesState["Backlog"] = new InkList();
    s.variablesState["StaleBacklog"] = new InkList();

    triggerNextDay(s);

    // T2 base=1, 50-79% → -1 → passive=0
    expect(s.variablesState["PassengerSatisfaction"]).toBe(50);
  });
});

describe("Delivery payoff — satisfaction pay modifier", () => {
  /**
   * 031_Diplomats: Earth→Luna, mass=30, passengers=1
   * Base pay = FLOOR(30 × distance(Earth,Luna) × PayRate × 1.5)
   *
   * We start at Earth, set here=Luna so the cargo delivers.
   */
  let story;

  beforeEach(() => {
    story = createStory();
    drainText(story);
    story.EvaluateFunction("install_module", [L(story, "ShipModules.PassengerModule"), 100]);
    story.variablesState["PassengerModuleTier"] = 1;
    story.variablesState["ShipCargo"] = L(story, "AllCargo.031_Diplomats");
    story.variablesState["here"] = L(story, "AllLocations.Luna");
    story.variablesState["PaperworkDone"] = 0;
    story.variablesState["PaperworkTotal"] = 0;
    story.variablesState["CargoCheckPenaltyPct"] = 0;
    story.variablesState["CargoDamagePct"] = 0;
  });

  function getBasePay() {
    const dist = story.EvaluateFunction("get_distance", [
      L(story, "AllLocations.Earth"),
      L(story, "AllLocations.Luna"),
    ]);
    return story.EvaluateFunction("get_cargo_pay", [L(story, "AllCargo.031_Diplomats"), dist]);
  }

  it("pays full base amount when satisfaction is neutral (50)", () => {
    story.variablesState["PassengerSatisfaction"] = 50;
    const basePay = getBasePay();
    const balanceBefore = story.variablesState["PlayerBankBalance"];

    pickChoice(story, "Deliver cargo");
    pickChoice(story, "Done");

    expect(story.variablesState["PlayerBankBalance"]).toBe(balanceBefore + basePay);
  });

  it("pays +10% when satisfaction is in bonus zone (≥70)", () => {
    story.variablesState["PassengerSatisfaction"] = 80;
    const basePay = getBasePay();
    const expectedPay = basePay + Math.floor(basePay * 10 / 100);
    const balanceBefore = story.variablesState["PlayerBankBalance"];

    pickChoice(story, "Deliver cargo");
    pickChoice(story, "Done");

    expect(story.variablesState["PlayerBankBalance"]).toBe(balanceBefore + expectedPay);
  });

  it("pays -10% when satisfaction is in penalty zone (≤30)", () => {
    story.variablesState["PassengerSatisfaction"] = 20;
    const basePay = getBasePay();
    // Ink uses floor division, so negative modifiers floor toward -∞:
    // pax_modifier = (pay * -10) / 100 → floor(-897*10/100) = -90, not -89
    const expectedPay = basePay + Math.floor(basePay * -10 / 100);
    const balanceBefore = story.variablesState["PlayerBankBalance"];

    pickChoice(story, "Deliver cargo");
    pickChoice(story, "Done");

    expect(story.variablesState["PlayerBankBalance"]).toBe(balanceBefore + expectedPay);
  });

  it("satisfaction modifier does not apply to non-passenger cargo", () => {
    story.variablesState["PassengerSatisfaction"] = 80; // bonus zone
    // 101_Helium: Luna→Earth, mass=20, no flags — deliver at Earth
    story.variablesState["ShipCargo"] = L(story, "AllCargo.101_Helium");
    story.variablesState["here"] = L(story, "AllLocations.Earth");
    const dist = story.EvaluateFunction("get_distance", [
      L(story, "AllLocations.Luna"),
      L(story, "AllLocations.Earth"),
    ]);
    const basePay = story.EvaluateFunction("get_cargo_pay", [L(story, "AllCargo.101_Helium"), dist]);
    const balanceBefore = story.variablesState["PlayerBankBalance"];

    pickChoice(story, "Deliver cargo");
    pickChoice(story, "Done");

    // Pay should equal base (no satisfaction modifier for non-passenger cargo)
    expect(story.variablesState["PlayerBankBalance"]).toBe(balanceBefore + basePay);
  });

  it("resets satisfaction to 50 when all passengers delivered", () => {
    story.variablesState["PassengerSatisfaction"] = 80;

    pickChoice(story, "Deliver cargo");
    pickChoice(story, "Done");

    expect(story.variablesState["PassengerSatisfaction"]).toBe(50);
  });
});

describe("Passenger module — upgrade menu", () => {
  let story;

  beforeEach(() => {
    story = createStory();
    drainText(story);
  });

  it("shows passenger module install option in upgrade menu", () => {
    pickChoice(story, "Ship upgrades");
    expect(hasChoice(story, "Passenger module")).toBe(true);
  });

  it("does not show passenger module in browse modules list", () => {
    pickChoice(story, "Ship upgrades");
    pickChoice(story, "Browse available modules");
    expect(hasChoice(story, "Passenger Module")).toBe(false);
  });

  it("passenger module install option disappears at tier 3", () => {
    story.EvaluateFunction("install_module", [L(story, "ShipModules.PassengerModule"), 100]);
    story.variablesState["PassengerModuleTier"] = 3;

    pickChoice(story, "Ship upgrades");
    expect(hasChoice(story, "Passenger module")).toBe(false);
  });
});

describe("Passenger cargo injection nudge", () => {
  const ITERATIONS = 30;

  it("with passenger module, passenger cargo appears in a statistically significant number of draws at Earth", () => {
    // With ~14/99 Earth items being passengers plus the 50% injection nudge,
    // passenger cargo should appear in well over 40% of draws.
    // Early-exit once we have enough positive evidence.
    const s = createStory();
    let passengerDrawCount = 0;
    const TARGET = Math.ceil(ITERATIONS * 0.4) + 1;

    for (let i = 0; i < ITERATIONS; i++) {
      s.ResetState();
      s.variablesState["ShipFuelCapacity"] = 2000;
      s.EvaluateFunction("install_module", [L(s, "ShipModules.PassengerModule"), 100]);
      s.variablesState["PassengerModuleTier"] = 1;

      const result = s.EvaluateFunction("get_available_cargo", [L(s, "AllLocations.Earth"), 5]);
      const hasPassenger = s.EvaluateFunction("has_passenger_in_list", [result]);
      if (hasPassenger) {
        passengerDrawCount++;
        if (passengerDrawCount >= TARGET) break; // early exit once condition met
      }
    }
    expect(passengerDrawCount).toBeGreaterThanOrEqual(TARGET);
  }, 30000);

  it("without passenger module, no passenger cargo appears in draws", () => {
    // Without module, cargo_is_available filters out all passenger cargo.
    const s = createStory();

    for (let i = 0; i < ITERATIONS; i++) {
      s.ResetState();
      s.variablesState["ShipFuelCapacity"] = 2000;

      const result = s.EvaluateFunction("get_available_cargo", [L(s, "AllLocations.Earth"), 5]);
      const hasPassenger = s.EvaluateFunction("has_passenger_in_list", [result]);
      expect(hasPassenger).toBe(false);
    }
  }, 30000);
});
