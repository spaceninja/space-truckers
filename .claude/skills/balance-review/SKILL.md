---
name: balance-review
description: "Review the game economy for balance issues: route viability, progression pacing, module ROI, and resource pressure. Reads current Ink source constants and outputs a scored report."
argument-hint: "[early-game | progression | routes | cargo | modules | resources]"
user-invokable: true
---

When this skill is invoked:

## 1. Read Current Economy State

Read the following files to extract current constants. Do not rely on memory — read the actual source.

- `space-truckers.ink` — starting VARs (`PlayerBankBalance`, `ShipFuel`, `ShipFuelCapacity`, `PayRate`, `ShipEngineTier`), `EngineData` lookup table (all tiers, all manufacturers, all modes: fuel factor and speed)
- `locations.ink` — distance matrix (`get_distance`), fuel prices per zone (`FuelPrice`)
- `cargo.ink` — `CargoData` table (mass and flags for each cargo item), `get_cargo_pay` formula
- `modules.ink` — `ModuleData` table (new price, refurb price, refurb condition), condition thresholds and their effects
- `ship.ink` — maintenance task rates, AP costs, fatigue accumulation per mode, fatigue failure thresholds, morale decay and boosts, module automation effects
- `port.ink` — engine repair cost formula, ship cleaning cost formula, delivery penalty formula
- `simulator.html` — break-even and feasibility crossover formulas

If an argument was provided (e.g., `/balance-review modules`), focus on that category's section but still read all files, since cross-system interactions may be relevant.

## 2. Run the Balance Checklist

For each category, compute specific numbers from the extracted constants. Show your work.

### Category 1: Early Game — Tier 1 Viability

**Goal:** A new player with 200€ starting balance should be able to profit on at least some routes, understand that outer routes require progression, and not feel trapped.

Checks:
- For each of the 15 non-trivial routes (all station pairs), compute: fuel cost at T1 Eco and T1 Balance mode, minimum feasible cargo mass, break-even cargo mass, and profit margin at the lightest available cargo.
- Flag any route where T1 Eco is **impossible** (fuel cost exceeds tank capacity at any cargo mass).
- Flag any route where T1 Balance is impossible.
- Check whether starting balance (200€) covers a full fuel load plus a 20€ buffer on at least 3 inner routes.
- Check whether the tutorial path (Earth → nearby station) produces a clear profit.

Formula reminders (from simulator):
```
fuel_cost = floor(distance * (cargo_mass + 5) * fuel_factor)
pay = floor(cargo_mass * distance * PayRate)
profit = pay - (fuel_cost * fuel_price_per_unit)
max_feasible_mass = fuel_cap / (distance * fuel_factor) - 5
break_even_mass = (5 * fuel_factor * fuel_price) / (PayRate - fuel_factor * fuel_price)
```

### Category 2: Progression Pacing

**Goal:** The cheapest upgrade should be reachable in 2–4 trips. No dead zone longer than ~6 trips where the player has money for nothing useful.

Checks:
- Estimate average profit per trip for a competent T1 player (use a mid-range inner route, clean run, no events, one cargo item at median mass).
- Compute how many such trips to afford each module (cheapest first, then by price).
- Compute how many trips to afford each engine tier upgrade (note: engine upgrade system is currently TODO — flag this if prices are not defined).
- Identify any "dead zones": gaps in the upgrade ladder where the player has earned enough to buy the previous thing but not the next one, and must grind without a goal.
- Check whether refurbished modules (at 60% condition, 80% max) meaningfully shorten the time to first upgrade vs. buying new.

### Category 3: Route Viability

**Goal:** Every engine tier should have a "sweet spot" of profitable routes. Outer routes should feel aspirational, not impossible. Fuel price zones should create real decisions.

Checks:
- For each engine tier and manufacturer, identify: which routes are profitable at each mode (Eco / Balance / Turbo), which are marginal (profit < 50% of fuel cost), and which are traps (fuel cost exceeds pay).
- Check whether Turbo mode is ever worth using for profit vs. Eco on the same route (it should be, at least for Express cargo).
- Check whether the Ceres fuel discount (1.0 vs 1.2 at inner planets) creates a meaningful incentive to route through the Belt.
- Check whether any route is *always* dominated (never the best choice regardless of mode or engine tier).

### Category 4: Cargo Economy

**Goal:** Flag bonuses (+50% each) should compensate for real constraints. Express should require commitment but reward it. Fragile and Hazardous should be "risky but worth it" decisions, not traps.

Checks:
- Compute the break-even point for Express cargo: at what Turbo fuel cost does the +50% bonus stop being worth it? Is this threshold reachable?
- Check whether Fragile (forces non-Turbo, +50% pay) is better than taking the same cargo without the flag on a Balance run.
- Check whether Hazardous (+50% pay, no mixing) is worth the opportunity cost of locking out all other cargo.
- Check whether Passengers (+50% pay, no Turbo, blocks non-passenger events) are worth carrying on long routes where event income could exceed the bonus.
- Compute max theoretical pay per trip (best flags, heaviest cargo, longest route at appropriate tier) and check it feels meaningfully larger than a standard run.

### Category 5: Module ROI

**Goal:** Modules should have a believable payoff period (not "I'll never afford this" and not "it pays for itself in 1 trip"). The buy order should be situational, not obviously optimal.

For each module, estimate ROI in trips:
- **Repair Drones (800€ new / 400€ refurb):** Saves ~1–2 maintenance tasks/day depending on condition. Each auto-completed task avoids 1 AP spend + prevents a stale-task penalty of -5 condition. Estimate saved repair cost per trip.
- **Cleaning Drones (600€ new / 300€ refurb):** Saves ship condition degradation. Estimate how many cleaning service costs (1€/point) are avoided per trip.
- **Auto-Nav Computer (600€ new / 300€ refurb):** Avoids +10% fuel penalty per missed nav check (checks every 3 days). Estimate fuel savings per trip by route length.
- **Cargo Management (500€ new / 250€ refurb):** Reduces paperwork AP burden (files 1 chunk/day or every other day). AP is limited; saved paperwork AP can go to maintenance or rest.
- **Entertainment System (400€ new / 200€ refurb):** +50% recreation morale boosts. Estimate morale impact on AP availability (morale < 40 → lose 1 AP, < 20 → lose 2 AP).
- **Wellness Suite (500€ new / 250€ refurb):** -5 fatigue/+2 morale daily (at 75%+). On long trips, prevents fatigue spiral that causes 40–70% task failure rates.

Flag if any module's ROI period exceeds 15 trips (likely not worth buying before upgrading engines instead).

Flag if the buy order is too obvious (e.g., one module always dominates — this removes interesting decisions).

### Category 6: Resource Pressure

**Goal:** Fatigue, morale, and ship condition should create tension without causing unavoidable death spirals. The player should feel challenged, not punished.

Checks:
- **Fatigue spiral:** On a long outer route (e.g., Earth→Titan, 52 distance units, ~10–13 trip days at T1 Balance), estimate daily fatigue accumulation (10/AP × 6 AP = 60/day baseline). Can the player keep fatigue below 70 without sacrificing all maintenance? What breaks first?
- **Morale spiral:** At what morale level does AP reduction kick in (< 40)? How many days of -1 morale/day to get there from 80? What morale boosts are available without consuming more than 1 AP?
- **Condition death spiral:** If ship condition falls below 50, morale decays at -3/day instead of -1/day. How quickly can a neglected ship push the player into AP reduction?
- **Backlog pressure:** 4 tasks added daily, max 8 in backlog. Each neglected task auto-resolves after 2 days with -5 condition penalty. Can a solo player (no drones) keep up without spending all AP on maintenance?
- **Fatigue task failure:** At 70+ fatigue, 20–70% of tasks fail. Check whether this failure rate makes maintenance unsustainable on long routes without wellness module or fatigue management.

## 3. Cross-System Cascade Check

After completing individual categories, check for dangerous cascades:

- **Engine degradation cascade:** Engine at 50% condition → +25% fuel cost. On a marginal route, does this push the run into a loss? How quickly can engine condition drop without drones?
- **Missed diagnostic cascade:** Every 5 days, diagnostic task appears. Missing it by 2+ days applies -5 to ALL module conditions. Does this create a catastrophic condition drop if the player is busy?
- **Long route compounding:** Events fire probabilistically (+3% EventChance per action). On a 13-day trip, events are nearly certain. Does the expected event damage materially change route economics?

## 4. Write the Report to a File

Do not print the report to the terminal. Instead, write it to a file using the Write tool.

**File path:** `reports/balance-review-YYYY-MM-DD.md` inside the project root (e.g. `reports/balance-review-2026-04-01.md`). Use today's actual date. The `reports/` directory may not exist yet — create the file directly; the Write tool will handle it.

**After writing:** Print one line to confirm: `Report written to reports/balance-review-YYYY-MM-DD.md`

Use this format for the file content. If a topic argument was given, include only the relevant section(s) plus the Session Test.

```markdown
# Balance Review — Space Truckers
*Generated: YYYY-MM-DD*

### Early Game: [Healthy ✓ | Watch ⚠️ | Concern ❌]
[Findings with specific numbers. Flag impossible routes, marginal margins, starting balance adequacy.]

### Progression Pacing: [Healthy ✓ | Watch ⚠️ | Concern ❌]
[Trips-to-upgrade for each module and engine tier. Identify any dead zones.]

### Route Viability: [Healthy ✓ | Watch ⚠️ | Concern ❌]
[Per-tier profitable/marginal/trap route summary. Call out dominant or useless routes.]

### Cargo Economy: [Healthy ✓ | Watch ⚠️ | Concern ❌]
[Flag bonus value vs. constraints. Break-even thresholds. Best and worst flags by route type.]

### Module ROI: [Healthy ✓ | Watch ⚠️ | Concern ❌]
[ROI per module in trips. Buy order analysis. Refurb vs. new value.]

### Resource Pressure: [Healthy ✓ | Watch ⚠️ | Concern ❌]
[Fatigue/morale/condition spiral risks. Sustainable task load without modules.]

### Cross-System Cascades
[Any dangerous compounding effects found across categories.]

### Session Test
Based on the economics: would a new player see meaningful progress and face at least one interesting decision within their first few trips? Estimate what that looks like.

### Recommendations
[Prioritized list. Lead with the most impactful issue. Note "clean run" assumption — random events and player error are not modeled.]
```

## Rules

- Show the math. Don't just say "this route is unprofitable" — show the fuel cost vs. pay.
- Flag assumptions explicitly (e.g., "assuming median cargo mass of 15t").
- Note when something can't be checked because it's not yet implemented (e.g., engine upgrade pricing if TODO).
- "Healthy" means the numbers work and the design intent is served. "Watch" means a potential issue that warrants playtesting. "Concern" means a likely problem that should be addressed before release.
- Do not suggest fixes — flag issues for the designer to resolve. The exception is when a fix is a trivial constant change (e.g., "increasing PayRate from 3 to 3.2 would resolve the Titan route profitability concern").
- This is a "clean run" analysis. Random events, player error, and event damage are not modeled. Note this in the report.
