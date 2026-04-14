/**
 * Shared story factory for tests.
 *
 * Creates a fresh compiled Story instance from the Ink source files.
 * Each call returns an independent story with no shared state.
 *
 * Usage:
 *   import { createStory, createListItem } from '../helpers/story.js';
 *   const story = createStory();
 *   const earth = createListItem(story, 'AllLocations.Earth');
 */

import { Compiler, CompilerOptions, InkList } from "inkjs/full";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const rootPath = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "../..",
);
const storyPath = path.join(rootPath, "space-truckers.ink");

const fileHandler = {
  ResolveInkFilename: (filename) => path.join(rootPath, filename),
  LoadInkFileContents: (filename) => fs.readFileSync(filename, "utf8"),
};

/**
 * Compile the Ink source files into a fresh `Story` instance with no shared
 * state from any previous call.
 *
 * Any Ink runtime error surfaces as a thrown JS `Error` (via `story.onError`),
 * so test failures point at the offending Ink rather than silently corrupting
 * state.
 *
 * Compiling the full source is expensive (~200ms). Prefer compiling once in
 * `beforeAll` and calling `story.ResetState()` between iterations rather than
 * calling `createStory()` in a loop — see `project-patterns.md`.
 */
export function createStory() {
  const source = fs.readFileSync(storyPath, "utf8");
  const options = new CompilerOptions(null, [], false, null, fileHandler);
  const story = new Compiler(source, options).Compile();
  story.onError = (msg) => {
    throw new Error(`Ink runtime error: ${msg}`);
  };
  return story;
}

/**
 * Construct the InkList value representing a single LIST item (e.g. `Earth`,
 * `001_Plums`, `Mass`).
 *
 * Needed because every LIST item in Ink is itself a list value under the hood,
 * and inkjs cannot resolve a bare JS string like `'001_Plums'` when crossing
 * the JS↔Ink boundary. Passing a list-item argument to `EvaluateFunction` or
 * assigning one to `variablesState` requires an actual `InkList` wrapper —
 * this is the JS-side spelling of that value.
 *
 * The story instance is required to resolve the list definition.
 *
 * Examples:
 *   createListItem(story, 'AllLocations.Earth')
 *   createListItem(story, 'AllCargo.001_Plums')
 *   createListItem(story, 'CargoStats.Mass')
 *   createListItem(story, 'EngineStats.FuelCap')
 */
export function createListItem(story, name) {
  return InkList.FromString(name, story);
}

/**
 * Construct an InkList containing multiple items by unioning them together —
 * the JS-side equivalent of an Ink list literal like `(001_Plums, 003_Water)`.
 *
 * Use when an Ink function or variable expects a multi-item list value (e.g.
 * a ship's cargo hold, a set of flags). For a single item, use
 * `createListItem` instead.
 *
 * Example:
 *   createListUnion(story, 'AllCargo.001_Plums', 'AllCargo.003_Water')
 */
export function createListUnion(story, ...names) {
  return names.reduce(
    (acc, name) => acc.Union(createListItem(story, name)),
    new InkList(),
  );
}

/**
 * Advance the story by repeatedly calling `Continue()` until it blocks on
 * external input — i.e. until the next choice point, or the end of the story.
 *
 * Each `story.Continue()` call emits one chunk of narrative text and moves the
 * cursor forward; `story.canContinue` becomes `false` once the runtime is
 * waiting for a choice (or has nothing left to play). Tests typically call
 * this after jumping to a knot or picking a choice so that assertions run
 * against a story positioned at the next interaction.
 *
 * Returns the concatenated output text. Most callers discard the return value
 * and only use this to advance state; capture it when asserting on emitted
 * narrative.
 */
export function continueToNextChoice(story) {
  let text = "";
  while (story.canContinue) {
    text += story.Continue();
  }
  return text;
}
