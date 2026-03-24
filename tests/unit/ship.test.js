/**
 * Unit tests for ship functions.
 *
 *   can_sleep()
 *     → true when Fatigue >= 30
 *
 *   is_overtired()
 *     → true when Fatigue >= 70
 */

import { describe, it, expect, beforeEach } from "vitest";
import { createStory } from "../helpers/story.js";

let story;

beforeEach(() => {
  story = createStory();
});

describe("can_sleep", () => {
  it("returns false when Fatigue is 0 (fully rested)", () => {
    story.variablesState["Fatigue"] = 0;
    expect(story.EvaluateFunction("can_sleep", [])).toBe(false);
  });

  it("returns false when Fatigue is 20 (below threshold)", () => {
    story.variablesState["Fatigue"] = 20;
    expect(story.EvaluateFunction("can_sleep", [])).toBe(false);
  });

  it("returns true at threshold (Fatigue = 30)", () => {
    story.variablesState["Fatigue"] = 30;
    expect(story.EvaluateFunction("can_sleep", [])).toBe(true);
  });

  it("returns true when Fatigue exceeds threshold", () => {
    story.variablesState["Fatigue"] = 80;
    expect(story.EvaluateFunction("can_sleep", [])).toBe(true);
  });
});

describe("is_overtired", () => {
  it("returns false when Fatigue is 0", () => {
    story.variablesState["Fatigue"] = 0;
    expect(story.EvaluateFunction("is_overtired", [])).toBe(false);
  });

  it("returns false when Fatigue is 60 (below threshold)", () => {
    story.variablesState["Fatigue"] = 60;
    expect(story.EvaluateFunction("is_overtired", [])).toBe(false);
  });

  it("returns true at threshold (Fatigue = 70)", () => {
    story.variablesState["Fatigue"] = 70;
    expect(story.EvaluateFunction("is_overtired", [])).toBe(true);
  });

  it("returns true when severely overtired", () => {
    story.variablesState["Fatigue"] = 100;
    expect(story.EvaluateFunction("is_overtired", [])).toBe(true);
  });
});
