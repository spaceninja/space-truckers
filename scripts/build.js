#!/usr/bin/env node
/**
 * Build script: compiles space-truckers.ink → dist/story.json,
 * then copies the vendored template/ files into dist/.
 */

import { execSync } from "child_process";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const ROOT = path.resolve(__dirname, "..");
const TEMPLATE_DIR = path.join(ROOT, "template");
const DIST_DIR = path.join(ROOT, "dist");
const INK_ENTRY = path.join(ROOT, "space-truckers.ink");
const INK_JSON = path.join(ROOT, "space-truckers.ink.json");
const DIST_STORY = path.join(DIST_DIR, "story.json");

// Step 1: Compile Ink → JSON
console.log("Compiling space-truckers.ink...");
try {
  execSync(`node "${path.join(ROOT, "node_modules/.bin/inkjs-compiler")}" "${INK_ENTRY}"`, {
    cwd: ROOT,
    stdio: "inherit",
  });
} catch (err) {
  console.error("Ink compilation failed.");
  process.exit(1);
}

if (!fs.existsSync(INK_JSON)) {
  console.error(`Expected compiled output not found: ${INK_JSON}`);
  process.exit(1);
}

// Step 2: Set up dist/
fs.mkdirSync(DIST_DIR, { recursive: true });

// Step 3: Copy compiled story JSON into dist/story.json
fs.copyFileSync(INK_JSON, DIST_STORY);
console.log(`Wrote dist/story.json`);

// Step 4: Copy template files into dist/ (skip template's placeholder story.json)
function copyDir(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDir(srcPath, destPath);
    } else {
      // Skip the placeholder story.json bundled in the template
      if (dest === DIST_DIR && entry.name === "story.json") continue;
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

console.log("Copying template files into dist/...");
copyDir(TEMPLATE_DIR, DIST_DIR);

// Step 5: Copy simulator.html into dist/
const SIMULATOR_SRC = path.join(ROOT, "simulator.html");
const SIMULATOR_DEST = path.join(DIST_DIR, "simulator.html");
fs.copyFileSync(SIMULATOR_SRC, SIMULATOR_DEST);
console.log("Copied simulator.html");

console.log("Build complete → dist/");
