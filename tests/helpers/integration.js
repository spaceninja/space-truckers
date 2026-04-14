/**
 * Shared helpers for integration tests.
 *
 * Provides story-setup factories (`setupStory`, `setupStoryAt`) and
 * choice-interaction utilities used across all integration test files.
 */

import { InkList } from "inkjs/full";
import { createStory, continueToNextChoice } from "./story.js";

/**
 * Return the visible label text of each currently available choice as an
 * array of strings. Used to list options in error messages when a lookup
 * by choice text fails.
 */
export function getChoiceLabels(story) {
  return story.currentChoices.map((c) => c.text);
}

/**
 * Return true if any currently available choice's label contains `text` as a
 * substring. Matching semantics match `pickChoice`, so a positive result
 * guarantees a subsequent `pickChoice(story, text)` will succeed.
 *
 * Use this to assert presence/absence of a choice without actually selecting
 * it — e.g. verifying that a gating condition hides or reveals an option.
 */
export function hasChoice(story, text) {
  return story.currentChoices.some((c) => c.text.includes(text));
}

/**
 * Pick the first choice whose label contains `text`, then advance to the next
 * choice point. Throws if no matching choice is found, listing the available
 * labels for debugging.
 *
 * Returns the narrative text emitted between the picked choice and the next
 * choice point. Capture the return value when asserting on that text;
 * otherwise ignore it.
 */
export function pickChoice(story, text) {
  const idx = story.currentChoices.findIndex((c) => c.text.includes(text));
  if (idx === -1)
    throw new Error(
      `Choice not found: "${text}"\nAvailable: ${getChoiceLabels(story).join(", ")}`,
    );
  story.ChooseChoiceIndex(idx);
  return continueToNextChoice(story);
}

/**
 * Default story state values shared across integration tests.
 * Individual tests override specific keys via the overrides parameter.
 */
const storyStateDefaults = {
  // example: true,
};

/**
 * Create a fresh story and seed its `variablesState` so integration tests
 * start from a known baseline instead of whatever the Ink source happens to
 * initialize variables to. Any values passed in `overrides` take precedence
 * over the shared `storyStateDefaults`, letting each test tweak only the
 * variables relevant to its scenario.
 *
 * `ShipCargo` is explicitly reset to an empty `InkList` so tests start with
 * an empty cargo hold regardless of the Ink source's initial value.
 */
export function setupStory(overrides = {}) {
  const story = createStory();
  story.variablesState["ShipCargo"] = new InkList();

  const vars = {
    ...storyStateDefaults,
    ...overrides,
  };

  for (const [key, value] of Object.entries(vars)) {
    story.variablesState[key] = value;
  }

  return story;
}

/**
 * Like `setupStory`, but jumps the story's execution pointer directly to the
 * given knot (or stitch) path before returning — bypassing whatever choices
 * would normally lead there. Intro text up to the next choice point is
 * drained so the returned story is positioned at the first interaction.
 *
 * Use when a test needs to assert on gameplay state inside a specific knot
 * without replaying the opening sequence.
 */
export function setupStoryAt(knot, overrides = {}) {
  const story = setupStory(overrides);
  story.ChoosePathString(knot);
  continueToNextChoice(story);
  return story;
}
