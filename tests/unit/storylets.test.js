/**
 * Unit tests for storylet system.
 */

import { describe, it, expect, beforeAll } from "vitest";
import { createStory } from "../helpers/story.js";

let story;

beforeAll(() => {
  story = createStory();
});

describe("Storylet act subsets", () => {
  it("Act1Storylets + Act2Storylets covers all Storylets", () => {
    const act1 = story.variablesState["Act1Storylets"];
    const act2 = story.variablesState["Act2Storylets"];
    const union = act1.Union(act2);
    const all = act1.all;
    expect(union.toString()).toBe(all.toString());
    expect(union.Count).toBe(all.Count);
  });
});
