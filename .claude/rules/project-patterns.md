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
| `modules.ink`        | Module data, accessors, drone tunnels, purchase/repair UI                           |
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

This pattern is used for `CargoData`, `LocationData`, `EngineData`, and `ModuleData`.

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

- Three systems: `EngineMaintTasks`, `ShipMaintTasks`, `ModuleMaintTasks` LISTs
- Two-stage daily selection via `add_daily_tasks()`: Stage 1 draws 3 engine + 3 ship + 1 module task (installed modules only) → Stage 2 coin flip for 3 or 4 from that combined pool
- One-day cooldown: `CompletedToday` → `MaintCooldown` rotation excludes recently completed tasks from next day's draw
- Economy: +3 condition on completion, +1 if fatigued, -5 on overdue auto-resolve
- Two-day aging: fresh → stale (overdue marker) → auto-resolve with condition penalty
- `is_engine_maint()` / `is_ship_maint()` / `is_module_maint()` categorize tasks; `maint_task_module(task)` maps module tasks to their parent module
- `has_overdue_tasks()` checks staleness
- Module tasks affect only their specific module (per-module both directions)
- Drone modules auto-complete engine/ship tasks (not module tasks) after daily setup (settle → age → add → drones)

## Module System (modules.ink)

- `ShipModules` LIST, `InstalledModules` VAR, per-module condition VARs (0 = not installed)
- `ModuleData(module, stat)` lookup, `get_module_condition()`/`set_module_condition()` accessors
- `is_module_active(module)` — installed AND condition >= 50
- `get_drone_capacity(module)` — 2 at 75%+, 1 at 50-74%, 0 below 50%
- `module_auto_tasks` tunnel: runs in `next_day()` and at trip start; handles all modules — drones (engine/ship task split, stale-first), AutoNav, CargoMgmt, WellnessSuite
- `RefurbishedModules` VAR tracks 80% max cap; `get_module_max_condition()` enforces it
- Module maintenance tasks in `ModuleMaintTasks` LIST: 2 tasks per module; `module_tasks_for(mod)` returns a module's task pair; `available_module_tasks()` returns the union across installed modules
- Narrative lookup: `MaintName(task)`, `MaintComplete(task)`, `MaintFatigued(task)`, `MaintOverdue(task)` — one function per text type, switch block covering all tasks from all three LISTs
- Purchase UI: `ship_upgrades` knot with buy new/refurb/repair options for modules; `engine_upgrades` stitch for engine purchases (next tier only, manufacturer gated by location)
- Engine upgrade system: `EngPrice` stat in `EngineStats`, `RefurbishedEngine` VAR (boolean), `get_engine_max_condition()` in functions.ink mirrors `get_module_max_condition()` pattern; manufacturer availability via `manufacturer_available_here(mfg)` checked against `here`
- Entertainment System: `apply_recreation_bonus(base)` function in ship.ink — +50% morale at 75%+ condition; new P4 tasks `VideoGames`/`ListenMusic` gated by `is_module_active(Entertainment)`
- WellnessSuite wires `has_medical_module()` in events.ink

## Ink Gotchas

- **Functions can't print text or use diverts.** Use knots/stitches/tunnels for narrative output.
- **Integer math:** `a * b / c` evaluates as `a * (b / c)`, truncating early. Store `a * b` in a temp first.
- **`~` on its own line:** Never inline `~ return` inside `{ condition: }`. Use a multi-line block.
- **VAR list init needs parens:** `VAR X = (A, B, C)` not `VAR X = A, B, C`.
- **Two conditional syntaxes, don't mix them:** Simple form puts the condition inline (`{ cond:` … `- else:`) and only supports `- else:` as a branch. Extended form puts `{` on its own line and uses `- condition:` for every branch including the first. Mixing them (simple opening + `- condition:` branch) is a compile error.
- **Threads (`<-`) are not tunnels (`-> ... ->`):** A stitch called via `<-` cannot use `->->` to return. Every branch must divert explicitly (e.g., `-> upgrade_menu`). To skip choices for a condition, gate them with `+ { condition }` rather than early-returning with `->->`.

## Test Helpers (tests/helpers/story.js)

- `createStory()` — compile fresh story instance
- `L(story, 'ListName.Item')` — construct InkList value
- `cargo(story, ...names)` — build multi-item InkList
- `drainText(story)` — advance to next choice point

Tests jump to specific knots via `story.ChoosePathString()` and set state via `story.variablesState["VarName"]`.

### Performance

`createStory()` compiles the full Ink source and is expensive (~200ms). Never call it in a loop. For statistical or iteration-based tests, compile once and use `story.ResetState()` between iterations:

```js
const s = createStory();
for (let i = 0; i < 30; i++) {
  s.ResetState();
  s.EvaluateFunction("some_function");
  // ... assert ...
}
```
