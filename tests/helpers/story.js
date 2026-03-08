/**
 * Shared story factory for tests.
 *
 * Creates a fresh compiled Story instance from the Ink source files.
 * Each call returns an independent story with no shared state.
 *
 * Usage:
 *   import { createStory, L } from '../helpers/story.js';
 *   const story = createStory();
 *   const earth = L(story, 'AllLocations.Earth');
 */

import { Compiler, CompilerOptions, InkList } from "inkjs/full";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const INK_ENTRY = path.join(ROOT, "space-truckers.ink");

const fileHandler = {
  ResolveInkFilename: (filename) => path.join(ROOT, filename),
  LoadInkFileContents: (filename) => fs.readFileSync(filename, "utf8"),
};

export function createStory() {
  const source = fs.readFileSync(INK_ENTRY, "utf8");
  const options = new CompilerOptions(null, [], false, null, fileHandler);
  const story = new Compiler(source, options).Compile();
  story.onError = (msg) => { throw new Error(`Ink runtime error: ${msg}`); };
  return story;
}

/**
 * Construct an InkList value from a "ListName.ItemName" string.
 * The story instance is required to resolve the list definition.
 *
 * Examples:
 *   L(story, 'AllLocations.Earth')
 *   L(story, 'AllCargo.001_Plums')
 *   L(story, 'CargoStats.Mass')
 *   L(story, 'EngineStats.FuelCap')
 */
export function L(story, name) {
  return InkList.FromString(name, story);
}

/**
 * Build an InkList containing multiple items by unioning them together.
 *
 * Example:
 *   cargo(story, 'AllCargo.001_Plums', 'AllCargo.003_Water')
 */
export function cargo(story, ...names) {
  return names.reduce(
    (acc, name) => acc.Union(L(story, name)),
    new InkList()
  );
}

/**
 * Drain all pending story text until the next choice point (or end).
 * Returns the concatenated text output.
 */
export function drainText(story) {
  let text = "";
  while (story.canContinue) {
    text += story.Continue();
  }
  return text;
}
