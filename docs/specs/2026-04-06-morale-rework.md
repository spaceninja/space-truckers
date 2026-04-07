# Design: Morale Rework & Stat Consolidation

Issue: #38

## Context

Morale and Ship Condition don't create meaningful gameplay decisions. Fatigue and Engine Condition work well because they have clear mechanical consequences (task failure, fuel costs). Morale's only effect (AP loss at <40/<20) is easy to avoid, and Ship Condition only modifies Morale's decay rate — a modifier on a stat that barely matters.

The goal is to **streamline gameplay mechanics** while **adding narrative richness**. Instead of optimizing numbers, the player should be motivated to take care of themselves and their ship because the narrative makes them *want* to — like the hot springs in Ghost of Tsushima.

## Design

### 1. Drop Morale Stat

Remove `VAR Morale` and everything connected to it:

- Daily decay in `next_day()`
- AP penalties at <20 and <40
- All `Morale = MIN/MAX(...)` modifications in ship.ink, events.ink, modules.ink
- `apply_recreation_bonus()` function

### 2. Drop Recreation Menu

Remove all fixed recreation tasks from the P4 tier:

- Relax (generic)
- Cook (fresh ingredient / standard recipe) — rework special ingredients into triggered narrative moments (see §8)
- Video Games (Entertainment module)
- Listen Music (Entertainment module)

The P5 "skip day" rest option remains.

### 3. Flatten Task Menu & Revise Priorities

Remove all submenus (engine options, maintenance options, relax options). All tasks appear as top-level choices. Simplify the cap system: drop the tier floor reservation (`p3_floor`/`p4_floor`). Just fill by priority up to `TaskCap` (7): P1 first, then P2, P3, P4.

**Revised task priorities:**

| Task | Priority | Condition |
|------|----------|-----------|
| Ship flip | P1 | Mid-trip, one-time |
| Nav check | P2 | Timer-based (every 3 days) |
| Cargo inspection | P2 | Timer-based (every 2-3 days) |
| Urgent sleep | P2 | Fatigue ≥ 70 |
| Maintenance (×3-4) | P3 | Daily backlog draw |
| Passenger task | P3 | Daily if passengers aboard |
| Paperwork | P4 | Until per-trip quota met |
| Narrative moment (task-type) | P4 | When triggered (0-1 per day) |
| Sleep (optional) | P4 | Fatigue 30-69 |
| Skip day | P5 | No P1-P3 active |

**P3 sub-priority ordering:** When not all P3 tasks fit, display in this order:
1. Overdue (stale) maintenance tasks — about to auto-resolve with -5 penalty
2. Passenger task — daily skip penalty (-3 satisfaction)
3. Fresh maintenance tasks — no immediate penalty for deferring

On heavy days, P4 items (paperwork, sleep, narrative moments) may not appear — this is intentional. They surface on quieter days when urgent work is caught up.

### 4. Cut Entertainment System & Wellness Suite Modules

**Entertainment System** — its purpose was boosting morale from recreation. With morale gone and the recreation menu gone, it has no role. Remove the module, its `ModuleData` entry, purchase UI, maintenance tasks, and all `is_module_active(Entertainment)` checks.

**Wellness Suite** — provided daily morale + fatigue reduction. With morale gone, it's just a small fatigue reducer. Not compelling enough to justify a module slot. Remove it, its `ModuleData` entry, purchase UI, maintenance tasks, `has_medical_module()` in events.ink, and all condition checks.

### 5. Merge EngineCondition + ShipCondition → Unified ShipCondition

Merge into a single `ShipCondition` stat representing overall ship health (engine, hull, cleanliness, life support, everything).

- `ShipCondition` inherits EngineCondition's **fuel cost penalty**: `penalty_pct = (100 - ShipCondition) / 2`
- Remove `VAR EngineCondition` — all references become `ShipCondition`
- Port repair services apply to `ShipCondition` (and per-module conditions separately)
- `get_engine_max_condition()` → `get_ship_max_condition()` (or unify with existing)
- `RefurbishedEngine` VAR → consider if this concept still applies to the unified stat

**Condition-gated urgency:** When `ShipCondition < 60`, some daily maintenance tasks escalate — they give **+5** condition instead of +3 and are narratively framed as emergency fixes. This replaces the old engine tune P2 task as the catch-up mechanism.

**Cut the engine tune P2 task.** Recovery from low condition now comes from: (a) urgency-boosted maintenance tasks during transit, and (b) port repairs.

### 6. Unify Maintenance Tasks

Merge `EngineMaintTasks` and `ShipMaintTasks` into a single `MaintTasks` LIST. `ModuleMaintTasks` stays separate in tracking (affects per-module condition) but joins the same daily draw pool.

- One unified daily draw: pick N tasks from the combined pool (MaintTasks + available ModuleMaintTasks)
- All MaintTasks affect `ShipCondition`; ModuleMaintTasks still affect their specific module
- Remove `is_engine_maint()` / `is_ship_maint()` — replace with a single `is_maint_task()` or just check pool membership
- Expand the task LIST with more variety for narrative flavor (the player sees "recalibrate sensors," "patch hull micro-fracture," "clean air filters," "do laundry" — all mechanically identical but narratively distinct)
- One-day cooldown and two-day aging system stays as-is

### 7. Simplify Drones

Rework the Drone Bay module:

- **One drone type** — no more engine/ship drone split
- Each drone completes **N tasks/day** from the full pool (ship maintenance + module maintenance)
- Players can own **up to 2 drones** (either via upgrade tiers or purchasing a second Drone Bay)
- Stale tasks prioritized (existing behavior, just unified)
- Remove `get_drone_capacity()` engine/ship split logic

**Open question for implementation:** How to model 2 drones — single Drone Bay module with tier upgrade (like PassengerModule), or allow purchasing two separate Drone Bay modules? Tier upgrade is simpler.

### 8. Triggered Narrative Moments

Replace the recreation menu with **triggered narrative moments** — contextual scenes that appear when conditions are met. Each is a short narrative tunnel (2-5 choices deep) with a specific reward.

#### Two delivery modes

**Task-type moments** — appear as P4 task options in the daily menu. The player chooses to engage. Cost 1 AP. Examples: cooking with purchased ingredients, playing cards with passengers.

**Interrupt-type moments** — fire automatically like random events, before the daily task menu. The player doesn't choose whether they happen — only how they respond. Examples: the "you've been grinding" nudge, environmental observations, cat moments.

#### Trigger framework

Each narrative moment needs:
- **Delivery mode** — task (player opts in) or interrupt (fires automatically)
- **Trigger condition** — what makes it eligible
- **One-time gate** — most moments fire once per trip or once ever (tracked via flags)
- **Narrative tunnel** — the scene itself (2-3 player choices, deliberate pacing)
- **Reward** — decorative, social, practical, or purely narrative

#### Six example moments

**A. Port purchase — "Strawberry Shortcake"** *(task-type)*
- *Trigger:* Player bought fresh strawberries at port. `HasStrawberries` flag set.
- *Gate:* One-time per purchase (flag cleared after scene plays). Ingredient cannot be re-purchased.
- *Scene:* You're in the galley. Choose your approach to the recipe. Mind wanders while it bakes. Choose a reflection topic.
- *Reward:* Decorative — "the galley still smells like baking" appears in next day's ship descriptions.

**B. Progression milestone — "First time at Ceres"** *(interrupt-type)*
- *Trigger:* First arrival at a specific port. `VisitedCeres` flag not yet set.
- *Gate:* Once ever.
- *Scene:* You see the dwarf planet up close — the mining rigs, the distant sun, the sense of being truly far from home. Choose what strikes you. Brief reflection.
- *Reward:* Narrative — a memory flag that can be referenced in future descriptions and events. ("You remember your first time here...")

**C. Companion — Cat moments** *(interrupt-type)*
- *Trigger:* `HasCat` is true (set via cheat menu for now). Each day, ~15% chance.
- *Gate:* Each specific cat scene fires once ever (a pool of 4-5 one-time cat scenes).
- *Scene:* The cat does something: curls up on the nav console, knocks a tool off the workbench, sits in your lap at dinner, chases a reflection across the hull. Brief, warm, specific.
- *Reward:* Decorative — cat references start appearing in other descriptions (maintenance text, cooking, sleeping). The ship feels less empty.

**D. Passenger-driven — "Card game invitation"** *(task-type)*
- *Trigger:* Passengers aboard (`InstalledModules ? PassengerModule` and carrying passenger cargo). Random chance per trip.
- *Gate:* Once per trip.
- *Scene:* A passenger knocks on the cockpit door, offers to play cards. Choose how you engage: play competitively, play casually and chat, or share stories instead of playing. Each branch has a short beat.
- *Reward:* Passenger satisfaction boost (+5).

**E. Routine/grinding — "You've been at this for days"** *(interrupt-type)*
- *Trigger:* Player has chosen only work tasks (maintenance, nav check, cargo inspection) for 3+ consecutive days with no narrative moments or sleep beyond minimum.
- *Gate:* Once per trip.
- *Scene:* You finish the last task of the day and realize your hands are sore, your back aches, and you can't remember the last time you looked out the window. Your attention drifts — choose what catches it: the viewport and the stars, an old photo tucked in a panel, the silence of the ship.
- *Reward:* Purely narrative — the game acknowledging the grind. Potentially a decorative flag ("the photo" or "the view") that gets callbacks.

**F. Environmental — "Asteroid belt passage"** *(interrupt-type)*
- *Trigger:* Current route passes through the belt (specific port pairs, e.g., Mars→Ceres, Mars→Jupiter routes). Random chance on qualifying days.
- *Gate:* Can fire once per qualifying trip (not once ever — this is a repeatable ambient moment with some text variation).
- *Scene:* Rocks drift past the viewport, close enough to see their surfaces. The ship's collision system pings softly. It's beautiful and a little unnerving. Choose whether to watch, adjust course slightly, or just note it and get back to work.
- *Reward:* Narrative texture — brief, atmospheric, no mechanical effect. The kind of moment that makes a trip memorable.

### 9. Ship Personalization Tracking

A `LIST Personalizations` (or set of VARs/flags) tracks what the player has done to make the ship home:

- Decorative purchases (bobblehead, painted galley, reupholstered chair)
- Narrative moment outcomes (the photo, the baking smell, cat-related changes)
- Milestone memories (first visit flags)

These flags are checked in existing description text to add conditional flavor. Over multiple trips, the ship's descriptions become richer and more personal. This is the compounding reward — the more you engage with narrative moments, the more alive the world feels.

**Implementation:** Simple boolean VARs or a LIST. Checked with `{ HasBobblehead: ... }` conditionals in relevant description text throughout the game.

## What Gets Removed

| Removed | Reason |
|---------|--------|
| `VAR Morale` + all references | Replaced by narrative moments |
| `VAR EngineCondition` + all references | Merged into ShipCondition |
| Daily morale decay | No longer exists |
| AP penalties for low morale | No longer exists |
| `apply_recreation_bonus()` | No longer exists |
| Recreation menu (Relax, Cook, Video Games, Music) | Replaced by triggered moments |
| Entertainment System module | No purpose without morale/recreation |
| Wellness Suite module | Not compelling enough without morale |
| Engine tune P2 task | Replaced by condition-gated urgency |
| `is_engine_maint()` / `is_ship_maint()` distinction | Unified maintenance pool |
| Engine/ship drone split | Unified drone type |
| Cooking system from PR #47 | Special ingredients reworked into triggered moments |
| Task submenus (engine options, maintenance options, relax options) | Flattened to top-level |
| Tier floor reservations (`p3_floor`/`p4_floor`) | Simplified cap: fill by priority |
| Nav check / cargo inspection at P3 | Elevated to P2 (timer-based = important) |

## What Stays Unchanged

- Fatigue system (accumulation, sleep, task failure)
- Passenger Satisfaction system
- Nav checks and cargo inspections (cooldown model, elevated to P2)
- Per-module condition tracking (modules still have individual condition)
- Random event system (individual events lose morale mods, gain narrative moment hooks)
- Cargo system
- Port repair services (now repair ShipCondition + per-module conditions)
- Drone Bay module (reworked but not removed)
- Passenger Module (unchanged)
- AutoNav module (unchanged)
- CargoMgmt module (unchanged)

## Implementation Tracking

- [ ] #49 Drop Morale, recreation menu, Entertainment & Wellness modules
- [ ] #50 Flatten task menu & revise priorities
- [ ] #51 Merge EngineCondition → ShipCondition
- [ ] #52 Unify maintenance task pool
- [ ] #53 Simplify drones
- [ ] #54 Narrative moment scaffolding + first examples
- [ ] #55 Remaining narrative moment examples
