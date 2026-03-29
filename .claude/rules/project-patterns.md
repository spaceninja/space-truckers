# Space Truckers — Project Patterns

This document records useful patterns that would be helpful in future work. It is not intended for human readers, and can be written in a mode best suited for an AI reader.

## File Structure

| File                 | Purpose                                                                             |
| -------------------- | ----------------------------------------------------------------------------------- |
| `space-truckers.ink` | Entry point. Global VARs, LISTs, engine data tables                                 |
| `ship.ink`           | Transit loop: `transit()`, `ship_options`, task system, `next_day()`, `pass_time()` |
| `port.ink`           | Port UI: cargo loading, fuel station, repairs, departure                            |
| `cargo.ink`          | Cargo LIST, `CargoData()` lookup, helper functions                                  |
| `locations.ink`      | Location LIST, `LocationData()` lookup, distances, fuel prices                      |
| `events.ink`         | Random event system: dispatch, event knots, `damage_random_system()`                |
| `functions.ink`      | Shared utility functions: `pop()`, `pop_random()`, `list_random_subset_of_size()`   |
| `simulator.html`     | Standalone balance tool (mirrors game constants — keep in sync)                     |

## Data Modeling Pattern

Game data uses LIST + function lookup tables (not Ink's built-in list values):

```ink
LIST CargoStats = From, To, Mass, Title, Express, Fragile
=== function CargoData(item, stat)
{ item == 001_Plums:
    ~ return cargo_row(stat, Earth, Mars, 5, ...)
}
```

This pattern is used for `CargoData`, `LocationData`, `EngineData`, and will be used for `ModuleData`.

## VAR Subset Pattern

When a subset of a LIST needs special treatment, define a VAR holding those members:

```ink
LIST Events = (A), (B), (C), (D)
VAR PassengerEvents = (C, D)    // subset requiring passengers
~ Events -= PassengerEvents      // bulk removal
```

Used for: `PassengerEvents` (events.ink), `EngineTasks` (space-truckers.ink). Preferred over manual `or` chains in functions.

## Task Priority System (ship.ink)

Tasks are threaded (`<-`) into `ship_options` using `CHOICE_COUNT()` caps:

| Tier | Purpose                                       | Cap logic                       |
| ---- | --------------------------------------------- | ------------------------------- |
| P1   | Urgent (ship flip)                            | No cap                          |
| P2   | Important (engine, urgent sleep)              | `TaskCap - p3_floor - p4_floor` |
| P3   | Routine (paperwork, nav, maintenance backlog) | `TaskCap - p4_floor`            |
| P4   | Recreation (relax, sleep)                     | `TaskCap`                       |
| P5   | Rest (skip day)                               | Only when no P1-P3 active       |

Each tier uses a shuffle block for variety. `has_tier_tasks(tier)` centralizes eligibility checks.

## Maintenance Backlog (ship.ink)

- 4 persistent tasks from `MaintTasks` LIST, tracked in `Backlog`/`StaleBacklog` VARs
- Tasks completed during the day shrink the backlog; `refill_backlog()` runs in `next_day()`
- Two-day aging: fresh → stale (overdue marker) → auto-resolve with -5 condition penalty
- `is_engine_task()` uses `EngineTasks ? task` to categorize; `has_overdue_tasks()` checks staleness

## Ink Gotchas

- **Functions can't print text or use diverts.** Use knots/stitches/tunnels for narrative output.
- **Integer math:** `a * b / c` evaluates as `a * (b / c)`, truncating early. Store `a * b` in a temp first.
- **`~` on its own line:** Never inline `~ return` inside `{ condition: }`. Use a multi-line block.
- **VAR list init needs parens:** `VAR X = (A, B, C)` not `VAR X = A, B, C`.

## Test Helpers (tests/helpers/story.js)

- `createStory()` — compile fresh story instance
- `L(story, 'ListName.Item')` — construct InkList value
- `cargo(story, ...names)` — build multi-item InkList
- `drainText(story)` — advance to next choice point

Tests jump to specific knots via `story.ChoosePathString()` and set state via `story.variablesState["VarName"]`.
