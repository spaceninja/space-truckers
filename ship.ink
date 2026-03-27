// TODO: ship modules degrade and need maintenance
// TODO: Fatigue affects task success (chance to fail tasks when overtired)
// TODO: contextual ship maintenance variety (drain lines, laundry, secure items, etc.)
// TODO: passenger events when carrying passenger cargo
// TODO: random events (micrometeorite, power surge, cargo shift, distress signal, etc.)

VAR ShipClock = 0
VAR ShipDestination = Transit
VAR AP = 6
VAR ActionPointsMax = 6

// Task registry lists — used only for LIST_COUNT() to keep shuffle loop
// bounds in sync. Add an entry here when adding a task to a tier's shuffle.
LIST P2Tasks = EngineMaintenance, UrgentSleep
LIST P3Tasks = Paperwork, NavCheck, ShipMaintenance
LIST P4Tasks = Relax, SleepRest

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
{is_overtired(): You're exhausted. Your hands are shaking.}
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
    - { CHOICE_COUNT() < p3_cap and ShipCondition < 80: <- task_ship_maint }
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
}
~ p4_loops++
{ p4_loops < LIST_COUNT(LIST_ALL(P4Tasks)) and CHOICE_COUNT() < p4_cap: -> p4_shuffle }

// P5: Rest — only when no P1–P3 tasks are active
~ temp has_obligations = has_tier_tasks(1) or has_tier_tasks(2) or has_tier_tasks(3)
{ not has_obligations: <- task_rest }

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

= task_ship_maint
+ [Tidy up the ship] -> ship_maint_options

= task_relax
+ [Take a break] -> relax_options

= task_rest
+ [Call it a day — skip remaining {AP} AP] -> do_rest

/*

    Sub-Menu Stitches
    Each sub-menu shows flavor text, offers sub-options with AP costs,
    and includes a free "Never mind" back option.

*/

= engine_options
You pop open the engine access panel. Condition: {EngineCondition}%.
+ [Run diagnostics and tune (2 AP)] -> do_engine_maintenance
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

= ship_maint_options
The ship could use some attention. Condition: {ShipCondition}%.
+ [Clean the air filters (1 AP)] -> do_ship_maintenance
// Future: + [Drain the waste lines (1 AP)] -> do_drain_lines
// Future: + [Do the laundry (1 AP)] -> do_laundry
+ [Never mind] -> ship_options

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
{ is_overtired():
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
~ PaperworkDone++
{ PaperworkDone >= PaperworkTotal:
    You file the last of the paperwork. All customs documentation is in order.
- else:
    You work through a stack of customs forms and cargo manifests. {PaperworkTotal - PaperworkDone} chunks remaining.
}
-> pass_time(1)

/*

    Navigation Check
    Review the flight trajectory and make course corrections.

*/
= do_nav_check
~ NavChecksCompleted++
You review the flight trajectory and make minor course corrections. Everything's on track.
-> pass_time(1)

/*

    Engine Maintenance
    Restore some engine condition. Costs 2 AP (1 AP with Basic Toolkit module).

*/
= do_engine_maintenance
~ EngineCondition = MIN(EngineCondition + 15, 100)
You run diagnostics and tune the engine. Condition improved to {EngineCondition}%.
-> pass_time(2)

/*

    Ship Maintenance
    Restore ship condition. Currently only air filters; future versions
    will select contextually from a pool of maintenance tasks.

*/
= do_ship_maintenance
~ ShipCondition = MIN(ShipCondition + 12, 100)
You swap out the air filters and run a purge cycle. The ship smells noticeably fresher.
-> pass_time(1)

/*

    Eat Rations
    Quick meal — small morale boost.

*/
= do_eat_rations
~ Morale = MIN(Morale + 3, 100)
You heat up a packet of rations. It's not gourmet, but it fills the hole.
-> pass_time(1)

/*

    Recreation
    Flexible recreation handler. Cost and morale boost are parameters.

*/
= do_recreation(cost, morale_boost)
~ Morale = MIN(Morale + morale_boost, 100)
{ cost > 1:
    You settle in for a movie. For a couple of hours, you're not a trucker — you're just an audience.
- else:
    You run through a quick workout routine. Your muscles thank you.
}
-> pass_time(cost)

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
// Daily degradation
~ ShipCondition = MAX(ShipCondition - 1, 0)
~ EngineCondition = MAX(EngineCondition - 1, 0)
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

    Has Tier Tasks
    Returns true if any tasks at the given priority tier are currently eligible.
    Used for floor calculations and Rest gating.
    When adding new tasks, update the appropriate tier case here.

*/
=== function has_tier_tasks(tier)
{ tier:
    - 1: ~ return (not FlipDone and TripDay >= TripDuration / 2)
    - 2: ~ return (EngineCondition < 80) or (Fatigue >= 70)
    - 3: ~ return (PaperworkDone < PaperworkTotal) or (TripDay > 0 and TripDay mod 3 == 0 and NavChecksCompleted < TripDay / 3) or (ShipCondition < 80)
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
    triggering warnings and future task failure chance.

*/
=== function is_overtired()
~ return Fatigue >= 70
