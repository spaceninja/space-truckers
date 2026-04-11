VAR ShipClock = 0
VAR ShipDestination = Transit
VAR AP = 6
VAR ActionPointsMax = 6

// Task registry lists — used only for LIST_COUNT() to keep shuffle loop
// bounds in sync. Add an entry here when adding a task to a tier's shuffle.
LIST P2Tasks = UrgentSleep, NavCheck, CargoInspect
LIST P3Tasks = MaintBacklog, PassengerTask
LIST P4Tasks = Paperwork, SleepRest

// Passenger task pool — 12 tasks in 3 tone categories.
// Tone category VARs control weighted random selection in pick_passenger_task.
// To add tasks: add to PassengerTasks LIST and the appropriate category VAR.
LIST PassengerTasks = PaxShower, PaxQuarters, PaxAirQuality, PaxRations, PaxMovieNight, PaxMealService, PaxGameNight, PaxExercise, PaxObsDeck, PaxKaraoke, PaxStargazing, PaxCocktails
VAR NegativePaxTasks = (PaxShower, PaxQuarters, PaxAirQuality, PaxRations)
VAR MixedPaxTasks = (PaxMovieNight, PaxMealService, PaxGameNight, PaxExercise)
VAR PositivePaxTasks = (PaxObsDeck, PaxKaraoke, PaxStargazing, PaxCocktails)

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
~ NavCheckDueDay = 3
~ NavPenaltyPct = 0
~ CargoCheckDueDay = 2
~ CargoCheckPenaltyPct = 0
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
// Passenger satisfaction — reset each trip
~ PassengerSatisfaction = 50
~ DailyPassengerTask = ()
~ PassengerTaskCompleted = false
{ has_passenger_cargo(ShipCargo) and InstalledModules ? PassengerModule:
    -> pick_passenger_task ->
}
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

// All tiers fill slots up to TaskCap; higher priority runs first so
// lower-priority tasks only get slots left over by upper tiers.
~ temp cap = TaskCap

// P1: Urgent — always show, no cap
{ not FlipDone and TripDay >= TripDuration / 2: <- task_flip }
// (future: random events, emergencies)

// P2: Important — shuffle for variety, respects cap
- (p2_offer)
~ temp p2_loops = 0
- (p2_shuffle)
{ shuffle:
    - { CHOICE_COUNT() < cap and Fatigue >= 70:
        <- task_nap
        { CHOICE_COUNT() < cap and Fatigue >= 40: <- task_full_sleep }
      }
    - { CHOICE_COUNT() < cap and TripDay >= NavCheckDueDay: <- task_nav_check }
    - { CHOICE_COUNT() < cap and TripDay >= CargoCheckDueDay: <- task_cargo_inspect }
}
~ p2_loops++
{ p2_loops < LIST_COUNT(LIST_ALL(P2Tasks)) and CHOICE_COUNT() < cap: -> p2_shuffle }

// P3: Routine — deterministic sub-priority order, respects cap
// Sub-priority: (1) overdue maint, (2) passenger task, (3) fresh maint

// (1) Overdue maintenance tasks
- (p3_offer)
~ temp _stale = Backlog ^ StaleBacklog
- (stale_top)
~ temp stale_task = pop(_stale)
{ stale_task:
    { CHOICE_COUNT() < cap: <- maint_choice(stale_task) }
    -> stale_top
}

// (2) Passenger task
- (p3_passenger)
{ CHOICE_COUNT() < cap and DailyPassengerTask != () and not PassengerTaskCompleted: <- task_passenger }

// (3) Fresh maintenance tasks
~ temp _fresh = Backlog - StaleBacklog
- (fresh_top)
~ temp fresh_task = pop(_fresh)
{ fresh_task:
    { CHOICE_COUNT() < cap: <- maint_choice(fresh_task) }
    -> fresh_top
}
-

// P4: Low priority — paperwork, optional sleep
- (p4_offer)
{ CHOICE_COUNT() < cap and PaperworkDone < PaperworkTotal: <- task_paperwork }
{ CHOICE_COUNT() < cap and Fatigue >= 30 and Fatigue < 70:
    <- task_nap
    { CHOICE_COUNT() < cap and Fatigue >= 40: <- task_full_sleep }
}

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

= task_cargo_inspect
+ [Cargo inspection (1 AP)] -> do_cargo_inspect

// --- Group tasks (direct actions, no sub-menus) ---

= task_nap
+ [Take a nap (1 AP)] -> sleep(1)

= task_full_sleep
+ [Sleep for a full cycle (2 AP)] -> sleep(2)

= task_rest
+ [Call it a day — skip remaining {AP} AP] -> do_rest

= maint_choice(task)
~ temp stale = StaleBacklog ? task
{ stale:
    + [{ MaintName(task) } — overdue (1 AP)] -> do_maintenance(task)
- else:
    + [{ MaintName(task) } (1 AP)] -> do_maintenance(task)
}

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
    ~ NavCheckDueDay = TripDay + 3
    You review the flight trajectory and make minor course corrections. Everything's on track.
}
-> pass_time(1)

/*

    Cargo Inspection
    Walk the hold, check tie-downs, container seals, and label integrity.
    Required every 3 days (or 2 days with Fragile/Hazardous cargo).
    Missing an inspection incurs a 1% pay fine per overdue day at delivery.

*/
= do_cargo_inspect
{ fatigue_check():
    You flip open the cargo manifest but can't focus on the inspection checklist. Everything blurs together. You'll have to try again after some rest.
- else:
    ~ CargoCheckDueDay = TripDay + get_cargo_check_interval()
    You walk the hold, checking tie-downs, container seals, and label integrity. Everything looks secure.
}
-> pass_time(1)

/*

    Backlog Maintenance
    Complete a maintenance task from the backlog. Costs 1 AP.
    Economy: +3 condition (rested), +1 condition (fatigued).
    When ShipCondition < 60 and rested: urgency boost gives +5.
    Module tasks → that specific module's condition.
    All other tasks → ShipCondition.

*/
= do_maintenance(task)
~ complete_maintenance_task(task)
~ temp boost = 3
{ fatigue_check():
    ~ boost = 1
- else:
    { ShipCondition < 60 and not is_module_maint(task):
        ~ boost = 5
    }
}
{
- is_module_maint(task):
    ~ temp module = maint_task_module(task)
    ~ temp condition = get_module_condition(module)
    ~ temp max_condition = get_module_max_condition(module)
    ~ set_module_condition(module, MIN(condition + boost, max_condition))
- else:
    ~ ShipCondition = MIN(ShipCondition + boost, 100)
}
{
- boost == 5:
    {MaintComplete(task)} The urgency sharpens your focus — you work faster and more thoroughly than usual.
- boost < 3:
    {MaintFatigued(task)}
- else:
    {MaintComplete(task)}
}
-> pass_time(1)

/*

    Passenger Task
    One passenger interaction offered per day when carrying passenger cargo.
    Completing gives a satisfaction boost; skipping applies a penalty at next_day.
    Task tone is weighted by passenger module tier via pick_passenger_task.

*/
= task_passenger
+ [Check on passengers — {PassengerTaskName(DailyPassengerTask)} (1 AP)]
    -> do_passenger_task

= do_passenger_task
~ PassengerTaskCompleted = true
~ temp sat_boost = 5
{ PassengerModuleTier >= 3:
    ~ sat_boost = 7  // Luxury Suite: better facilities, better outcomes
}
~ PassengerSatisfaction = MIN(PassengerSatisfaction + sat_boost, 100)
{PassengerTaskText(DailyPassengerTask)}
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
    { shuffle:
    -   When you wake, you brew coffee and heat up a packet of oatmeal. Not glamorous, but it's something warm.
    -   When you wake, you crack open an emergency ration bar and chase it with two bulbs of coffee. The second one kicks in mid-task.
    -   When you wake, you make a proper breakfast — fried reconstituted eggs, toast, the works. You feel almost human.
    -   When you wake, you sit with your coffee for a long moment before moving. It's the only ritual that still makes sense out here.
    }
- else:
    ~ Fatigue = MAX(Fatigue - 25, 0)
    You grab a quick power nap in the captain's chair. It takes the edge off.
    { shuffle:
    -   You eat a protein bar without really tasting it on your way back to the task list.
    -   You wash down a ration packet with the last of the cold coffee. Good enough.
    -   You grab a handful of crackers from the emergency tin. Technically food.
    }
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
// Nav check overdue penalty: +1% trip fuel per day past due
{ TripDay > NavCheckDueDay:
    ~ NavPenaltyPct++
}
// Cargo inspection overdue penalty: +1% pay per day past due
{ TripDay > CargoCheckDueDay:
    ~ CargoCheckPenaltyPct++
}
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
// Passenger satisfaction: skip penalty, passive bonus, status update, new task
{ has_passenger_cargo(ShipCargo) and InstalledModules ? PassengerModule:
    // Skip penalty: -3 if yesterday's task was offered but not completed
    { DailyPassengerTask != () and not PassengerTaskCompleted:
        ~ PassengerSatisfaction = MAX(PassengerSatisfaction - 3, 0)
    }
    // Passive daily satisfaction: tier determines base, condition shifts it
    // T1: +0/−1/−2, T2: +1/0/−1, T3: +2/+1/0 at 80%+/50%+/below 50%
    ~ temp pax_cond = get_module_condition(PassengerModule)
    ~ temp passive = PassengerModuleTier - 1 // base: T1=0, T2=1, T3=2
    {
    - pax_cond >= 80:
        // full bonus — no adjustment
    - pax_cond >= 50:
        ~ passive = passive - 1
    - else:
        ~ passive = passive - 2
    }
    { passive > 0:
        ~ PassengerSatisfaction = MIN(PassengerSatisfaction + passive, 100)
    }
    { passive < 0:
        ~ PassengerSatisfaction = MAX(PassengerSatisfaction + passive, 0)
    }
    -> passenger_satisfaction_check ->
    -> pick_passenger_task ->
}
{ ShipClock == 0:
    -> arrive_in_port(ShipDestination)
}
{ shuffle:
-   You grab a protein bar and a bulb of coffee and review the task list.
-   You eat standing up — reconstituted eggs, more or less — and get back to it.
-   Coffee first. Everything else can wait thirty seconds.
-   You skip breakfast and immediately regret it. The ration bar you eat an hour later doesn't count.
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
    - 2: ~ return (Fatigue >= 70) or (TripDay >= NavCheckDueDay) or (TripDay >= CargoCheckDueDay)
    - 3: ~ return (LIST_COUNT(Backlog) > 0) or (DailyPassengerTask != () and not PassengerTaskCompleted)
    - 4: ~ return (PaperworkDone < PaperworkTotal) or (Fatigue >= 30 and Fatigue < 70)
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

// Human-readable name for a maintenance task.
=== function MaintName(task)
{ task:
// Ship/engine tasks
- FuelLine:       ~ return "fuel line cleaning"
- Injector:       ~ return "injector calibration"
- Coolant:        ~ return "coolant system check"
- AirFilter:      ~ return "air filter swap"
- HullCheck:      ~ return "hull inspection"
- DrainLines:     ~ return "drain line flush"
- Scrub:          ~ return "common area scrub"
- SensorRecal:    ~ return "sensor recalibration"
- HullPatch:      ~ return "hull micro-fracture patch"
- LaundryRun:     ~ return "laundry run"
- WiringCheck:    ~ return "wiring harness check"
// Module tasks
- DroneBayServo:  ~ return "drone bay servo calibration"
- DroneBayOptics: ~ return "drone bay optics cleaning"
- NavChipFlush:   ~ return "nav computer chip flush"
- NavGyroCalib:   ~ return "nav gyroscope calibration"
- CargoSensor:    ~ return "cargo sensor recalibration"
- CargoSealCheck: ~ return "cargo bay seal check"
- PaxLifeSupp:    ~ return "passenger life support check"
- PaxBerthClean:  ~ return "passenger berth cleaning"
}
~ return "maintenance"

// Completion text for a maintenance task (rested).
=== function MaintComplete(task)
{ task:
// Ship/engine tasks
- FuelLine:       ~ return "You flush the fuel lines clean. Flow rate's back to normal."
- Injector:       ~ return "You recalibrate the injectors. The engine idles smoother now."
- Coolant:        ~ return "You top off the coolant and bleed the air out. Temps look good."
- AirFilter:      ~ return "You pop the old filters out and slot in fresh ones. The air tastes better already."
- HullCheck:      ~ return "You walk the hull sections checking for stress fractures. All clear."
- DrainLines:     ~ return "You hook up the purge line and flush the residue. Disgusting, but necessary."
- Scrub:          ~ return "You give the common areas a proper scrub. The ship feels livable again."
- SensorRecal:    ~ return "You run through the sensor suite. All readings are back in spec."
- HullPatch:      ~ return "You locate the hairline fracture and seal it. One less thing to worry about."
- LaundryRun:     ~ return "You run the laundry. Clean clothes make a surprising difference to morale."
- WiringCheck:    ~ return "You trace the wiring harness and tighten a few loose connectors."
// Module tasks
- DroneBayServo:  ~ return "You recalibrate the drone bay servos. The drones move with precision again."
- DroneBayOptics: ~ return "You clean the drone bay optical sensors. Target acquisition is back to normal."
- NavChipFlush:   ~ return "You flush the nav computer's cache. Response time is snappy again."
- NavGyroCalib:   ~ return "You recalibrate the navigation gyroscopes. Heading data looks solid."
- CargoSensor:    ~ return "You recalibrate the cargo bay sensors. Weight readings are accurate again."
- CargoSealCheck: ~ return "You inspect the cargo bay seals and tighten the loose ones."
- PaxLifeSupp:    ~ return "You run through the passenger life support diagnostics. Air and water systems nominal."
- PaxBerthClean:  ~ return "You clean the passenger berths and restock the basics. Everything looks presentable."
}
~ return "You finish the maintenance task."

// Completion text for a maintenance task (fatigued — reduced effectiveness).
=== function MaintFatigued(task)
{ task:
// Ship/engine tasks
- FuelLine:       ~ return "You fumble with the fuel line fittings. Close enough."
- Injector:       ~ return "You squint at the injector readings, too tired to be precise."
- Coolant:        ~ return "You slosh coolant everywhere topping off the system. It'll do."
- AirFilter:      ~ return "You swap the filters but drop one in the process. Good enough."
- HullCheck:      ~ return "You half-heartedly walk the hull. Probably fine."
- DrainLines:     ~ return "You flush the drains but skip the secondary lines. Too tired."
- Scrub:          ~ return "You push a mop around but your heart isn't in it."
- SensorRecal:    ~ return "You poke at the sensor settings. The readings are... better."
- HullPatch:      ~ return "You smear sealant over the crack. It'll hold. Probably."
- LaundryRun:     ~ return "You start the laundry and immediately forget about it. It'll be wrinkled."
- WiringCheck:    ~ return "You poke at the wiring but can't focus. You tighten a few obvious ones."
// Module tasks
- DroneBayServo:  ~ return "You fumble through the servo calibration. The drones wobble a bit less, at least."
- DroneBayOptics: ~ return "You wipe the drone optics but can barely keep your own eyes open."
- NavChipFlush:   ~ return "You start the cache flush but skip the verification step."
- NavGyroCalib:   ~ return "You attempt the gyro calibration but the numbers swim. Close enough."
- CargoSensor:    ~ return "You poke at the sensor calibration. The readings are... better."
- CargoSealCheck: ~ return "You check a few seals but skip the hard-to-reach ones."
- PaxLifeSupp:    ~ return "You half-check the passenger life support. Probably fine."
- PaxBerthClean:  ~ return "You give the berths a quick once-over. It'll have to do."
}
~ return "You go through the motions on the maintenance task. Not your best work."

// Consequence text for an overdue maintenance task (auto-resolved with penalty).
=== function MaintOverdue(task)
{ task:
// Ship/engine tasks
- FuelLine:       ~ return "Fuel flow is getting sluggish. The lines needed cleaning days ago."
- Injector:       ~ return "The injectors are misfiring. You can hear it in the engine's stutter."
- Coolant:        ~ return "The engine's running hot. The coolant system needed attention."
- AirFilter:      ~ return "The air smells stale and metallic. Those filters are long overdue."
- HullCheck:      ~ return "You hear a creak you don't recognize. Should have checked the hull."
- DrainLines:     ~ return "The drains are backing up. Should have flushed them when you had the chance."
- Scrub:          ~ return "The common areas are getting grimy. It's starting to smell in here."
- SensorRecal:    ~ return "A sensor alarm trips and then clears. Something's drifting out of spec."
- HullPatch:      ~ return "You feel a faint vibration in the hull. That fracture needed sealing."
- LaundryRun:     ~ return "The ship is starting to smell. Laundry waits for no one."
- WiringCheck:    ~ return "A light flickers. The wiring harness needed attention."
// Module tasks
- DroneBayServo:  ~ return "A drone is moving erratically. The servos needed attention."
- DroneBayOptics: ~ return "A drone keeps missing its targets. The optics are filthy."
- NavChipFlush:   ~ return "The nav computer is sluggish. Its cache is bloated."
- NavGyroCalib:   ~ return "Course heading keeps drifting. The gyroscopes are way out of spec."
- CargoSensor:    ~ return "The cargo sensors are giving bogus readings. Hope nothing shifted."
- CargoSealCheck: ~ return "You hear a whistle near the cargo bay. The seals are loosening."
- PaxLifeSupp:    ~ return "The passenger section air smells recycled and stale. Life support needed attention."
- PaxBerthClean:  ~ return "The passenger berths are getting grimy. Someone left a polite but firm note."
}
~ return "A maintenance task went unattended."

// Generate the initial backlog at trip start.
=== function generate_backlog()
~ Backlog = ()
~ StaleBacklog = ()
~ CompletedToday = ()
~ MaintCooldown = ()
~ add_daily_tasks()

// Complete a maintenance task: remove from backlog/stale, add to cooldown.
// Replacement tasks are generated at start of next day, not immediately.
=== function complete_maintenance_task(task)
~ Backlog -= task
~ StaleBacklog -= task
~ CompletedToday += task

// Are any backlog tasks overdue (survived two days without completion)?
=== function has_overdue_tasks()
~ return LIST_COUNT(Backlog ^ StaleBacklog) > 0

// Daily task selection: draw 3-4 tasks from the unified pool (MaintTasks + module tasks).
// Cooldown excludes yesterday's completed tasks from the draw.
=== function add_daily_tasks()
~ temp pool = LIST_ALL(MaintTasks) - Backlog - MaintCooldown
~ temp mod_pool = available_module_tasks() - Backlog - MaintCooldown
~ temp combined = pool + mod_pool
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

/*

    Pick Passenger Task
    Tunnel called from transit() and next_day(). Selects one random passenger
    task using two-stage weighted selection: first pick tone category (weighted
    by module tier), then pick randomly within that category.

    Avoids drawing the same task two days in a row by redrawing once if the
    chosen task matches yesterday's. (6.25% residual repeat rate is acceptable.)

    Tier 1 weights: 50% negative / 30% mixed / 20% positive
    Tier 2 weights: 30% negative / 40% mixed / 30% positive
    Tier 3 weights: 20% negative / 50% mixed / 30% positive

*/
=== pick_passenger_task
~ temp prev = DailyPassengerTask
~ PassengerTaskCompleted = false
~ temp roll = RANDOM(1, 100)
// Stage 1: pick tone category (1=neg, 2=mixed, 3=pos)
~ temp category = 0
{
- PassengerModuleTier >= 3:
    {
    - roll <= 20: ~ category = 1
    - roll <= 70: ~ category = 2
    - else:       ~ category = 3
    }
- PassengerModuleTier >= 2:
    {
    - roll <= 30: ~ category = 1
    - roll <= 70: ~ category = 2
    - else:       ~ category = 3
    }
- else:
    {
    - roll <= 50: ~ category = 1
    - roll <= 80: ~ category = 2
    - else:       ~ category = 3
    }
}
// Stage 2: pick random task within category
{
- category == 1: ~ DailyPassengerTask = LIST_RANDOM(NegativePaxTasks)
- category == 2: ~ DailyPassengerTask = LIST_RANDOM(MixedPaxTasks)
- else:          ~ DailyPassengerTask = LIST_RANDOM(PositivePaxTasks)
}
// Redraw once if same as yesterday
{ DailyPassengerTask == prev:
    {
    - category == 1: ~ DailyPassengerTask = LIST_RANDOM(NegativePaxTasks)
    - category == 2: ~ DailyPassengerTask = LIST_RANDOM(MixedPaxTasks)
    - else:          ~ DailyPassengerTask = LIST_RANDOM(PositivePaxTasks)
    }
}
->->

/*

    Passenger Satisfaction Check
    Tunnel called from next_day(). Prints a status line when passengers
    are in bonus or penalty satisfaction zones.

*/
=== passenger_satisfaction_check
{
- PassengerSatisfaction >= 70:
    { shuffle:
    - The passengers seem genuinely content. You can hear laughter from the common area.
    - Someone left a thank-you note on the galley counter. You pocket it.
    - The mood aboard is warm. Even the quiet ones are smiling.
    }
- PassengerSatisfaction <= 30:
    { shuffle:
    - The passengers are not happy. You catch muttering as you pass the berths.
    - Someone has scratched a complaint into the galley table. Charming.
    - The atmosphere in the passenger section could curdle milk.
    }
}
->->

/*

    Passenger Task Name
    Short display name used in choice text.

*/
=== function PassengerTaskName(task)
{ task:
- PaxShower:      ~ return "fix the broken shower"
- PaxQuarters:    ~ return "address cramped quarters"
- PaxAirQuality:  ~ return "improve air quality"
- PaxRations:     ~ return "sort out food complaints"
- PaxMovieNight:  ~ return "set up movie night"
- PaxMealService: ~ return "cook a group meal"
- PaxGameNight:   ~ return "organize a game night"
- PaxExercise:    ~ return "lead a group workout"
- PaxObsDeck:     ~ return "open the observation deck"
- PaxKaraoke:     ~ return "host karaoke night"
- PaxStargazing:  ~ return "stargazing session"
- PaxCocktails:   ~ return "mix cocktails"
}
~ return "check on passengers"

/*

    Passenger Task Text
    Completion flavor text for each passenger task.

*/
=== function PassengerTaskText(task)
{ task:
// Negative tone — fixing problems
- PaxShower:
    ~ return "You trace the shower problem to a stuck mixing valve. Twenty minutes with a wrench and your passengers have hot water again. Someone thanks you like you've performed a miracle."
- PaxQuarters:
    ~ return "You rearrange the berth dividers and rig up a privacy curtain from cargo netting. It's not luxury, but the complaints stop."
- PaxAirQuality:
    ~ return "You swap the passenger section air filters and crank the circulation up a notch. The air smells almost fresh. Almost."
- PaxRations:
    ~ return "You dig through the galley stores and put together something that isn't a ration pack. It's basic, but the passengers eat every bite."
// Mixed tone — small positive gestures
- PaxMovieNight:
    ~ return "You rig the common area screen and queue up a film. The passengers settle in with blankets and ration snacks. For a couple of hours, nobody's thinking about the void outside."
- PaxMealService:
    ~ return "You cook enough for everyone. The ship smells like real food for the first time this trip. A kid asks for seconds."
- PaxGameNight:
    ~ return "You sit down with the passengers for cards. The game gets competitive, then loud, then funny. You lose badly and nobody cares."
- PaxExercise:
    ~ return "You lead the group through a workout routine in the cargo hold. It's awkward at first, then everyone gets into it. You're all sore and smiling afterward."
// Positive tone — genuine hospitality
- PaxObsDeck:
    ~ return "You open the observation blister and dim the interior lights. The passengers crowd in, faces lit by starlight. You point out Jupiter, the Belt, the distant Sun. Nobody speaks for a long time."
- PaxKaraoke:
    ~ return "The karaoke system fires up and your passengers take turns murdering classic songs. It's terrible and wonderful. Someone drags you up for a duet."
- PaxStargazing:
    ~ return "You set up in the observation deck with star charts and a thermos of coffee. The passengers listen as you trace constellations and tell stories about the places they connect. It's a good night."
- PaxCocktails:
    ~ return "You break out the good glasses and mix something from the ship's stores that passes for cocktails. The passengers toast each other, toast you, toast the ship. The mood is warm."
}
~ return "You spend some time with the passengers."
