# Space Truckers — Developer Guide

This document explains the design goals and mathematical foundations of the Space Truckers gameplay systems. It is intended for developers who need to understand *why* the numbers are the way they are, not just what they are.

---

## Core Gameplay Loop

The central design goal is to let the player make meaningful choices between four variables on every run:

- **Mass** — how much cargo to carry
- **Distance** — how far the destination is
- **Time** — how long the trip will take
- **Efficiency** — how much fuel each engine mode burns

No single run is the "obviously correct" choice. A heavier load earns more money but costs more fuel. A faster engine mode saves time but empties the tank. The player is always trading one resource against another. All other systems — engine tiers, cargo flags, fuel pricing — exist to deepen and vary that core trade-off, not to replace it.

---

## Design Philosophy

**Failure = complication, not disaster.** A single missed task should be noticeable but not devastating — roughly 5–10% of a trip's profit. Several failures compound to make a trip unprofitable. The player should never lose the game from one bad day, but should feel the consequences of sustained neglect.

**Progression arc.** The early game is a busy, stressful balancing act — too many tasks, not enough AP. The player cannot do everything every day and must prioritise. The late game feels qualitatively different: ship modules automate the busywork, and the player's decisions shift from "can I keep this ship running?" to "how do I maximise revenue across routes?"

**Events present choices, not taxes.** Random events should offer a "safe but costly" option and a "risky but rewarding" option. The player should feel agency, not just punishment.

---

## Distance Units

Distances are internal, abstract units. They are never displayed to the player and do not correspond to real astronomical distances. They are tuned to produce satisfying fuel cost and trip duration numbers at each engine tier.

| Route | Distance |
|---|---|
| Earth ↔ Luna | 5 |
| Luna ↔ Mars | 8 |
| Earth ↔ Mars | 14 |
| Mars ↔ Ceres | 10 |
| Luna ↔ Ceres | 18 |
| Earth ↔ Ceres | 22 |
| Ceres ↔ Ganymede | 18 |
| Mars ↔ Ganymede | 26 |
| Ganymede ↔ Titan | 16 |
| Mars ↔ Titan | 36 |
| Ceres ↔ Titan | 28 |
| Earth ↔ Ganymede | 40 |
| Luna ↔ Titan | 50 |
| Earth ↔ Titan | 52 |

The inner system (Earth, Luna, Mars) is tightly clustered with distances of 5–14. The belt (Ceres) sits in a middle band at 10–22 from inner planets. The outer system (Ganymede, Titan) is substantially further, at 16–52. This spread means early-game players genuinely cannot reach the outer system in one hop, and late-game players who can do so have a real advantage in route efficiency.

---

## Engine Tiers

There are four engine tiers. The player starts with tier 1 and can purchase upgrades to reach tier 4.

Each tier has eight stats: `FuelCap`, `EcoFuel`, `EcoSpeed`, `BalFuel`, `BalSpeed`, `TurboFuel`, `TurboSpeed`, `EngPrice`.

The table below shows Kepler stats as the Tier 1 baseline and representative values — manufacturer-specific stats differ for Tiers 2-4.

| Tier | FuelCap | EcoFuel | EcoSpeed | BalFuel | BalSpeed | TurboFuel | TurboSpeed | EngPrice |
|---|---|---|---|---|---|---|---|---|
| 1 (starter) | 300 | 1.1 | 1.0 | 2.0 | 1.5 | 4.0 | 2.5 | 0 |
| 2 | 500 | varies | 1.0–1.2 | varies | 1.8–2.0 | varies | 2.7–3.5 | 1,500 |
| 3 | 650 | varies | 1.3–1.8 | varies | 2.3–2.5 | varies | 3.5–4.5 | 2,500 |
| 4 | 800 | varies | 1.8–2.3 | varies | 3.2–3.5 | varies | 4.5–5.5 | 4,000 |

`FuelFactor` values are multipliers in the fuel cost formula (lower is better). `Speed` values are divisors in the trip duration formula (higher is faster). `EngPrice` is the new-engine purchase cost; refurbished engines cost 50% of this.

### Engine Manufacturers

Three manufacturers offer engines at Tiers 2-4, each optimized for a different mode:

| Manufacturer | Specialty | Available at |
|---|---|---|
| Kepler Drive Systems | Best Balance mode | Earth, Luna, Ceres |
| Olympus Propulsion | Best Turbo mode | Mars, Ceres |
| Huygens Deepspace | Best Eco mode | Ganymede, Titan, Ceres |

The player can switch manufacturers at any tier upgrade. Location availability creates meaningful travel decisions — buying a Huygens engine requires a trip to the outer system.

### Refurbished Engines

Refurbished engines follow the same pattern as refurbished modules:

- **Cost:** 50% of new price
- **Starting condition:** 60%
- **Max condition cap:** 80% (tracked by `VAR RefurbishedEngine = true`)
- **Effect:** A permanent −10% fuel efficiency penalty at max condition vs. a new engine

`get_engine_max_condition()` in `functions.ink` returns 80 when `RefurbishedEngine` is true, 100 otherwise. All engine condition caps in `ship.ink` and repair logic in `port.ink` call this function rather than hardcoding 100.

### What Each Tier Unlocks

The engine upgrade path is designed to change *how* the player navigates the solar system, not just how profitable each run is.

**Tier 1 (starter):** Inner system only — Earth, Luna, Mars. Economy mode is the only viable option for most loads. Balance mode breaks even or loses money. Turbo is essentially unusable. The player is doing methodical planet-hopping at thin margins (~17% profit on a decent load). The outer system is technically reachable via multi-hop but uses 88–99% of the tank on each leg — dangerously risky.

**Tier 2:** The belt opens up. Earth→Ceres, Mars→Ceres, and Ceres→Ganymede become viable at light loads. Inner-system margins improve. Crucially, Balance mode becomes *usable* on inner-system runs even though Economy speed hasn't changed — the player suddenly feels faster because they can afford to go faster. Outer-system single-hop routes are still unreachable, but a careful player can now do two-leg outer-system runs.

**Tier 3:** The outer system opens up. Ganymede and Titan routes become accessible. Economy speed improves noticeably (Earth→Mars drops from 14 days to ~9 days). The map feels larger and more open. Balance mode is now financially viable on almost all routes.

**Tier 4:** Long-haul routes that were previously multi-day ordeals become quick runs. Earth→Titan, which took weeks in tier 1, is now a meaningful option. Turbo mode is affordable on most routes. The player's late-game decisions are about maximising revenue and managing Express/Hazardous cargo flags, not about whether they can physically reach a destination.

### Why v1 and v2 Have the Same Economy Speed

This is intentional. The v2 upgrade feels financial rather than viscerally faster — better margins, new routes. The speed improvement lands at v3, which makes that upgrade feel like a qualitative shift in how the game plays. If speed improved at every tier, upgrades would feel more uniform and less memorable.

---

## Fuel Cost Formula

```
fuel_cost = FLOOR(distance × total_mass × fuel_factor)
```

Where `total_mass = cargo_mass + 5` (the +5 represents the ship's own mass, so an empty ship still burns some fuel).

`fuel_factor` comes from `EngineData` for the current tier and chosen mode (EcoFuel, BalFuel, or TurboFuel).

### Why Mass Is in the Fuel Formula

Carrying more cargo costs proportionally more fuel. This creates the core tension: a heavier load earns more pay but leaves less fuel margin, which may force the player into a slower mode or require them to top up mid-route.

### Why There Is a Ship Mass Constant

Without the +5 ship mass, an empty ship would cost zero fuel to move, which breaks the economics of deadheading (flying empty to reposition). The constant also ensures that even the lightest possible cargo load produces a non-trivial fuel cost.

---

## Trip Duration Formula

```
duration = MAX(FLOOR(distance / speed), 1)
```

`speed` comes from `EngineData` for the current tier and chosen mode (EcoSpeed, BalSpeed, TurboSpeed). The `MAX(..., 1)` clamp ensures no trip is instantaneous — even the shortest route at the fastest engine tier takes at least 1 day.

### Why Mass Does Not Affect Duration

Trip time is a function of how fast the engine pushes the ship, not how heavy the load is. This is a deliberate simplification: if mass affected both cost *and* duration, the player would always want to fly light. Keeping duration mass-independent means a heavy load is only penalised in fuel cost, not in time — which preserves the trade-off: heavy loads earn more and cost more fuel, but don't necessarily cost more time.

---

## Pay Formula

```
base_pay = FLOOR(mass × distance × PayRate)
```

`PayRate` is a global constant, currently set to `3`.

Each applicable cargo flag adds a 50% bonus on top of base pay:

```
total_pay = base_pay + (number_of_flags × FLOOR(base_pay / 2))
```

Flags that add +50%: `Express`, `Fragile`, `Hazardous`, `Passengers`.

### Why Computed Pay Instead of Hard-Coded Pay

Pay is derived from the same distance table used for fuel costs. This guarantees that longer routes always pay more, shorter routes always pay less, and new cargo entries or route changes never require manually recalculating payouts. It also means the player can intuitively reason about value: "longer route, bigger cargo, more pay."

### Why PayRate = 3

At `PayRate = 3`, a typical inner-system run (e.g., 20t of cargo, Earth→Mars, distance 14) earns `FLOOR(20 × 14 × 3) = €840`. The fuel cost for that run at tier 1 Economy is roughly `FLOOR(14 × 25 × 1.1) = €385` at €1.2/unit. That's approximately a 54% margin — enough to feel rewarding without being easy. Balance mode on the same run costs roughly €700 in fuel, squeezing the margin to ~17%. Turbo mode exceeds the tank capacity entirely, which is exactly the intended constraint.

### Why the Flag Bonus Is +50% Per Flag (Not a Multiplier)

A flat additive bonus per flag keeps the math transparent. The player can see: "this cargo has two flags, so it pays 2× the base bonus on top of standard rate." A compounding multiplier would make multi-flag cargo disproportionately lucrative and harder to reason about.

---

## Fuel Pricing Zones

Fuel prices vary by location zone:

| Zone | Locations | Price per Unit |
|---|---|---|
| Inner system | Earth, Luna, Mars | €1.2 |
| Belt | Ceres | €1.0 |
| Outer system | Ganymede, Titan | €0.8 |

### Why Inner Fuel Is Most Expensive

This is deliberately counter-intuitive but economically motivated: inner-system locations are mature, high-demand markets. The outer system is sitting on ice deposits, helium, and methane — raw fuel is abundant and cheap if you can get there. This creates a natural incentive that reinforces the upgrade progression: push further out, pay less for fuel, make bigger profits — but you need a better engine to get there.

In early game, the player is paying premium prices at inner ports. In late game, they're refuelling cheaply at outer-system stations and turning larger margins.

---

## Cargo Flags

Flags are boolean properties stored in `CargoStats` and queried via `CargoData`. Each flag has a gameplay effect that creates a constraint or a decision.

| Flag | Pay Bonus | Constraint |
|---|---|---|
| Express | +50% | Turbo mode only; all Express cargo must share one destination |
| Fragile | +50% | No Turbo mode |
| Hazardous | +50% | Cannot mix with non-Hazardous cargo in the same hold |
| Passengers | +50% | No Turbo mode |

### Why These Specific Constraints

Each flag is designed to interact with the core mass/time/distance/efficiency trade-off in a distinct way:

- **Express** forces the player to prioritise speed over fuel cost. The higher pay partially compensates but requires either a light load (to afford Turbo) or careful fuel management.
- **Fragile** and **Passengers** remove Turbo from the table, making them inherently slower trips. The pay bonus compensates for the time cost.
- **Hazardous** forces exclusivity — you can't mix it with other cargo. This caps your earning potential per run (you're filling the hold with one contract), which the pay bonus partially offsets.

The goal is that no flag is a pure upside. Each one closes off an option while opening a financial reward, so the player is always making a real choice about whether to take the contract.

---

## The `None` Sentinel Value

`AllLocations` includes `None` as its first (lowest-value) entry. This is a sentinel used by `cargo_express_destination` to represent "no Express destination found yet." It was chosen over an integer `0` because Ink cannot compare list values to integers with `==`. `None` is always safe to use as a sentinel because no cargo is ever bound for `None`.

---

## Economic Penalties

The transit system applies economic penalties when the player neglects tasks. The design principle is "failure = complication, not disaster" — a single missed task is noticeable but not devastating, while neglecting everything can make a trip unprofitable.

### Penalty Currencies

Penalties come in two forms:

- **Fuel penalties** accumulate mid-trip in `TripFuelPenalty` and are settled on arrival by deducting from `ShipFuel`. If fuel goes to zero, a towing narrative fires with a large money penalty.
- **Money penalties** (paperwork fines) reduce delivery pay at port.

### Maintenance Backlog

Ships maintain a persistent maintenance backlog during transit. 3-4 new tasks are drawn daily via two-stage selection across three systems: engine, ship, and modules. Tasks accumulate if neglected. Tracked in four VARs:

- **`Backlog`** — current tasks (accumulates daily)
- **`StaleBacklog`** — tasks that survived yesterday without completion
- **`CompletedToday`** — tasks completed this day; becomes the cooldown exclusion for tomorrow
- **`MaintCooldown`** — yesterday's completed tasks; excluded from today's draw so players don't see the same task two days running

**Task categories:**
- Engine tasks (`EngineMaintTasks` LIST) affect `EngineCondition`. Classified by `is_engine_maint()`.
- Ship tasks (`ShipMaintTasks` LIST) affect `ShipCondition`. Classified by `is_ship_maint()`.
- Module tasks (`ModuleMaintTasks` LIST) affect the specific module they belong to. Classified by `is_module_maint()`. `maint_task_module(task)` maps each task to its parent module.

**Two-stage daily selection (`add_daily_tasks()`):**
1. **Stage 1:** Draw 3 random engine tasks + 3 random ship tasks + 1 random module task (only from installed modules) from their respective available pools, excluding current `Backlog` and `MaintCooldown`
2. **Stage 2:** Coin flip for 3 or 4, then draw that many from the combined pool of 6-7
3. **Cooldown rotation:** `MaintCooldown = CompletedToday`, then `CompletedToday = ()`

The module pool only includes tasks for installed modules (`available_module_tasks()` → `module_tasks_for(mod)`). If no modules are installed, the pool is just engine + ship (6 candidates).

**Task lifecycle (three stages):**

| Stage | How it gets there | Consequence |
|-------|------------------|-------------|
| **Fresh** | Just generated | None — player has today to do it |
| **Stale** | Survived one day without completion | Shown with "overdue" marker |
| **Auto-resolve** | In both `Backlog` and `StaleBacklog` at start of next day | Condition -5, task replaced |

**In `next_day()` each morning:**
1. **Settle stale tasks:** `Backlog ^ StaleBacklog` = tasks that survived 2 days → apply condition -5 penalty, print consequence, remove from backlog
2. **Age today's tasks:** `StaleBacklog = Backlog`
3. **Add daily tasks:** `add_daily_tasks()` — two-stage selection with cooldown rotation
4. **Drone auto-complete:** Active drone modules handle engine/ship tasks (not module tasks) from backlog, preferring stale tasks

When stale tasks are settled, those task types become available again for the next day's pool. This creates a cycle where neglect feels overwhelming but drones and diligent play keep it manageable.

**When a player completes a task:** `complete_maintenance_task(task)` removes it from both `Backlog` and `StaleBacklog`, and adds it to `CompletedToday` for tomorrow's cooldown.

**Trip initialization:** `generate_backlog()` (called from `transit()`) clears all four VARs and calls `add_daily_tasks()` to populate the first day's backlog.

**Conditions no longer degrade passively.** Engine, ship, and module conditions only change from:
- Skipped maintenance (auto-resolve penalty: -5 per task)
- Event damage (`damage_random_system()`, micrometeorite cargo hits)
- Completed maintenance (+3 on success, +1 if fatigued)
- Port repair services (restore to max condition)

### Engine Degradation Fuel Penalty

Degraded engines burn more fuel, applied at departure:

```
penalty_pct = (100 - EngineCondition) / 2
extra_fuel = FLOOR(base_cost × penalty_pct / 100)
```

At 80% condition, fuel costs are 10% higher. At 50%, they're 25% higher. This is calculated in `get_engine_fuel_penalty()` (locations.ink) and added to displayed fuel costs in `flight_options` (port.ink). The base `get_trip_fuel_cost` function is unchanged — it's also used for cargo filtering at port, where degradation shouldn't apply.

### Mid-Trip Fuel Penalties

These accumulate in `TripFuelPenalty` during transit and are settled in `settle_trip_penalties` on arrival:

| Penalty | Trigger | Amount |
|---|---|---|
| Flip delay | Each day past midpoint without flipping | +5% of trip fuel cost per day |
| Sloppy flip | Executing flip while overtired | +10% of trip fuel cost (one-time) |
| Missed nav check | Each day past `NavCheckDueDay` without completing it | +1% of trip fuel cost per overdue day |

Nav checks use a cooldown model: `NavCheckDueDay` starts at 3 and advances by 3 on each completion (`NavCheckDueDay = TripDay + 3`). A penalty tick fires in `next_day()` when `TripDay > NavCheckDueDay`, and a final tick fires in `settle_trip_penalties` on arrival if still overdue. The accumulated `NavPenaltyPct` is converted to fuel: `TripFuelCost × NavPenaltyPct / 100`.

### Paperwork Fines

Incomplete paperwork reduces delivery pay. The penalty is calculated by `get_paperwork_penalty_pct()` (cargo.ink):

```
penalty = missing_chunks × 5%
```

Each missing chunk costs 5% of delivery pay. This is applied per-item during `deliver_cargo` (port.ink) combined with cargo inspection fines and cargo damage, capped at 75% total.

### Cargo Inspection Fines

Missed cargo inspections reduce delivery pay. Inspections are a regulatory requirement: the player must inspect cargo every few days and sign off on it.

- **Base schedule:** `CargoCheckDueDay` starts at 2 and advances by the interval on each completion
- **Interval:** 3 days (base cargo), 2 days (Fragile or Hazardous cargo, via `get_cargo_check_interval()`)
- **Penalty:** 1% of delivery pay per overdue day, accumulated in `CargoCheckPenaltyPct`
- **Penalty ticks:** fire in `next_day()` when `TripDay > CargoCheckDueDay`, and a final tick in `settle_trip_penalties` if still overdue on arrival
- **Applied at delivery:** combined with paperwork and cargo damage, capped at 75%

`has_special_inspection_cargo()` (cargo.ink) returns true if any item in the hold has Fragile or Hazardous flags.

### Towing Scenario

If `TripFuelPenalty` exceeds remaining `ShipFuel` on arrival, fuel is set to 0 and the player pays a tow fee of 200% of the trip's base fuel cost. This can push `PlayerBankBalance` negative.

### Port Repair Services

The player can pay for repairs at any port (port.ink, `repair_services`). The option only appears when at least one condition is below 100%.

| Service | Effect | Cost |
|---------|--------|------|
| Engine repair | Restore EngineCondition to 100% | `(100 - condition) × 2` € |
| Cleaning service | Restore ShipCondition to 100% | `(100 - condition) × 1` € |

Ship condition no longer resets to 100% on arrival — this was a bug that has been fixed.

### Ink Integer Math Pitfall

Ink evaluates `a * b / c` as `a * (b / c)`, not `(a * b) / c`. With integer math, this causes silent truncation to zero when `b < c`. Always store the multiplication result in a temp variable before dividing:

```ink
// WRONG — penalty_pct / 100 truncates to 0 in integer math
~ return FLOOR(base_cost * penalty_pct / 100)

// CORRECT — multiply first, then divide
~ temp product = base_cost * penalty_pct
~ return FLOOR(product / 100)
```

---

## Task Priority System

The transit day presents tasks to the player via a priority-based selection system. Tasks are organized into five tiers, and the system uses Ink's threading (`<-`) and `CHOICE_COUNT()` to dynamically build the choice list.

### Priority Tiers

| Tier | Label | Selection Rule |
|---|---|---|
| P1 | Urgent | Always shown when applicable. No cap. |
| P2 | Important | Shown when stat thresholds met. Shuffled. Capped at `TaskCap - p3_floor - p4_floor`. |
| P3 | Routine | Shown on schedule or when relevant. Shuffled. Capped at `TaskCap - p4_floor`. |
| P4 | Recreation | Fills remaining slots. Shuffled. Capped at `TaskCap`. |
| P5 | Rest | Shown only when no P1–P3 tasks are active. |

`TaskCap` (default 7) controls the maximum number of top-level tasks. P3 and P4 each have a floor of 1 slot (if eligible tasks exist in that tier), ensuring the player always has at least one routine task and one recreation option.

### Threading + CHOICE_COUNT() Pattern

Ink evaluates all choices in a block simultaneously — you can't run code between them. The solution (from [inkle's official tips](https://gist.github.com/joningold/a28cc5113c6310f45fd4ad8f7958196b)) is to put each task in its own stitch, thread it into the main flow with `<-`, and use `CHOICE_COUNT()` to enforce the cap:

```ink
// Each task is threaded in if its condition is met and cap allows
{ CHOICE_COUNT() < p3_cap and LIST_COUNT(Backlog) > 0: <- task_maintenance }

= task_maintenance
+ [Ship maintenance — {LIST_COUNT(Backlog)} tasks] -> maintenance_options
```

Shuffle blocks randomize which tasks within a tier get offered first, providing day-to-day variety when more tasks are eligible than slots allow.

### Grouped Tasks and Sub-Menus

Related tasks are collapsed into single top-level entries that expand into sub-menus with flavor text:

- **Sleep** (P2 when fatigue ≥ 70, P4 when 30–69) → nap (1 AP), full sleep (2 AP)
- **Relax** (P4, always) → cook a special meal (2 AP), workout (1 AP), movie (2 AP), video games (1 AP, Entertainment active), listen to music (1 AP, Entertainment active)
- **Ship maintenance** (P3, when backlog has tasks) → shows all backlog tasks (1 AP each), stale tasks marked "overdue"
- **Engine care** (P2, when condition < 80) → run diagnostics (2 AP)

Each sub-menu includes a free "Never mind" back option. After completing a sub-task, the player returns to the top-level task list.

### has_tier_tasks() Function

The `has_tier_tasks(tier)` function (ship.ink) centralizes the "are there eligible tasks at this priority?" check. It's used for floor calculations and Rest gating. When adding new tasks to any tier, update the appropriate case in this function.

### Adding a New Task

1. Add an entry to the appropriate task registry list (`P2Tasks`, `P3Tasks`, or `P4Tasks` in ship.ink) — this keeps the shuffle loop count in sync automatically
2. Write a `task_*` stitch that injects one choice (and optionally a `*_options` sub-menu stitch)
3. Add a `{ CHOICE_COUNT() < cap and condition: <- task_* }` line in the appropriate priority section of `ship_options`
4. Update `has_tier_tasks()` with the new task's condition in the appropriate tier

### Key Variables

- `TaskCap` — Maximum top-level tasks shown (excluding P5 Rest). Default 7.
- `TasksCompletedToday` — Incremented by `pass_time()`, reset by `next_day()` and `transit()`.

### Fatigue and Task Failure

When fatigue is 70 or above, work tasks are subject to a dice roll that can cause failure or degraded outcomes. The `fatigue_check()` function (ship.ink) handles this using `RANDOM(1, 100)` with three escalating tiers:

| Fatigue | Failure Chance | Exhaustion Warning |
|---------|---------------|--------------------|
| 0–69 | 0% | None |
| 70–79 | 20% | "Running on fumes" |
| 80–89 | 40% | "Hands are shaking" |
| 90+ | 70% | "Barely function" |

**Two failure modes:**

- **Degraded** (ship flip, engine tune, backlog maintenance) — The task completes but with a reduced effect. Ship flip adds a fuel penalty. Engine tune restores +8 instead of +15. Backlog maintenance restores +1 instead of +3.
- **Fail + retry** (nav check, cargo inspection, paperwork) — The task doesn't count. The due day is not advanced, so the task remains available for retry. AP is still spent.

Only "work" tasks use `fatigue_check()`. Sleep, recreation, eating, and rest are unaffected.

`is_overtired()` is still used for UI concerns (P2 sleep threshold, task offering logic). `fatigue_check()` is used for task outcome resolution.

### Random Events

Random events are P0 interruptions that fire during transit, bypassing the task list entirely. All event code lives in `events.ink`.

**Triggering:** Each time `ship_options` is entered, an escalating probability check fires. `EventChance` starts at 0 and increases by 3 per check. When an event fires, `EventChance` resets to 0 and `EventCooldownDay` is set to the current `TripDay` to prevent a second event the same day.

**Event selection:** When triggered, `random_event` picks randomly from eligible events. Some events have eligibility conditions:
- **Cargo shift** — only eligible when the player has cargo (static check at trip start)
- **Shortcut** — only eligible when `ShipClock > 1` (dynamic check each roll)
- **Passenger events** — only eligible when the player has passenger cargo (static check at trip start)

**Passenger event eligibility:** The `PassengerEvents` VAR holds the subset of events that require passengers. In `transit()`, `Events -= PassengerEvents` removes all passenger events in one operation when no passenger cargo is aboard. To add a new passenger event, add it to both the `Events` LIST and the `PassengerEvents` VAR (they are adjacent in `events.ink`).

**`has_medical_module()`:** Returns `is_module_active(WellnessSuite)`. Used by the medical emergency event to improve patient outcomes — better recovery odds and no possibility of a fatal outcome when the suite is active (condition >= 50%).

**Passenger satisfaction impacts:** All four passenger events and the coffee machine event modify `PassengerSatisfaction` (guarded by `InstalledModules ? PassengerModule`). See the event tables in `events.ink` for the specific values. The coffee machine event affects satisfaction if passengers are present (the lack of coffee hits harder with an audience).

**Cargo damage:** `CargoDamagePct` accumulates cargo damage during transit (micrometeorite cargo hit, cargo shift with fatigue failure). It reduces delivery pay at port alongside paperwork and inspection penalties. Total combined penalty is capped at 75%. It only increases from event outcomes — normal transit never touches it.

**`damage_random_system(amount)`:** Damages a random system — 50% chance engine, 50% chance a random installed module. If no modules are installed, always damages engine. Module condition floors at 1 (not 0, since 0 = not installed).

**Adding a new event:**
1. Add an entry to the `Events` LIST in `events.ink`
2. If the event requires passenger cargo, also add it to the `PassengerEvents` VAR
3. Write an `event_*` knot in `events.ink`
4. Add a dispatch line in `random_event`: `{ chosen == Name: -> event_name }`
5. If the event has a dynamic eligibility condition, add a removal line in `random_event`

---

## Module System

Ship modules automate routine tasks, reducing the daily AP burden as the player progresses. Module infrastructure lives in `modules.ink`; VARs and LISTs are declared in `space-truckers.ink`.

### Data Model

Modules follow the same LIST + function lookup pattern as cargo, locations, and engines:

- **`ShipModules` LIST** — all module types
- **`ModuleStats` LIST** — stat keys (`ModName`, `ModPrice`, `ModDesc`)
- **`ModuleData(module, stat)`** — returns the requested stat
- **Per-module condition VARs** — `RepairDronesCondition`, `CleaningDronesCondition`, etc. (0 = not installed, 1-100 = condition)
- **`InstalledModules` VAR** — LIST of currently installed modules
- **`RefurbishedModules` VAR** — subset bought refurbished (80% max condition cap)

### Graduated Effectiveness

| Condition | Drone Effect | Other Modules |
|-----------|-------------|---------------|
| 75-100% | Auto-complete 2 tasks/day | Full effect |
| 50-74% | Auto-complete 1 task/day | Reduced effect |
| Below 50% | Offline | Offline |

### Module Auto-Tasks

All module daily behavior runs via the `module_auto_tasks` tunnel, called from `next_day()` (after settle → age → add daily tasks) and at trip start (after `generate_backlog()`).

- **Repair Drones** (800€) — auto-complete engine maintenance tasks from backlog. Prefer stale tasks. Capacity: 2 at 75%+, 1 at 50-74%.
- **Cleaning Drones** (600€) — auto-complete ship maintenance tasks from backlog. Same capacity tiers as Repair Drones.
- **Auto-Nav Computer** (500€) — auto-completes nav checks. Full (75%+): completes every check. Reduced (50-74%): completes on even `TripDay` only. Advances `NavCheckDueDay = TripDay + 3` on completion.
- **Cargo Management System** (700€) — handles both cargo inspections and paperwork (1 task/day, inspections prioritized). Full (75%+): completes every task due. Reduced (50-74%): completes on even `TripDay` only. Inspections take priority because they expire (day-of only); paperwork persists until delivery. Advances `CargoCheckDueDay = TripDay + get_cargo_check_interval()` on inspection completion.

- **Entertainment System** (400€) — improves recreation. Full (75%+): all recreation (cooking, workout, movie, video games, music) gets a +50% morale bonus via `apply_recreation_bonus(base)`. The bonus uses integer math: `base + base / 2`. Reduced (50-74%): video games and music are available (module is active), but no morale bonus. Below 50%: offline, no extra options. Video games and music appear inside the "Take a break" → `relax_options` sub-menu when Entertainment is active (not as standalone P4 choices). They are gated with `{ is_module_active(Entertainment) }` inline choice guards inside `relax_options`.

- **Wellness Suite** (500€) — daily fatigue/morale benefit and medical emergency improvement. Full (75%+): -5 fatigue, +2 morale per day. Reduced (50-74%): -3 fatigue, +1 morale. Applied in `module_auto_tasks` with narrative flavor text (gym, autodoc, sunlight simulator, therapy, haircut). Also wires `has_medical_module()` → `is_module_active(WellnessSuite)` to improve medical emergency outcomes.

- **Passenger Module** (tiered, separate upgrade path) — gates passenger cargo and drives the satisfaction system. Unlike other modules, this has a `PassengerModuleTier` VAR (0=not installed, 1-3=tier) and a separate purchase/upgrade UI stitch (`passenger_module_upgrades`) that is linked from `upgrade_menu` but excluded from the standard `browse_module_list`. Tier is upgraded sequentially (T0→T1→T2→T3); pricing is cumulative (200/400/800€ total, delta charged per upgrade). The refurbished option is only available at initial install (T0→T1). Passive satisfaction bonus activates at T2+.

### Module Maintenance (Two Layers)

1. **Random event damage:** `damage_random_system()` — 50% chance engine, 50% chance random installed module
2. **Backlog maintenance tasks:** Each installed module contributes 2 tasks to the `ModuleMaintTasks` pool. Completing a task boosts that specific module's condition by +3 (+1 if fatigued). Neglecting a task auto-resolves with -5 to that specific module (floor at 1). Module maintenance replaces the old periodic diagnostic system.
3. **Port repair:** Pay to restore module conditions. Cost: `(max_condition - condition) × price / 100`

### Purchase UI

Port menu option `[Ship upgrades]` diverts to `ship_upgrades` in `modules.ink`. Offers:
- **Buy new** — full price, 100% condition
- **Buy refurbished** — 50% price, 60% starting condition, 80% max cap
- **Repair** installed modules

### Adding a New Module

1. Add an entry to `ShipModules` LIST in `space-truckers.ink`
2. Add a condition VAR (e.g., `VAR NewModuleCondition = 0`) in `space-truckers.ink`
3. Add a row to `ModuleData()` in `modules.ink`
4. Add cases to `get_module_condition()` and `set_module_condition()` in `modules.ink`
5. Add 2 new entries to `ModuleMaintTasks` LIST in `space-truckers.ink`
6. Add mappings for those tasks in `maint_task_module()` and `module_tasks_for()` in `modules.ink`
7. Add cases for those tasks in `MaintName()`, `MaintComplete()`, `MaintFatigued()`, `MaintOverdue()` in `ship.ink`
8. Wire module-specific behavior:
   - For maintenance auto-complete or daily passive effects: add a stitch in `module_auto_tasks` (modules.ink)
   - For task list effects: gate tasks with `is_module_active(Module)` in `ship_options`
   - For event/combat effects: update the relevant function (e.g., `has_medical_module()`)

---

## Adding New Content

### New Cargo Entry

Add a line to `CargoData` in `cargo.ink` using `cargo_db`:

```ink
- NNN_Name:
    ~ return cargo_db(data, FromLocation, ToLocation, massInTons, "display name", isExpress, isFragile, isHazardous, isPassengers)
```

Pay is computed automatically from mass and distance. No manual payout calculation needed.

If you set `isPassengers = 1`, also add the item to the `PassengerCargo` VAR at the top of `cargo.ink`. This VAR is a subset of `AllCargo` used by the injection nudge (see below) to avoid iterating all 600+ items on every port visit.

### Passenger Cargo Availability and Injection Nudge

Ports vary in how many passenger cargo items they offer. Earth and Mars have the most passenger options (~14 and ~11 items respectively), while remote outposts like Ganymede and Titan have fewer (~4 and ~5). This reflects the in-world reality that busy inner-system ports see heavier passenger traffic.

**The injection nudge** further improves the odds that passenger cargo appears in a port draw when the player has the Passenger Module installed:

- `get_available_cargo` draws 5 items via `validated_list_random_subset_of_size`
- After the draw, if the Passenger Module is installed and no passenger item was drawn naturally, there is a **50% chance** one randomly selected item in the result is replaced with a random available passenger cargo item from that port
- The replacement item is drawn from `PassengerCargo` filtered by `cargo_is_available` (i.e., it must originate at the current port and pass all standard availability checks)

The nudge is implemented via three functions in `cargo.ink`:
- `has_passenger_in_list(items)` — recursive check for any Passengers flag in a list
- `get_random_passenger_cargo(port)` — builds the available pool from `PassengerCargo` and returns `LIST_RANDOM`
- `_build_passenger_pool(items, port)` — recursive helper that filters the pool by `cargo_is_available`

### New Location

1. Add the location to `AllLocations` in `locations.ink`
2. Add a row to `LocationData` with distances to all other locations
3. Add a column to `location_db` for the new location
4. Add a fuel price case to `get_fuel_price`

### New Engine Tier

Add a row to `EngineData` in `space-truckers.ink`. Use the tier progression table above as a guide — each tier should make at least one mode feel qualitatively different from the previous tier, not just numerically better.

---

## Running the Compiler

After any changes to `.ink` files, always validate before committing:

```bash
npm run lint
```

This compiles the full story from `space-truckers.ink` and reports any errors. `TODO:` messages are informational; `ERROR:` lines must be fixed before the game will run.
