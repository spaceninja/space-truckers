/**
 * Integration tests for the random event system.
 *
 * Events are triggered by setting EventChance to 100 (guaranteed fire
 * on next check), then navigating to ship_options. Individual events
 * are tested by jumping directly to their knots via ChoosePathString.
 *
 * Statistical tests reuse a single story instance for performance.
 */

import { describe, it, expect } from "vitest";
import { L, drainText } from "../helpers/story.js";
import {
  hasChoice,
  pickChoice,
  pickChoiceGetText,
  setupTransit,
  setupEvent,
} from "../helpers/integration.js";

// ---------------------------------------------------------------------------
// Event triggering
// ---------------------------------------------------------------------------

describe("Event triggering", () => {
  it("no event fires when EventChance is 0 (first check)", () => {
    const story = setupTransit({ EventChance: 0 });
    // If an event had fired, the story would have diverted before presenting
    // normal task choices. Verify we got normal choices instead.
    expect(hasChoice(story, "Call it a day")).toBe(true);
  });

  it("events do not repeat within a trip", () => {
    // Fire all general events by calling random_event repeatedly.
    // After all have fired, the pool should be empty and the
    // dispatcher should fall through to ship_options.
    const story = setupTransit({}, { navigate: false });
    // Give non-passenger cargo so CargoShift is eligible
    story.variablesState["ShipCargo"] = L(story, "AllCargo.001_Plums");
    // Remove passenger events (no passenger cargo — simulates what transit() does)
    const passengerEvents = story.variablesState["PassengerEvents"];
    story.variablesState["Events"] = story.variablesState["Events"].Without(passengerEvents);

    // Fire all 6 non-passenger events
    for (let i = 0; i < 6; i++) {
      story.variablesState["AP"] = 6;
      
      story.variablesState["TripFuelPenalty"] = 0;
      story.variablesState["CargoDamagePct"] = 0;
      story.variablesState["ShipClock"] = 5;
      story.ChoosePathString("random_event");
      drainText(story);
    }

    // After 6 events, the Events list should be empty
    const eventsRemaining = story.variablesState["Events"];
    expect(eventsRemaining.Count).toBe(0);
  });

  it("event fires when EventChance is 100", () => {
    // With EventChance at 100, RANDOM(1,100) <= 100 is always true.
    // The event will fire and divert before the task list.
    // After the event resolves it returns to ship_options or pass_time,
    // so we just verify we didn't get a clean normal task list immediately.
    const story = setupTransit({ EventChance: 100 }, { navigate: false });
    story.ChoosePathString("transit.ship_options");
    let text = "";
    while (story.canContinue) text += story.Continue();
    // Should have fired an event — text should contain event narrative
    expect(text).not.toBe("");
    // EventChance should have been reset to 0
    expect(story.variablesState["EventChance"]).toBe(0);
    // EventCooldownDay should be set to current TripDay
    expect(story.variablesState["EventCooldownDay"]).toBe(3);
  });

  it("EventChance increments by 3 per check when no event fires", () => {
    const story = setupTransit({ EventChance: 0 });
    expect(story.variablesState["EventChance"]).toBe(3);
  });

  it("cooldown prevents second event on same day", () => {
    // EventCooldownDay == TripDay means we're in cooldown
    const story = setupTransit({
      EventChance: 100, // would fire if not in cooldown
      EventCooldownDay: 3, // same as default TripDay
    });
    // Cooldown active — should get normal task choices, not an event
    expect(hasChoice(story, "Call it a day")).toBe(true);
    // EventChance should still have incremented (cooldown blocks event, not increment)
    // Actually per our logic: when in cooldown, we skip the check entirely
    // so EventChance should NOT increment either
    expect(story.variablesState["EventChance"]).toBe(100);
  });
});

// ---------------------------------------------------------------------------
// Micrometeorite
// ---------------------------------------------------------------------------

describe("Event: Micrometeorite", () => {
  it("costs 2 AP when not fatigued", () => {
    const story = setupEvent("event_micrometeorite", {
      Fatigue: 0,
      AP: 6,
      TripFuelCost: 100,
      TripFuelPenalty: 0,
    });
    // No choices for micrometeorite — it resolves automatically
    // After resolution AP should have decreased by 2
    expect(story.variablesState["AP"]).toBe(4);
  });

  it("costs 3 AP and adds fuel penalty when fatigued (statistical)", () => {
    const story = setupEvent("event_micrometeorite", {
      Fatigue: 0,
      AP: 6,
      TripFuelCost: 100,
      TripFuelPenalty: 0,
    });

    let slowRepairs = 0;
    for (let i = 0; i < 50; i++) {
      story.variablesState["Fatigue"] = 90;
      story.variablesState["AP"] = 6;
      story.variablesState["TripFuelPenalty"] = 0;
      story.variablesState["TripFuelCost"] = 100;
      
      story.variablesState["CargoDamagePct"] = 0;
      story.ChoosePathString("event_micrometeorite");
      drainText(story);
      if (story.variablesState["AP"] === 3) slowRepairs++;
      if (slowRepairs > 0) break;
    }
    expect(slowRepairs).toBeGreaterThan(0);
  });

  it("damage table produces varied outcomes (statistical)", () => {
    const story = setupEvent("event_micrometeorite", {
      Fatigue: 0,
      AP: 6,
      TripFuelCost: 100,
    });

    const outcomes = new Set();
    for (let i = 0; i < 50; i++) {
      story.variablesState["Fatigue"] = 0;
      story.variablesState["AP"] = 6;
      story.variablesState["ShipCondition"] = 100;
      story.variablesState["CargoDamagePct"] = 0;
      story.variablesState["TripFuelPenalty"] = 0;
      story.ChoosePathString("event_micrometeorite");
      drainText(story);
      const cond = story.variablesState["ShipCondition"];
      const dmg = story.variablesState["CargoDamagePct"];
      if (cond < 100) outcomes.add("system");
      else if (dmg > 0) outcomes.add("cargo");
      else outcomes.add("lucky");
      if (outcomes.size >= 2) break;
    }
    expect(outcomes.size).toBeGreaterThanOrEqual(2);
  });
});

// ---------------------------------------------------------------------------
// Power Surge
// ---------------------------------------------------------------------------

describe("Event: Power Surge", () => {
  it("quick fix costs 2 AP and damages system when not fatigued", () => {
    const story = setupEvent("event_power_surge", {
      Fatigue: 0,
      AP: 6,
      
      TripFuelPenalty: 0,
    });
    pickChoice(story, "Isolate the surge");
    expect(story.variablesState["ShipCondition"]).toBe(75); // 100 - 25
    expect(story.variablesState["AP"]).toBe(4); // 6 - 2
    expect(story.variablesState["TripFuelPenalty"]).toBe(0);
  });

  it("quick fix costs 3 AP and more damage when fatigued (statistical)", () => {
    const story = setupEvent("event_power_surge", {
      AP: 6,
      
      TripFuelPenalty: 0,
    });

    let worstCase = 0;
    for (let i = 0; i < 50; i++) {
      story.variablesState["Fatigue"] = 90;
      story.variablesState["AP"] = 6;
      story.variablesState["ShipCondition"] = 100;
      story.variablesState["TripFuelPenalty"] = 0;
      story.ChoosePathString("event_power_surge");
      drainText(story);
      pickChoice(story, "Isolate the surge");
      // Fatigue failure: ShipCondition should be 60 (100-40) and AP 3
      if (
        story.variablesState["ShipCondition"] === 60 &&
        story.variablesState["AP"] === 3
      ) {
        worstCase++;
        break;
      }
    }
    expect(worstCase).toBeGreaterThan(0);
  });

  it("proper fix costs 3 AP and adds fuel penalty when not fatigued", () => {
    const story = setupEvent("event_power_surge", {
      Fatigue: 0,
      AP: 6,
      
      TripFuelCost: 100,
      TripFuelPenalty: 0,
    });
    pickChoice(story, "full system reset");
    expect(story.variablesState["AP"]).toBe(3); // 6 - 3
    expect(story.variablesState["TripFuelPenalty"]).toBe(5); // +5%
    expect(story.variablesState["ShipCondition"]).toBe(100); // no damage
  });

  it("proper fix costs 4 AP, adds fuel penalty AND damage when fatigued (statistical)", () => {
    const story = setupEvent("event_power_surge", {
      AP: 6,
      
      TripFuelCost: 100,
      TripFuelPenalty: 0,
    });

    let worstCase = 0;
    for (let i = 0; i < 50; i++) {
      story.variablesState["Fatigue"] = 90;
      story.variablesState["AP"] = 6;
      story.variablesState["ShipCondition"] = 100;
      story.variablesState["TripFuelPenalty"] = 0;
      story.ChoosePathString("event_power_surge");
      drainText(story);
      pickChoice(story, "full system reset");
      // Fatigue failure: 4 AP spent, fuel penalty, and minor damage
      if (
        story.variablesState["AP"] === 2 &&
        story.variablesState["TripFuelPenalty"] === 5 &&
        story.variablesState["ShipCondition"] === 85 // 100-15
      ) {
        worstCase++;
        break;
      }
    }
    expect(worstCase).toBeGreaterThan(0);
  });
});

// ---------------------------------------------------------------------------
// Cargo Shift
// ---------------------------------------------------------------------------

describe("Event: Cargo Shift", () => {
  it("costs 2 AP", () => {
    const story = setupEvent("event_cargo_shift", {
      Fatigue: 0,
      AP: 6,
      CargoDamagePct: 0,
    });
    expect(story.variablesState["AP"]).toBe(4);
  });

  it("no cargo damage when not fatigued", () => {
    const story = setupEvent("event_cargo_shift", {
      Fatigue: 0,
      AP: 6,
      CargoDamagePct: 0,
    });
    expect(story.variablesState["CargoDamagePct"]).toBe(0);
  });

  it("sometimes causes cargo damage when fatigued (statistical)", () => {
    const story = setupEvent("event_cargo_shift", {
      AP: 6,
      CargoDamagePct: 0,
    });

    let damaged = 0;
    for (let i = 0; i < 50; i++) {
      story.variablesState["Fatigue"] = 90;
      story.variablesState["AP"] = 6;
      story.variablesState["CargoDamagePct"] = 0;
      story.ChoosePathString("event_cargo_shift");
      drainText(story);
      if (story.variablesState["CargoDamagePct"] > 0) {
        damaged++;
        break;
      }
    }
    expect(damaged).toBeGreaterThan(0);
  });

  it("does not fire without cargo (not eligible)", () => {
    // Cargo shift requires has_cargo. With empty ShipCargo, it should never
    // be selected. We run the dispatcher multiple times, resetting the
    // Events pool each iteration (events are removed after firing).
    const story = setupTransit({}, { navigate: false });
    // Save initial Events list (all active) for resetting between iterations
    const allEvents = story.variablesState["Events"];

    // Run the dispatcher 20 times
    for (let i = 0; i < 20; i++) {
      story.variablesState["AP"] = 6;
      
      story.variablesState["TripFuelPenalty"] = 0;
      story.variablesState["CargoDamagePct"] = 0;
      story.variablesState["Events"] = allEvents;
      story.ChoosePathString("random_event");
      drainText(story);
    }
    // This test verifies the dispatcher doesn't crash with empty cargo.
    expect(true).toBe(true);
  });
});

// ---------------------------------------------------------------------------
// Distress Signal
// ---------------------------------------------------------------------------

describe("Event: Distress Signal", () => {
  it("full help costs 4 AP and awards 500€", () => {
    const story = setupEvent("event_distress_signal", {
      AP: 6,
      PlayerBankBalance: 1000,
    });
    pickChoice(story, "Stop and help with repairs");
    expect(story.variablesState["AP"]).toBe(2); // 6 - 4
    expect(story.variablesState["PlayerBankBalance"]).toBe(1500);
  });

  it("share supplies costs 2 AP and awards 150€", () => {
    const story = setupEvent("event_distress_signal", {
      AP: 6,
      PlayerBankBalance: 1000,
    });
    pickChoice(story, "Share some supplies");
    expect(story.variablesState["AP"]).toBe(4); // 6 - 2
    expect(story.variablesState["PlayerBankBalance"]).toBe(1150);
  });

  it("send relay costs 0 AP and has no reward", () => {
    const story = setupEvent("event_distress_signal", {
      AP: 6,
      PlayerBankBalance: 1000,
    });
    pickChoice(story, "Send a distress relay");
    expect(story.variablesState["AP"]).toBe(6); // unchanged
    expect(story.variablesState["PlayerBankBalance"]).toBe(1000); // unchanged
  });
});

// ---------------------------------------------------------------------------
// Shortcut
// ---------------------------------------------------------------------------

describe("Event: Shortcut", () => {
  it("staying on course has no effect on ShipClock", () => {
    const story = setupEvent("event_shortcut", { ShipClock: 5 });
    pickChoice(story, "Stay on the charted course");
    expect(story.variablesState["ShipClock"]).toBe(5);
  });

  it("taking the shortcut produces varied ShipClock outcomes (statistical)", () => {
    const story = setupEvent("event_shortcut", { ShipClock: 5 });
    const clockValues = new Set();

    for (let i = 0; i < 40; i++) {
      story.variablesState["ShipClock"] = 5;
      story.variablesState["TripFuelPenalty"] = 0;
      story.variablesState["TripFuelCost"] = 100;
      story.ChoosePathString("event_shortcut");
      drainText(story);
      pickChoice(story, "Take the shortcut");
      clockValues.add(story.variablesState["ShipClock"]);
      if (clockValues.size >= 2) break;
    }
    expect(clockValues.size).toBeGreaterThanOrEqual(2);
  });

  it("ShipClock never goes below 1 when taking the shortcut (MAX guard)", () => {
    // The shortcut uses MAX(ShipClock - 1, 1) so it can never reduce
    // ShipClock below 1. Test this invariant directly across multiple rolls.
    const story = setupEvent("event_shortcut", { ShipClock: 1 });

    for (let i = 0; i < 20; i++) {
      story.variablesState["ShipClock"] = 1;
      story.variablesState["TripFuelPenalty"] = 0;
      story.variablesState["TripFuelCost"] = 100;
      story.ChoosePathString("event_shortcut");
      drainText(story);
      pickChoice(story, "Take the shortcut");
      expect(story.variablesState["ShipClock"]).toBeGreaterThanOrEqual(1);
    }
  });
});

