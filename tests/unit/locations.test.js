/**
 * Unit tests for location functions.
 */

import { describe, it, expect, beforeAll } from "vitest";
import { InkList } from "inkjs/full";
import { createStory, createListItem } from "../helpers/story.js";

let story;

beforeAll(() => {
  story = createStory();
});

function getLocation(name) {
  return createListItem(story, `AllLocations.${name}`);
}

// ── LocationData (spot-checks for Name stat) ──────────────────────────────────

describe("LocationData Name", () => {
  it("Luna displays as 'Moon Base'", () => {
    expect(
      story.EvaluateFunction("LocationData", [
        getLocation("Luna"),
        createListItem(story, "LocationStats.Name"),
      ]),
    ).toBe("Moon Base");
  });
});
