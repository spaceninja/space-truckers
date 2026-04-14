---
name: ink-testing
description: Conventions for testing an Ink interactive fiction game with inkjs and vitest — how to write testable Ink code, when and how to write unit and integration tests, and what test helpers are available. Use when writing or modifying tests, adding test coverage, or when a gameplay interaction warrants a new test.
---

# Testing an Ink Game

This project tests Ink source files by compiling them with inkjs and running assertions in vitest. These conventions cover how to structure Ink code for testability, when to write each type of test, and how to use the shared test helpers.

## Write testable Ink code

Prefer extracting logic into named `=== function` blocks over embedding it inline in knot bodies. Inline logic can only be exercised through integration tests; extracted functions can be unit-tested directly and cheaply.

**Prefer this:**
```ink
=== function can_afford_fuel(fuel_amount)
~ return PlayerBankBalance >= FLOOR(fuel_amount * get_fuel_price(here))

= fuel_station
+ {can_afford_fuel(ShipFuelCapacity - ShipFuel)} [Fill it up] -> buy_fuel(...)
```

**Over this:**
```ink
= fuel_station
+ {PlayerBankBalance >= FLOOR((ShipFuelCapacity - ShipFuel) * get_fuel_price(here))} [Fill it up] -> buy_fuel(...)
```

When encountering existing inline logic that is complex enough to warrant testing, refactor it into a function.

## Writing unit tests for Ink functions

Whenever a new Ink function is added or an existing one is changed, add a corresponding unit test in `tests/unit/`. Use `story.EvaluateFunction()` to call the function directly:

```js
// Pass list values using the createListItem() helper
const result = story.EvaluateFunction('get_cargo_pay', [createListItem(story, 'AllCargo.003_Water'), 14]);
expect(result).toBe(1680);
```

Good candidates for unit tests (in order of priority):
- **Pure math functions** — `get_cargo_pay`, `get_trip_fuel_cost`, `get_trip_duration`
- **Data lookups** — `CargoData`, `EngineData`, `LocationData` / `get_distance`
- **Boolean predicates** — `cargo_has_express`, `cargo_blocks_turbo`, `cargo_is_mixed_hazardous`
- **Recursive list utilities** — `total_mass`, `pop`, `list_random_subset_of_size`

## Suggesting integration tests

When a complex gameplay interaction is added or changed, suggest adding an integration test in `tests/integration/`. Good candidates:

- A new departure check (e.g. a new cargo restriction that blocks ship-out)
- A new port action that changes `PlayerBankBalance`, `ShipFuel`, or `ShipCargo`
- A new transit mode or destination type
- Any flow that involves conditional choices based on game state

Integration tests drive the story via `pickChoice()` and assert on `variablesState` or `currentChoices`. See `tests/integration/port.test.js` for the established pattern.

## Test helpers

All tests share the factory in `tests/helpers/story.js`:
- `createStory()` — compiles `.ink` source fresh; call once per test or `beforeAll`
- `createListItem(story, 'ListName.ItemName')` — constructs the `InkList` value representing a single LIST item (needed to cross the JS↔Ink boundary)
- `createListUnion(story, ...names)` — constructs a multi-item `InkList` by unioning list-item values together
- `continueToNextChoice(story)` — advances the story until it blocks on a choice point or ends; returns the concatenated output text (usually discarded)

## Performance

`createStory()` compiles the full Ink source and is the most expensive operation in tests. Keep these guidelines in mind to avoid CI timeouts:

- **Reuse story instances in loops.** For statistical or iteration-based tests, create the story once, then use `story.ResetState()` to reset all runtime state between iterations. Each reset is cheap; compilation is not.
- **Early-exit when possible.** For tests like "verify at least N distinct outcomes", break out of the loop as soon as the condition is met rather than running all iterations.
- **Keep iteration counts reasonable.** 50-100 iterations is fine when reusing a single story instance.

```js
// Good: one story, many iterations
const s = createStory();
for (let i = 0; i < 30; i++) {
  s.ResetState();
  s.EvaluateFunction("add_daily_tasks");
  // ... assert ...
  if (conditionMet) break; // early exit
}

// Bad: new story per iteration (causes CI timeouts)
for (let i = 0; i < 30; i++) {
  const s = createStory(); // compiles every time!
  // ...
}
```
