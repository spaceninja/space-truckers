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

Each tier has seven stats: `FuelCap`, `EcoFuel`, `EcoSpeed`, `BalFuel`, `BalSpeed`, `TurboFuel`, `TurboSpeed`.

| Tier | FuelCap | EcoFuel | EcoSpeed | BalFuel | BalSpeed | TurboFuel | TurboSpeed |
|---|---|---|---|---|---|---|---|
| 1 (starter) | 300 | 1.1 | 1.0 | 2.0 | 1.5 | 4.0 | 2.5 |
| 2 | 500 | 0.8 | 1.0 | 1.5 | 2.0 | 3.0 | 3.0 |
| 3 | 650 | 0.5 | 1.5 | 0.9 | 2.5 | 1.8 | 4.0 |
| 4 | 800 | 0.3 | 2.0 | 0.6 | 3.5 | 1.2 | 5.0 |

`FuelFactor` values are multipliers in the fuel cost formula (lower is better). `Speed` values are divisors in the trip duration formula (higher is faster).

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

### Engine Degradation

Engine condition degrades 1% per day during transit. Degraded engines burn more fuel, applied at departure:

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
| Missed nav check | Not doing a nav check when offered | +10% of trip fuel cost per missed check |

Nav checks appear every 3 days (`TripDay mod 3 == 0, TripDay > 0`). Expected check count: `(TripDuration - 1) / 3`.

### Paperwork Fines

Incomplete paperwork reduces delivery pay. The penalty is calculated by `get_paperwork_penalty_pct()` (cargo.ink):

```
penalty = MIN(missing_chunks × 10, 50)%
```

Each missing chunk costs 10% of delivery pay, capped at 50%. This is applied per-item during `deliver_cargo` (port.ink).

### Towing Scenario

If `TripFuelPenalty` exceeds remaining `ShipFuel` on arrival, fuel is set to 0 and the player pays a tow fee of 200% of the trip's base fuel cost. This can push `PlayerBankBalance` negative.

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
{ CHOICE_COUNT() < p3_cap and ShipCondition < 80: <- task_ship_maint }

= task_ship_maint
+ [Tidy up the ship] -> ship_maint_options
```

Shuffle blocks randomize which tasks within a tier get offered first, providing day-to-day variety when more tasks are eligible than slots allow.

### Grouped Tasks and Sub-Menus

Related tasks are collapsed into single top-level entries that expand into sub-menus with flavor text:

- **Sleep** (P2 when fatigue ≥ 70, P4 when 30–69) → nap (1 AP), full sleep (2 AP)
- **Relax** (P4, always) → heat rations (1 AP), workout (1 AP), movie (2 AP)
- **Ship maintenance** (P3, when condition < 80) → clean filters (1 AP), more in future
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

- **Degraded** (ship flip, engine maintenance, ship maintenance) — The task completes but with a reduced effect. Ship flip adds a fuel penalty. Engine maintenance restores +8 instead of +15. Ship maintenance restores +5 instead of +12.
- **Fail + retry** (nav check, paperwork) — The task doesn't count. The counter is not incremented, so the task remains available for retry. AP is still spent.

Only "work" tasks use `fatigue_check()`. Sleep, recreation, eating, and rest are unaffected.

`is_overtired()` is still used for UI concerns (P2 sleep threshold, task offering logic). `fatigue_check()` is used for task outcome resolution.

---

## Adding New Content

### New Cargo Entry

Add a line to `CargoData` in `cargo.ink` using `cargo_db`:

```ink
- NNN_Name:
    ~ return cargo_db(data, FromLocation, ToLocation, massInTons, "display name", isExpress, isFragile, isHazardous, isPassengers)
```

Pay is computed automatically from mass and distance. No manual payout calculation needed.

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
