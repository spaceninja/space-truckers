/*

    Random Events
    P0 interruptions that fire during transit. When triggered, the player
    is diverted here before seeing the task list. After resolution they
    return to ship_options via pass_time(), which handles AP and flow.

    Triggering: checked each time ship_options is entered. EventChance
    starts at 0% and increases 3% per check. Resets to 0 after an event
    fires. EventCooldownDay prevents more than one event per day.

    Events don't repeat within a trip — each event is removed from the
    Events list after firing. The list is reset to all-active in transit().

    Adding a new event:
    1. Add an entry to the Events list below (in parentheses = active)
    2. Write an event_* knot below
    3. Add a dispatch line in random_event: { chosen == Name: -> event_name }
    4. If the event has an eligibility condition, add a removal line in random_event

*/

// Event registry — tracks which events are still available this trip.
// Events are set active at trip start and deactivated after firing,
// preventing repeats. Add new events here and in the dispatch block below.
LIST Events = (Micrometeorite), (PowerSurge), (DistressSignal), (CargoShift), (Shortcut)

/*

    Random Event Dispatcher
    Builds an eligible set from remaining events, picks one at random.
    The chosen event is removed from the pool so it won't repeat this trip.

*/
=== random_event
// Start with events that haven't fired this trip, remove dynamically ineligible ones
// (Static eligibility like cargo checks is handled at trip start in transit())
~ temp eligible = Events
{ eligible ? Shortcut and ShipClock <= 1:
    ~ eligible -= Shortcut
}
~ temp eligible_count = LIST_COUNT(eligible)

{ eligible_count <= 0:
    // No eligible events remain, skip
    -> transit.ship_options
}

~ temp chosen = LIST_RANDOM(eligible)
~ Events -= chosen  // remove from pool so it won't repeat this trip

{ chosen == Micrometeorite: -> event_micrometeorite }
{ chosen == PowerSurge: -> event_power_surge }
{ chosen == DistressSignal: -> event_distress_signal }
{ chosen == CargoShift: -> event_cargo_shift }
{ chosen == Shortcut: -> event_shortcut }
// Fallback (shouldn't reach here)
-> event_micrometeorite

/*

    Damage Random System
    Stub: always damages EngineCondition for now.
    When modules are implemented, update this function to randomly
    choose from installed modules + engine.

*/
=== function damage_random_system(amount)
~ EngineCondition = MAX(EngineCondition - amount, 0)

/*

    Micrometeorite Strike
    A micrometeorite impacts the hull. Must be repaired immediately.
    Fatigue check: failure costs extra AP and adds a fuel penalty.
    After repair, roll for what was damaged.

*/
=== event_micrometeorite
A sharp crack echoes through the hull followed by the hiss of escaping air. Warning lights flood the cockpit — micrometeorite strike. You need to patch this now.

{ fatigue_check():
    ~ TripFuelPenalty = TripFuelPenalty + TripFuelCost / 20  // +5% fuel: ship drifted during slow repair
    You're exhausted and your hands are clumsy. The patch takes twice as long as it should, and by the time you're done the ship has drifted off course.
    -> meteor_damage(3)
- else:
    You move fast and seal the breach cleanly.
    -> meteor_damage(2)
}

= meteor_damage(ap_cost)
// Roll for what got damaged
~ temp damage_roll = RANDOM(1, 10)
{
- damage_roll <= 3:
    // Lucky — no significant damage
    You inspect the impact site. The meteorite glanced off a reinforced section. Lucky.
- damage_roll <= 6:
    // Cargo hit
    ~ CargoDamagePct = MIN(CargoDamagePct + 15, 100)
    Debris punched through the cargo hold. Some of your shipment took damage.
- else:
    // System damage
    ~ damage_random_system(20)
    A ship system took a direct hit. You'll need to keep an eye on that.
}
-> transit.pass_time(ap_cost)

/*

    Power Surge
    An electrical surge ripples through the ship's systems.
    Two resolution options with different tradeoffs.
    Both have a fatigue check.

*/
=== event_power_surge
Alarms blare as a power surge ripples through the ship's electrical systems. Sparks fly from a junction panel. You have two options.

+ [Isolate the surge — reroute power around the damaged section]
    -> power_surge_quick
+ [Shut down and do a full system reset]
    -> power_surge_proper

= power_surge_quick
You pull up the power routing panel and start rerouting circuits. It's fast and dirty, but it'll keep you flying.
{ fatigue_check():
    You fumble the reroute. The damage spreads before you can isolate it.
    ~ damage_random_system(40)
    -> transit.pass_time(3)
- else:
    The surge is contained. One system took a hit, but the ship is stable.
    ~ damage_random_system(25)
    -> transit.pass_time(2)
}

= power_surge_proper
You cut all non-essential power and run a full system reset. The ship goes dark for a few minutes.
{ fatigue_check():
    You fumble the restart sequence. The ship drifts longer than it should, and there's minor residual damage despite your careful approach.
    ~ TripFuelPenalty = TripFuelPenalty + TripFuelCost / 20  // +5% fuel: extended drift
    ~ damage_random_system(15)
    -> transit.pass_time(4)
- else:
    Clean shutdown, clean restart. No damage, but the ship drifted during the downtime.
    ~ TripFuelPenalty = TripFuelPenalty + TripFuelCost / 20  // +5% fuel: drift during shutdown
    -> transit.pass_time(3)
}

/*

    Cargo Shift
    Cargo has shifted in the hold and must be secured.
    Only fires when the player has cargo.
    Fatigue check: failure means some cargo is damaged before you secure it.

*/
=== event_cargo_shift
A jolt rocks the ship. You hear the unmistakable sound of cargo shifting in the hold — if it's not secured quickly, something's going to break.

{ fatigue_check():
    You're too slow getting back there. By the time you've secured everything, some of the cargo has already taken a beating.
    ~ CargoDamagePct = MIN(CargoDamagePct + 15, 100)
- else:
    You catch it in time, bracing the shifted containers before anything breaks loose.
}
-> transit.pass_time(2)

/*

    Distress Signal
    Another ship is in trouble. Three options with different costs and rewards.

*/
=== event_distress_signal
A distress signal cuts through the comms static. A cargo hauler, call sign Meridian Star, has lost engine power and is drifting. They're not in immediate danger, but without help they're looking at weeks before a rescue tug finds them.

+ [Stop and help with repairs — spend the time, do it right]
    -> distress_help_full
+ [Share some supplies and spare parts — get them limping]
    -> distress_help_partial
+ [Send a distress relay to the nearest station and keep flying]
    -> distress_ignore

= distress_help_full
You match velocity and spend the better part of the day working on their engine alongside their crew. It's good work and you're glad you stopped.
~ PlayerBankBalance += 500
~ temp reward = 500
They press {reward} € into your hand before you undock. "You saved us weeks out here."
-> transit.pass_time(4)

= distress_help_partial
You pass over a kit of spare parts and a few canisters of fuel through the airlock. Not a full fix, but enough to get them moving.
~ PlayerBankBalance += 150
~ Morale = MIN(Morale + 10, 100)
They thank you warmly. {150} € and the knowledge you did something good.
-> transit.pass_time(2)

= distress_ignore
You log the signal, punch in the coordinates of the nearest relay station, and broadcast a distress packet on their behalf. Someone will find them. Probably.
You get back to work.
-> transit.ship_options

/*

    Navigation Shortcut
    A potential faster route has appeared on sensors.
    No AP cost — the outcome affects ShipClock.

*/
=== event_shortcut
Your nav computer flags an alternate route — a gravitational slingshot corridor that most pilots avoid due to unpredictable debris density. It could shave time off the trip. Or not.

+ [Take the shortcut]
    -> shortcut_take
+ [Stay on the charted course]
    You note it for the logs and get back to work. Better safe than sorry.
    -> transit.ship_options

= shortcut_take
~ temp roll = RANDOM(1, 4)
{
- roll == 1:
    // Save time and fuel
    ~ ShipClock = MAX(ShipClock - 1, 1)
    ~ TripFuelPenalty = MAX(TripFuelPenalty - TripFuelCost / 20, 0)  // small fuel refund: slingshot boost
    The slingshot works perfectly. The gravitational assist kicks you forward and you gain almost a full day. Even the fuel consumption is down.
- roll == 2:
    // Save time, no fuel savings
    ~ ShipClock = MAX(ShipClock - 1, 1)
    The corridor works as advertised, but the maneuvering to stay clear of the debris ate up whatever fuel you saved. Still — you're a day ahead of schedule.
- roll == 3:
    // No change
    The corridor looked promising but turned out to have its own set of obstacles. You spend as long navigating through it as you would have on the standard route. Nothing gained, nothing lost.
- else:
    // Backfire — add time
    ~ ShipClock = ShipClock + 1
    Turns out there's a reason nobody comes this way. The debris is denser than the charts suggested and you spend hours carefully threading through it. You've actually lost time.
}
-> transit.ship_options
