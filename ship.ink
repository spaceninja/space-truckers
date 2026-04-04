VAR ShipClock = 0
VAR ShipDestination = Transit
VAR AP = 6
VAR ActionPointsMax = 6

// Task registry lists — used only for LIST_COUNT() to keep shuffle loop
// bounds in sync. Add an entry here when adding a task to a tier's shuffle.
LIST P2Tasks = EngineMaintenance, UrgentSleep
LIST P3Tasks = Paperwork, NavCheck, MaintBacklog
LIST P4Tasks = Relax, SleepRest, VideoGames, ListenMusic

/*

    Transit

*/
=== transit(destination, fuel_cost, duration, mode)
~ here = Transit
~ ShipDestination = destination
~ ShipFuel -= fuel_cost
~ ShipClock = duration
~ TripDuration = duration
~ TripDay = 0
~ FlipDone = false
~ FlightMode = mode
~ PaperworkTotal = count_paperwork_chunks(ShipCargo)
~ PaperworkDone = 0
~ TripFuelCost = fuel_cost
~ TripFuelPenalty = 0
~ NavChecksCompleted = 0
~ TasksCompletedToday = 0
~ EventChance = 0
~ EventCooldownDay = -1
~ generate_backlog()
-> module_auto_tasks ->
~ Events = LIST_ALL(Events)
// Remove events whose eligibility is fixed for the whole trip
{ ShipCargo == ():
    ~ Events -= CargoShift
}
{ not has_passenger_cargo(ShipCargo):
    ~ Events -= PassengerEvents
}
~ CargoDamagePct = 0
Flying to {LocationData(destination, Name)} for {duration} days…
-> ship_options

/*

    Ship Options
    Priority-based task selection using threading + CHOICE_COUNT().
    Each task is a separate stitch threaded via <-. Shuffle provides
    variety within tiers. CHOICE_COUNT() enforces the cap.

    Adding a new task:
    1. Write a task_* stitch (and optionally a *_options sub-menu stitch)
    2. Add a <- line in the appropriate priority section below
    3. Update has_tier_tasks() with the new task's condition

*/
= ship_options
// P0: Random event check — escalating probability, resets after event fires,
// cooldown prevents more than one event per day.
{ EventCooldownDay < TripDay:
    { RANDOM(1, 100) <= EventChance:
        ~ EventChance = 0
        ~ EventCooldownDay = TripDay
        -> random_event
    }
    ~ EventChance += 3
}
{
- Fatigue >= 90:
    You can barely function. Every movement feels like it's happening underwater. You need to sleep.
- Fatigue >= 80:
    You're exhausted. Your hands are shaking and your vision blurs when you look at the instruments too long.
- Fatigue >= 70:
    You're running on fumes. Everything takes a little more concentration than it should.
}
<center><em><small>{ShipClock} days to {LocationData(ShipDestination, Name)} / {AP} AP remaining</small></em></center>
- (ship_opts)

// Calculate tier floors and caps
// has_tier_tasks() returns true/false which Ink treats as 1/0,
// so these work as slot reservations in the cap math below.
~ temp p3_floor = has_tier_tasks(3)
~ temp p4_floor = has_tier_tasks(4)
~ temp p2_cap = TaskCap - p3_floor - p4_floor
~ temp p3_cap = TaskCap - p4_floor
~ temp p4_cap = TaskCap

// P1: Urgent — always show, no cap
{ not FlipDone and TripDay >= TripDuration / 2: <- task_flip }
// (future: random events, emergencies)

// P2: Important — shuffle, respects p2_cap
- (p2_offer)
~ temp p2_loops = 0
- (p2_shuffle)
{ shuffle:
    - { CHOICE_COUNT() < p2_cap and EngineCondition < 80: <- task_engine }
    - { CHOICE_COUNT() < p2_cap and Fatigue >= 70: <- task_sleep_urgent }
}
~ p2_loops++
{ p2_loops < LIST_COUNT(LIST_ALL(P2Tasks)) and CHOICE_COUNT() < p2_cap: -> p2_shuffle }

// P3: Routine — shuffle, respects p3_cap
- (p3_offer)
~ temp p3_loops = 0
- (p3_shuffle)
{ shuffle:
    - { CHOICE_COUNT() < p3_cap and PaperworkDone < PaperworkTotal: <- task_paperwork }
    - { CHOICE_COUNT() < p3_cap and TripDay > 0 and TripDay mod 3 == 0 and NavChecksCompleted < TripDay / 3: <- task_nav_check }
    - { CHOICE_COUNT() < p3_cap and LIST_COUNT(Backlog) > 0: <- task_maintenance }
}
~ p3_loops++
{ p3_loops < LIST_COUNT(LIST_ALL(P3Tasks)) and CHOICE_COUNT() < p3_cap: -> p3_shuffle }

// P4: Recreation — shuffle, respects p4_cap
- (p4_offer)
~ temp p4_loops = 0
- (p4_shuffle)
{ shuffle:
    - { CHOICE_COUNT() < p4_cap: <- task_relax }
    - { CHOICE_COUNT() < p4_cap and Fatigue >= 30 and Fatigue < 70: <- task_sleep_rest }
    - { CHOICE_COUNT() < p4_cap and is_module_active(Entertainment): <- task_video_games }
    - { CHOICE_COUNT() < p4_cap and is_module_active(Entertainment): <- task_listen_music }
}
~ p4_loops++
{ p4_loops < LIST_COUNT(LIST_ALL(P4Tasks)) and CHOICE_COUNT() < p4_cap: -> p4_shuffle }

// P5: Rest — only when no P1–P3 tasks are active
~ temp has_obligations = has_tier_tasks(1) or has_tier_tasks(2) or has_tier_tasks(3)
{ not has_obligations: <- task_rest }

// DEBUG: Skip the rest of the trip and arrive at destination immediately
+ { DEBUG } [\[DEBUG\] Skip Trip]
    -> arrive_in_port(ShipDestination)

// Flow pauses here; accumulated threaded choices are presented to the player
- (await_choice)
-> DONE

/*

    Task Stitches
    Each stitch injects one choice into ship_options via threading (<-).
    Direct-action tasks show AP cost. Group tasks use exploratory phrasing.

*/

// --- Direct-action tasks ---

= task_flip
+ [Execute ship flip (1 AP)] -> do_flip

= task_paperwork
+ [File paperwork — {PaperworkDone}/{PaperworkTotal} (1 AP)] -> do_paperwork

= task_nav_check
+ [Navigation check (1 AP)] -> do_nav_check

// --- Group tasks (open sub-menus) ---

= task_engine
+ [Check on the engine] -> engine_options

= task_sleep_urgent
+ [Get some rest — you can barely keep your eyes open] -> sleep_options

= task_sleep_rest
+ [Get some rest] -> sleep_options

= task_maintenance
+ [Ship maintenance — {LIST_COUNT(Backlog)} tasks{ has_overdue_tasks(): (overdue!)}] -> maintenance_options

= task_relax
+ [Take a break] -> relax_options

= task_video_games
+ [Play video games (1 AP)] -> do_video_games

= task_listen_music
+ [Listen to music (1 AP)] -> do_listen_music

= task_rest
+ [Call it a day — skip remaining {AP} AP] -> do_rest

/*

    Sub-Menu Stitches
    Each sub-menu shows flavor text, offers sub-options with AP costs,
    and includes a free "Never mind" back option.

*/

= engine_options
You pop open the engine access panel. Condition: {EngineCondition}%.
+ [Run diagnostics and tune (2 AP)] -> do_engine_tune
+ [Never mind] -> ship_options

= sleep_options
{ Fatigue >= 70:
    You can barely keep your eyes open. You need rest.
- else:
    You're feeling the fatigue. Some rest might help.
}
+ [Take a nap (1 AP)] -> sleep(1)
+ { Fatigue >= 40 } [Sleep for a full cycle (2 AP)] -> sleep(2)
+ [Never mind] -> ship_options

= maintenance_options
{ has_overdue_tasks():
    Some of these have been waiting. You should get to them before things get worse.
- else:
    The ship needs some attention.
}
Engine: {EngineCondition}% / Ship: {ShipCondition}%
~ temp _maint = Backlog
- (maint_top)
~ temp task = pop(_maint)
{ task:
    <- maint_choice(task)
    -> maint_top
}
-
+ [Never mind] -> ship_options

= maint_choice(task)
~ temp stale = StaleBacklog ? task
{ stale:
    + [{ MaintName(task) } — overdue (1 AP)] -> do_maintenance(task)
- else:
    + [{ MaintName(task) } (1 AP)] -> do_maintenance(task)
}

= relax_options
What sounds good right now?
+ [Heat up some rations (1 AP)] -> do_eat_rations
+ [Quick workout (1 AP)] -> do_recreation(1, 8)
+ [Watch a movie (2 AP)] -> do_recreation(2, 15)
+ [Never mind] -> ship_options

/*

    Ship Flip
    Required once per trip at the midpoint. The ship rotates 180 degrees
    to begin deceleration.

*/
= do_flip
~ FlipDone = true
{ fatigue_check():
    ~ TripFuelPenalty = TripFuelPenalty + TripFuelCost / 10  // +10% sloppy flip penalty
    Your hands tremble on the controls as you initiate the flip sequence. The ship groans through the rotation — not your cleanest work. The sloppy maneuver will cost you extra fuel.
- else:
    You initiate the flip sequence. The stars wheel past the viewport as the ship rotates 180 degrees. Engines now pointing forward for deceleration. Textbook.
}
-> pass_time(1)

/*

    Paperwork
    File one chunk of customs documentation. Chunks are calculated at
    departure: 1 base + 1 per special-flagged cargo item.

*/
= do_paperwork
{ fatigue_check():
    You stare at the customs forms but can't focus. After filling in the same field twice, you give up. This will have to wait until you've had some rest.
- else:
    ~ PaperworkDone++
    { PaperworkDone >= PaperworkTotal:
        You file the last of the paperwork. All customs documentation is in order.
    - else:
        You work through a stack of customs forms and cargo manifests. {PaperworkTotal - PaperworkDone} chunks remaining.
    }
}
-> pass_time(1)

/*

    Navigation Check
    Review the flight trajectory and make course corrections.

*/
= do_nav_check
{ fatigue_check():
    You squint at the trajectory data, but the numbers swim in front of your eyes. You'll need to try this again when you're more alert.
- else:
    ~ NavChecksCompleted++
    You review the flight trajectory and make minor course corrections. Everything's on track.
}
-> pass_time(1)

/*

    Engine Tune (P2)
    Deep engine diagnostics when condition is critical. Costs 2 AP.
    Separate from the backlog — this is an urgent, targeted repair.

*/
= do_engine_tune
{ fatigue_check():
    ~ EngineCondition = MIN(EngineCondition + 8, get_engine_max_condition())
    You fumble through the diagnostics, missing a few steps. The engine's a little better, but not as much as it should be. Condition: {EngineCondition}%.
- else:
    ~ EngineCondition = MIN(EngineCondition + 15, get_engine_max_condition())
    You run diagnostics and tune the engine. Condition improved to {EngineCondition}%.
}
-> pass_time(2)

/*

    Backlog Maintenance
    Complete a maintenance task from the backlog. Costs 1 AP.
    Economy: +3 condition (rested), +1 condition (fatigued).
    Engine tasks → EngineCondition, ship tasks → ShipCondition,
    module tasks → that specific module's condition.

*/
= do_maintenance(task)
~ complete_maintenance_task(task)
~ temp boost = 3
{ fatigue_check():
    ~ boost = 1
}
{
- is_engine_maint(task):
    ~ EngineCondition = MIN(EngineCondition + boost, get_engine_max_condition())
- is_module_maint(task):
    ~ temp module = maint_task_module(task)
    ~ temp condition = get_module_condition(module)
    ~ temp max_condition = get_module_max_condition(module)
    ~ set_module_condition(module, MIN(condition + boost, max_condition))
- else:
    ~ ShipCondition = MIN(ShipCondition + boost, 100)
}
{ boost < 3:
    {MaintFatigued(task)}
- else:
    {MaintComplete(task)}
}
-> pass_time(1)

/*

    Eat Rations
    Quick meal — small morale boost.

*/
= do_eat_rations
~ Morale = MIN(Morale + apply_recreation_bonus(3), 100)
You heat up a packet of rations. It's not gourmet, but it fills the hole.
-> pass_time(1)

/*

    Recreation
    Flexible recreation handler. Cost and morale boost are parameters.

*/
= do_recreation(cost, morale_boost)
~ Morale = MIN(Morale + apply_recreation_bonus(morale_boost), 100)
{ cost > 1:
    You settle in for a movie. For a couple of hours, you're not a trucker — you're just an audience.
- else:
    You run through a quick workout routine. Your muscles thank you.
}
-> pass_time(cost)

= do_video_games
~ Morale = MIN(Morale + apply_recreation_bonus(10), 100)
{ shuffle:
-   You boot up a game on the entertainment console. Time melts away as you get absorbed in the action.
-   You spend some time gaming. It's a nice escape from the monotony of deep space hauling.
-   The entertainment system loads your saved game. For a while, you forget you're hurtling through the void.
-   You lose an hour to a dogfighting sim. Ironic, given your actual job.
}
-> pass_time(1)

= do_listen_music
~ Morale = MIN(Morale + apply_recreation_bonus(5), 100)
{ shuffle:
-   You put on some music and let it fill the cockpit. The ship feels less empty.
-   You queue up a playlist and let the music wash over you. Simple pleasures.
-   Music drifts through the ship. You catch yourself humming along.
-   Something melancholy tonight. It fits the mood, somehow.
}
-> pass_time(1)

/*

    Sleep
    Full sleep (2 AP) resets fatigue to 0.
    Nap (1 AP) reduces fatigue by 25.

*/
= sleep(amount)
{ amount > 1:
    ~ Fatigue = 0
    You fall into your bunk and sleep like the dead.
- else:
    ~ Fatigue = MAX(Fatigue - 25, 0)
    You grab a quick power nap in the captain's chair. It takes the edge off.
}
-> pass_time(amount)

/*

    Rest
    Skip the rest of the day. Spends all remaining AP.
    Mild fatigue reduction, no fatigue accumulation.

*/
= do_rest
You call it a day and stretch out in your bunk, watching the stars drift past the viewport.
~ Fatigue = MAX(Fatigue - 10, 0)  // mild rest benefit
-> pass_time(AP)

/*

    Pass Time
    Deduct AP and increment task counter.
    If not sleeping or resting, accumulate fatigue with gravity modifier.

*/
= pass_time(amount)
~ AP -= amount
~ TasksCompletedToday++
{ not came_from(-> sleep) and not came_from(-> do_rest):
    // Gravity-modified fatigue: Turbo is more fatiguing, Eco is less
    ~ temp fatigue_gain = amount * 10
    { FlightMode == Turbo:
        ~ fatigue_gain = amount * 15
    }
    { FlightMode == Eco:
        ~ fatigue_gain = amount * 8
    }
    ~ Fatigue = MIN(Fatigue + fatigue_gain, 100)
}
{ AP > 0:
    -> ship_options
- else:
    -> next_day(AP)
}

/*

    Next Day
    Advance the clock, degrade conditions, decay morale, reset AP.

*/
= next_day(rollover)
~ ShipClock--
~ TripDay++
~ AP = ActionPointsMax + rollover
~ TasksCompletedToday = 0
// Flip delay penalty: +5% trip fuel for each day past midpoint without flipping
{ not FlipDone and TripDay > TripDuration / 2:
    ~ TripFuelPenalty = TripFuelPenalty + TripFuelCost / 20  // +5% trip fuel per day delayed
}
// Settle stale tasks — tasks in both Backlog and StaleBacklog have survived
// two days without completion. Apply condition penalty and remove them.
-> settle_stale_tasks ->
// Age today's backlog — current tasks become tomorrow's stale set
~ StaleBacklog = Backlog
// Add 3-4 new daily tasks via two-stage selection
~ add_daily_tasks()
// Module auto-tasks — all modules run daily auto-complete logic
-> module_auto_tasks ->
// Morale decay: faster if ship is dirty
{ ShipCondition < 50:
    ~ Morale = MAX(Morale - 3, 0)
- else:
    ~ Morale = MAX(Morale - 1, 0)
}
// Low morale reduces effective AP
{ Morale < 20:
    ~ AP = MIN(AP, 4)
- else:
    { Morale < 40:
        ~ AP = MIN(AP, 5)
    }
}
{ ShipClock == 0:
    -> arrive_in_port(ShipDestination)
}
-> ship_options

/*

    Settle Stale Tasks
    Tunnel called from next_day(). Tasks that have been in the backlog for
    two days (present in both Backlog and StaleBacklog) auto-resolve with
    a condition penalty. Each settled task is replaced with a fresh one.
    Loops until all overdue tasks are resolved.

*/
= settle_stale_tasks
~ temp overdue = Backlog ^ StaleBacklog
{ LIST_COUNT(overdue) <= 0:
    ->->
}
- (settle_next)
~ temp task = pop(overdue)
~ Backlog -= task
~ StaleBacklog -= task
{
- is_engine_maint(task):
    ~ EngineCondition = MAX(EngineCondition - 5, 0)
- is_module_maint(task):
    ~ temp module = maint_task_module(task)
    // Guard: skip if module was uninstalled since task was added
    { InstalledModules ? module:
        ~ set_module_condition(module, MAX(get_module_condition(module) - 5, 1))
    }
- else:
    ~ ShipCondition = MAX(ShipCondition - 5, 0)
}
{MaintOverdue(task)}
{ LIST_COUNT(overdue) > 0:
    -> settle_next
}
->->

/*

    Has Tier Tasks
    Returns true if any tasks at the given priority tier are currently eligible.
    Used for floor calculations and Rest gating.
    When adding new tasks, update the appropriate tier case here.

*/
=== function has_tier_tasks(tier)
{ tier:
    - 1: ~ return (not FlipDone and TripDay >= TripDuration / 2)
    - 2: ~ return (EngineCondition < 80) or (Fatigue >= 70)
    - 3: ~ return (PaperworkDone < PaperworkTotal) or (TripDay > 0 and TripDay mod 3 == 0 and NavChecksCompleted < TripDay / 3) or (LIST_COUNT(Backlog) > 0)
    - 4: ~ return true  // Relax is always available
}
~ return false

/*

    Can The Player Sleep?
    Returns true when fatigue is high enough to offer sleep options.

*/
=== function can_sleep()
~ return Fatigue >= 30

/*

    Is The Player Overtired?
    Returns true when fatigue is dangerously high,
    triggering warnings and task failure chance.

*/
=== function is_overtired()
~ return Fatigue >= 70

/*

    Fatigue Check
    Dice roll for task failure when overtired. Returns true if the
    player fails (too tired to do good work). Three escalating tiers:
    70–79: 20% chance, 80–89: 40% chance, 90+: 70% chance.

*/
=== function fatigue_check()
{ Fatigue < 70:
    ~ return false
}
~ temp roll = RANDOM(1, 100)
{ Fatigue >= 90:
    ~ return roll <= 70
}
{ Fatigue >= 80:
    ~ return roll <= 40
}
~ return roll <= 20

/*

    Maintenance Task Helpers
    Functions for the persistent maintenance backlog system.

*/

// Classification: which system does this maintenance task belong to?
=== function is_engine_maint(task)
~ return LIST_ALL(EngineMaintTasks) ? task

=== function is_ship_maint(task)
~ return LIST_ALL(ShipMaintTasks) ? task

// Human-readable name for a maintenance task.
=== function MaintName(task)
{ task:
// Engine tasks
- EngTune:        ~ return "engine tune-up"
- FuelLine:       ~ return "fuel line cleaning"
- Injector:       ~ return "injector calibration"
- Coolant:        ~ return "coolant system check"
// Ship tasks
- AirFilter:      ~ return "air filter swap"
- HullCheck:      ~ return "hull inspection"
- DrainLines:     ~ return "drain line flush"
- Scrub:          ~ return "common area scrub"
// Module tasks
- RepDroneServo:  ~ return "repair drone servo calibration"
- RepDroneOptics: ~ return "repair drone optics cleaning"
- ClnDroneBrush:  ~ return "cleaning drone brush replacement"
- ClnDroneFilter: ~ return "cleaning drone filter swap"
- NavChipFlush:   ~ return "nav computer chip flush"
- NavGyroCalib:   ~ return "nav gyroscope calibration"
- CargoSensor:    ~ return "cargo sensor recalibration"
- CargoSealCheck: ~ return "cargo bay seal check"
- EntWiring:      ~ return "entertainment system wiring check"
- EntDisplayClean: ~ return "display panel cleaning"
- WellSanitize:   ~ return "wellness suite sanitization"
- WellCalib:      ~ return "autodoc calibration"
}
~ return "maintenance"

// Completion text for a maintenance task (rested).
=== function MaintComplete(task)
{ task:
// Engine tasks
- EngTune:        ~ return "You run through the engine tune-up. Sounds healthier already."
- FuelLine:       ~ return "You flush the fuel lines clean. Flow rate's back to normal."
- Injector:       ~ return "You recalibrate the injectors. The engine idles smoother now."
- Coolant:        ~ return "You top off the coolant and bleed the air out. Temps look good."
// Ship tasks
- AirFilter:      ~ return "You pop the old filters out and slot in fresh ones. The air tastes better already."
- HullCheck:      ~ return "You walk the hull sections checking for stress fractures. All clear."
- DrainLines:     ~ return "You hook up the purge line and flush the residue. Disgusting, but necessary."
- Scrub:          ~ return "You give the common areas a proper scrub. The ship feels livable again."
// Module tasks
- RepDroneServo:  ~ return "You recalibrate the repair drone's servos. Its movements are precise again."
- RepDroneOptics: ~ return "You clean the repair drone's optical sensors. It can see what it's fixing now."
- ClnDroneBrush:  ~ return "You swap the cleaning drone's worn brushes for fresh ones."
- ClnDroneFilter: ~ return "You replace the cleaning drone's clogged filter. Much better airflow."
- NavChipFlush:   ~ return "You flush the nav computer's cache. Response time is snappy again."
- NavGyroCalib:   ~ return "You recalibrate the navigation gyroscopes. Heading data looks solid."
- CargoSensor:    ~ return "You recalibrate the cargo bay sensors. Weight readings are accurate again."
- CargoSealCheck: ~ return "You inspect the cargo bay seals and tighten the loose ones."
- EntWiring:      ~ return "You trace the entertainment system wiring and fix a dodgy connection."
- EntDisplayClean: ~ return "You clean the display panels. The picture's crisp again."
- WellSanitize:   ~ return "You run the wellness suite through a full sanitization cycle."
- WellCalib:      ~ return "You recalibrate the autodoc's sensors. Readings are precise again."
}
~ return "You finish the maintenance task."

// Completion text for a maintenance task (fatigued — reduced effectiveness).
=== function MaintFatigued(task)
{ task:
// Engine tasks
- EngTune:        ~ return "Your hands shake through the tune-up. It's done, but not your best work."
- FuelLine:       ~ return "You fumble with the fuel line fittings. Close enough."
- Injector:       ~ return "You squint at the injector readings, too tired to be precise."
- Coolant:        ~ return "You slosh coolant everywhere topping off the system. It'll do."
// Ship tasks
- AirFilter:      ~ return "You swap the filters but drop one in the process. Good enough."
- HullCheck:      ~ return "You half-heartedly walk the hull. Probably fine."
- DrainLines:     ~ return "You flush the drains but skip the secondary lines. Too tired."
- Scrub:          ~ return "You push a mop around but your heart isn't in it."
// Module tasks
- RepDroneServo:  ~ return "You fumble the servo calibration. The drone wobbles a bit less, at least."
- RepDroneOptics: ~ return "You wipe the drone's optics but can barely keep your own eyes open."
- ClnDroneBrush:  ~ return "You swap the brushes but install one backwards. It'll work, mostly."
- ClnDroneFilter: ~ return "You jam a new filter in place. Not a clean fit, but it'll run."
- NavChipFlush:   ~ return "You start the cache flush but skip the verification step."
- NavGyroCalib:   ~ return "You attempt the gyro calibration but the numbers swim. Close enough."
- CargoSensor:    ~ return "You poke at the sensor calibration. The readings are... better."
- CargoSealCheck: ~ return "You check a few seals but skip the hard-to-reach ones."
- EntWiring:      ~ return "You jiggle a wire until the static clears. Engineering at its finest."
- EntDisplayClean: ~ return "You smear the displays more than clean them."
- WellSanitize:   ~ return "You run a quick sanitization cycle. Probably killed most of the germs."
- WellCalib:      ~ return "You squint at the autodoc readings and call it calibrated."
}
~ return "You go through the motions on the maintenance task. Not your best work."

// Consequence text for an overdue maintenance task (auto-resolved with penalty).
=== function MaintOverdue(task)
{ task:
// Engine tasks
- EngTune:        ~ return "The engine's been knocking all day. Should have done that tune-up."
- FuelLine:       ~ return "Fuel flow is getting sluggish. The lines needed cleaning days ago."
- Injector:       ~ return "The injectors are misfiring. You can hear it in the engine's stutter."
- Coolant:        ~ return "The engine's running hot. The coolant system needed attention."
// Ship tasks
- AirFilter:      ~ return "The air smells stale and metallic. Those filters are long overdue."
- HullCheck:      ~ return "You hear a creak you don't recognize. Should have checked the hull."
- DrainLines:     ~ return "The drains are backing up. Should have flushed them when you had the chance."
- Scrub:          ~ return "The common areas are getting grimy. Morale isn't the only thing suffering."
// Module tasks
- RepDroneServo:  ~ return "The repair drone's arm is jerking erratically. The servos needed attention."
- RepDroneOptics: ~ return "The repair drone keeps bumping into things. Its optics are filthy."
- ClnDroneBrush:  ~ return "The cleaning drone is just pushing dirt around. Its brushes are shot."
- ClnDroneFilter: ~ return "The cleaning drone smells worse than what it's cleaning. Filter's clogged."
- NavChipFlush:   ~ return "The nav computer is sluggish. Its cache is bloated."
- NavGyroCalib:   ~ return "Course heading keeps drifting. The gyroscopes are way out of spec."
- CargoSensor:    ~ return "The cargo sensors are giving bogus readings. Hope nothing shifted."
- CargoSealCheck: ~ return "You hear a whistle near the cargo bay. The seals are loosening."
- EntWiring:      ~ return "The entertainment system is glitching out. Wiring issue, probably."
- EntDisplayClean: ~ return "The displays are so grimy you can barely read them."
- WellSanitize:   ~ return "The wellness suite smells like a gym locker. Sanitization is overdue."
- WellCalib:      ~ return "The autodoc's readings are drifting. Can't trust it like this."
}
~ return "A maintenance task went unattended."

// Generate the initial backlog at trip start.
=== function generate_backlog()
~ Backlog = ()
~ StaleBacklog = ()
~ CompletedToday = ()
~ MaintCooldown = ()
~ add_daily_tasks()

// Apply Entertainment System morale bonus to a base recreation boost.
// At 75%+ condition: +50% bonus (base + base / 2, integer math).
// Otherwise: base unchanged.
=== function apply_recreation_bonus(base_boost)
~ temp bonus = 0
{ get_module_condition(Entertainment) >= 75:
    ~ bonus = base_boost / 2
}
~ return base_boost + bonus

// Complete a maintenance task: remove from backlog/stale, add to cooldown.
// Replacement tasks are generated at start of next day, not immediately.
=== function complete_maintenance_task(task)
~ Backlog -= task
~ StaleBacklog -= task
~ CompletedToday += task

// Are any backlog tasks overdue (survived two days without completion)?
=== function has_overdue_tasks()
~ return LIST_COUNT(Backlog ^ StaleBacklog) > 0

// Two-stage daily task selection. Stage 1: draw 3 engine, 3 ship, 1 module
// (from installed modules only). Stage 2: coin flip for 3 or 4 from combined pool.
// Cooldown excludes yesterday's completed tasks from the draw.
=== function add_daily_tasks()
// Build per-system pools (exclude backlog + cooldown)
~ temp eng_pool = LIST_ALL(EngineMaintTasks) - Backlog - MaintCooldown
~ temp ship_pool = LIST_ALL(ShipMaintTasks) - Backlog - MaintCooldown
~ temp mod_pool = available_module_tasks() - Backlog - MaintCooldown
// Stage 1: draw candidates from each system
~ temp combined = list_random_subset_of_size(eng_pool, 3) + list_random_subset_of_size(ship_pool, 3)
{ LIST_COUNT(mod_pool) > 0:
    ~ combined += list_random_subset_of_size(mod_pool, 1)
}
// Stage 2: coin flip for 3 or 4, then draw from combined pool
~ temp draw_count = 3
{ RANDOM(1, 2) == 1:
    ~ draw_count = 4
}
{ LIST_COUNT(combined) < draw_count:
    ~ draw_count = LIST_COUNT(combined)
}
~ Backlog += list_random_subset_of_size(combined, draw_count)
// Rotate cooldown: today's completions become tomorrow's exclusion
~ MaintCooldown = CompletedToday
~ CompletedToday = ()
