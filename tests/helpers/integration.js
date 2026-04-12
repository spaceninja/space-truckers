/**
 * Shared helpers for integration tests.
 *
 * Provides setupTransit (transit state factory), setupEvent (event knot
 * factory), and choice-interaction utilities used across all integration
 * test files.
 */

import { InkList } from "inkjs/full";
import { createStory, L, drainText } from "./story.js";

/**
 * Return all current choice texts as an array.
 */
export function choiceTexts(story) {
  return story.currentChoices.map((c) => c.text);
}

/**
 * Return true if a choice containing `text` is available.
 */
export function hasChoice(story, text) {
  return story.currentChoices.some((c) => c.text.includes(text));
}

/**
 * Pick the choice containing `text`, then drain to the next choice point.
 * Throws if no matching choice is found.
 */
export function pickChoice(story, text) {
  const idx = story.currentChoices.findIndex((c) => c.text.includes(text));
  if (idx === -1)
    throw new Error(
      `Choice not found: "${text}"\nAvailable: ${choiceTexts(story).join(", ")}`
    );
  story.ChooseChoiceIndex(idx);
  drainText(story);
}

/**
 * Pick a choice and return the output text (before draining to next choice point).
 */
export function pickChoiceGetText(story, text) {
  const idx = story.currentChoices.findIndex((c) => c.text.includes(text));
  if (idx === -1)
    throw new Error(
      `Choice not found: "${text}"\nAvailable: ${choiceTexts(story).join(", ")}`
    );
  story.ChooseChoiceIndex(idx);
  let output = "";
  while (story.canContinue) {
    output += story.Continue();
  }
  return output;
}

/**
 * Default transit state values shared across integration tests.
 * Individual tests override specific keys via the overrides parameter.
 */
const TRANSIT_DEFAULTS = {
  ShipClock: 5,
  TripDuration: 10,
  TripDay: 3,
  FlipDone: true,
  PaperworkDone: 1,
  PaperworkTotal: 1,
  TripFuelCost: 100,
  TripFuelPenalty: 0,
  NavCheckDueDay: 99,
  NavPenaltyPct: 0,
  CargoCheckDueDay: 99,
  CargoCheckPenaltyPct: 0,
  AP: 6,
  ActionPointsMax: 6,
  Fatigue: 0,
  ShipCondition: 100,
  ShipFuel: 200,
  TaskCap: 7,
  TasksCompletedToday: 0,
  EventChance: 0,
  EventCooldownDay: -1,
  CargoDamagePct: 0,
};

/**
 * Create a story in transit state and optionally navigate to ship_options.
 *
 * Options:
 *   navigate (default true) — call ChoosePathString("transit.ship_options")
 *     and drain text. Set to false when you need to set additional state
 *     before navigating.
 *
 * Returns the story instance.
 */
export function setupTransit(overrides = {}, { navigate = true } = {}) {
  const story = createStory();
  story.variablesState["ShipCargo"] = new InkList();

  const vars = {
    ...TRANSIT_DEFAULTS,
    ShipDestination: L(story, "AllLocations.Mars"),
    FlightMode: L(story, "FlightModes.Bal"),
    ...overrides,
  };

  for (const [key, value] of Object.entries(vars)) {
    story.variablesState[key] = value;
  }

  if (navigate) {
    story.ChoosePathString("transit.ship_options");
    drainText(story);
  }

  return story;
}

/**
 * Navigate directly to an event knot and drain intro text.
 * Uses the same transit defaults but jumps to a specific knot.
 */
export function setupEvent(eventKnot, overrides = {}) {
  const story = setupTransit(overrides, { navigate: false });
  story.ChoosePathString(eventKnot);
  drainText(story);
  return story;
}
