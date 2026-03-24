// TODO: ship modules degrade and need maintenance
// TODO: Fatigue affects task success (chance to fail tasks when overtired)
// TODO: contextual ship maintenance variety (drain lines, laundry, secure items, etc.)
// TODO: passenger events when carrying passenger cargo
// TODO: random events (micrometeorite, power surge, cargo shift, distress signal, etc.)

VAR ShipClock = 0
VAR ShipDestination = Transit
VAR AP = 6
VAR ActionPointsMax = 6

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
Flying to {LocationData(destination, Name)} for {duration} days…
-> ship_options

/*

    Ship Options

*/
= ship_options
{is_overtired(): You're exhausted. Your hands are shaking.}
<center><em><small>{ShipClock} days to {LocationData(ShipDestination, Name)} / {AP} AP remaining</small></em></center>
- (ship_opts)

// No AP checks needed — the AP system allows borrowing from the next day
// (negative AP rolls over via next_day). On the final day, any negative
// rollover is harmlessly discarded on arrival.

// P1: Ship flip (at midpoint, if not done)
+ {not FlipDone and TripDay >= TripDuration / 2}
    [Execute ship flip (1 AP)]
    -> do_flip

// P2: Engine maintenance (when condition < 80%)
+ {EngineCondition < 80}
    [Engine maintenance (2 AP)]
    -> do_engine_maintenance

// P2: Sleep (when very fatigued)
+ {Fatigue >= 70}
    [Sleep (2 AP)]
    -> sleep(2)

// P3: Paperwork (when chunks remain)
+ {PaperworkDone < PaperworkTotal}
    [File paperwork — {PaperworkDone}/{PaperworkTotal} (1 AP)]
    -> do_paperwork

// P3: Navigation check (appears every 3 days)
+ {TripDay > 0 and TripDay mod 3 == 0}
    [Navigation check (1 AP)]
    -> do_nav_check

// P3: Ship maintenance (when condition < 80%)
+ {ShipCondition < 80}
    [Clean air filters (1 AP)]
    -> do_ship_maintenance

// P4: Cooking
+ [Heat up rations (1 AP)]
    -> do_eat_rations

// P4: Recreation
+ [Watch a movie (2 AP)]
    -> do_recreation(2, 15)

+ [Quick workout (1 AP)]
    -> do_recreation(1, 8)

// P4: Nap (moderate fatigue)
+ {Fatigue >= 30}
    [Nap (1 AP)]
    -> sleep(1)

// P4: Sleep (available when fatigued enough, but not yet urgent)
+ {Fatigue >= 40 and Fatigue < 70}
    [Sleep (2 AP)]
    -> sleep(2)

- -> END

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

    Pass Time
    Deduct AP. If not sleeping, accumulate fatigue with gravity modifier.

*/
= pass_time(amount)
~ AP -= amount
{ not came_from(-> sleep):
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
