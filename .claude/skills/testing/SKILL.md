---
name: testing
description: Testing conventions for Space Truckers — how to write testable Ink code, when and how to write unit and integration tests, and what test helpers are available. Use when writing or modifying Ink functions, working in test files, or when a gameplay interaction warrants a new test.
---

# Testing Conventions

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
// Pass list values using the L() helper
const result = story.EvaluateFunction('get_cargo_pay', [L(story, 'AllCargo.003_Water'), 14]);
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
- `L(story, 'ListName.ItemName')` — constructs an `InkList` value for passing to `EvaluateFunction`
- `cargo(story, ...names)` — builds a multi-item hold by unioning list values
- `drainText(story)` — advances past output text to the next choice point
