/**
 * Unit tests for extracted ship functions.
 *
 *   can_sleep()
 *     → true when AwakeDuration >= ActionPointsMax - 2 (i.e., >= 4 with default max of 6)
 *
 *   is_overtired()
 *     → true when AwakeDuration > ActionPointsMax (i.e., > 6 with default max of 6)
 */

import { describe, it, expect, beforeEach } from "vitest";
import { createStory } from "../helpers/story.js";

let story;

beforeEach(() => {
  story = createStory();
  // ActionPointsMax defaults to 6
});

describe("can_sleep", () => {
  it("returns false when AwakeDuration is 0 (just woke up)", () => {
    story.variablesState["AwakeDuration"] = 0;
    expect(story.EvaluateFunction("can_sleep", [])).toBe(false);
  });

  it("returns false when AwakeDuration is 3 (below threshold)", () => {
    story.variablesState["AwakeDuration"] = 3;
    expect(story.EvaluateFunction("can_sleep", [])).toBe(false);
  });

  it("returns true at threshold (AwakeDuration = ActionPointsMax - 2 = 4)", () => {
    story.variablesState["AwakeDuration"] = 4;
    expect(story.EvaluateFunction("can_sleep", [])).toBe(true);
  });

  it("returns true when AwakeDuration exceeds threshold", () => {
    story.variablesState["AwakeDuration"] = 8;
    expect(story.EvaluateFunction("can_sleep", [])).toBe(true);
  });
});

describe("is_overtired", () => {
  it("returns false when AwakeDuration is 0", () => {
    story.variablesState["AwakeDuration"] = 0;
    expect(story.EvaluateFunction("is_overtired", [])).toBe(false);
  });

  it("returns false when AwakeDuration equals ActionPointsMax (6)", () => {
    story.variablesState["AwakeDuration"] = 6;
    expect(story.EvaluateFunction("is_overtired", [])).toBe(false);
  });

  it("returns true when AwakeDuration exceeds ActionPointsMax (7)", () => {
    story.variablesState["AwakeDuration"] = 7;
    expect(story.EvaluateFunction("is_overtired", [])).toBe(true);
  });

  it("returns true when severely overtired", () => {
    story.variablesState["AwakeDuration"] = 12;
    expect(story.EvaluateFunction("is_overtired", [])).toBe(true);
  });
});
