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
LIST Events = (Micrometeorite), (PowerSurge), (DistressSignal), (CargoShift), (Shortcut), (CoffeeMachine), (PassengerBirthday), (PassengerComplaint), (PassengerConversation), (MedicalEmergency)

// Passenger event subset — removed from Events at trip start when no
// passenger cargo is aboard. Keep in sync with the Events list above.
VAR PassengerEvents = (PassengerBirthday, PassengerComplaint, PassengerConversation, MedicalEmergency)

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
{ chosen == CoffeeMachine: -> event_coffee_machine }
{ chosen == PassengerBirthday: -> event_passenger_birthday }
{ chosen == PassengerComplaint: -> event_passenger_complaint }
{ chosen == PassengerConversation: -> event_passenger_conversation }
{ chosen == MedicalEmergency: -> event_medical_emergency }
// Fallback (shouldn't reach here)
-> event_micrometeorite

/*

    Damage Random System
    Damages a random system: 50% chance engine, 50% chance a random
    installed module. If no modules installed, always damages engine.
    Module condition floors at 1 (not 0, since 0 = not installed).

*/
=== function damage_random_system(amount)
~ temp module_count = LIST_COUNT(InstalledModules)
{ module_count == 0:
    ~ EngineCondition = MAX(EngineCondition - amount, 0)
    ~ return
}
~ temp roll = RANDOM(1, 100)
{ roll <= 50:
    ~ EngineCondition = MAX(EngineCondition - amount, 0)
    ~ return
}
~ temp target = LIST_RANDOM(InstalledModules)
~ temp current = get_module_condition(target)
~ set_module_condition(target, MAX(current - amount, 1))

/*

    Medical Module Check
    Returns true if the Wellness Suite is installed and active (condition >= 50).

*/
=== function has_medical_module()
~ return is_module_active(WellnessSuite)

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

/*

    Coffee Machine Breakdown
    The coffee machine has stopped working. The player can spend 2 AP to fix it
    or take a significant morale hit. If carrying passengers, an additional
    morale penalty applies if it goes unrepaired.

*/
=== event_coffee_machine
A grinding noise from the galley, then silence. You investigate. The coffee machine has died.
{ has_passenger_cargo(ShipCargo):
    One of your passengers pokes their head in to ask about morning coffee. You don't have good news.
}

+ [Fix it — spend the time tracking down the problem (2 AP)]
    -> coffee_fix
+ [Leave it broken — you'll manage]
    -> coffee_ignore

= coffee_fix
You pull the machine apart, diagnose a clogged heating element, and spend two hours putting it back together right. The first cup it makes is mediocre. The second one is perfect.
~ Morale = MIN(Morale + 5, 100)
-> transit.pass_time(2)

= coffee_ignore
~ Morale = MAX(Morale - 15, 0)
You try to convince yourself you don't need it. You absolutely need it. The rest of the day is worse for it.
{ has_passenger_cargo(ShipCargo):
    ~ Morale = MAX(Morale - 5, 0)
    Your passengers are not happy about it either. You get three separate complaints before lunch.
}
-> transit.ship_options

/*

    Passenger Birthday
    A passenger's birthday. Opportunity to celebrate.
    Only fires when carrying passenger cargo.

*/
=== event_passenger_birthday
One of your passengers flags you down in the corridor. Turns out it's their birthday — they're sheepish about mentioning it, but you can tell they'd appreciate some acknowledgment.

+ [Throw a small celebration — break out some rations and make it festive]
    -> birthday_celebrate
+ [Wish them a happy birthday and get back to work]
    ~ Morale = MIN(Morale + 5, 100)
    You wish them well with a genuine smile. They seem touched that you remembered. Small gestures count for something out here.
    -> transit.ship_options

= birthday_celebrate
You clear a table in the common area, dig out something that passes for cake mix, and round up the other passengers.
{ fatigue_check():
    You're running on fumes and it shows. The "celebration" is half-hearted — you burn the cake and can barely keep your eyes open through the singing. It's the thought that counts, but only just.
    ~ Morale = MIN(Morale + 5, 100)
- else:
    It's nothing fancy, but the passengers are laughing and trading stories, and for a little while the ship feels less like a cargo hauler and more like somewhere people actually want to be.
    ~ Morale = MIN(Morale + 10, 100)
}
-> transit.pass_time(1)

/*

    Passenger Complaint
    A passenger is unhappy about conditions aboard the ship.
    Only fires when carrying passenger cargo.

*/
=== event_passenger_complaint
A passenger corners you outside the cockpit. The air recycler is making a noise that's keeping them up, the food is awful, and the heating in their berth is inconsistent. They want something done about it.

+ [See what you can do to fix their complaints]
    -> complaint_accommodate
+ [Apologise but explain this is a cargo ship, not a cruise liner]
    ~ Morale = MIN(MAX(Morale - 5, 0), 100)
    You're sympathetic but honest — this is a working freighter, not a passenger vessel. They're not happy, but they accept it. The mood aboard drops a little.
    -> transit.ship_options

= complaint_accommodate
You head down to check the recycler and tweak the heating.
{ fatigue_check():
    You try, but you're too tired to focus. You fiddle with the recycler and adjust the heating, but honestly you're not sure you've fixed anything. The passenger thanks you, though they don't sound convinced.
- else:
    ~ Morale = MIN(Morale + 5, 100)
    The recycler had a loose panel — easy fix once you found it. You adjust the heating and throw in an extra blanket for good measure. The passenger seems genuinely grateful.
}
-> transit.pass_time(1)

/*

    Passenger Conversation
    A passenger strikes up a conversation during downtime.
    Only fires when carrying passenger cargo.
    No fatigue check — this is a relaxing interaction.

*/
=== event_passenger_conversation
You're running through a systems check when one of your passengers drifts into the cockpit. They're not complaining — they're just curious. They ask about the ship, the route, what it's like out here.

+ [Chat with them for a while]
    ~ Morale = MIN(Morale + 5, 100)
    ~ Fatigue = MAX(Fatigue - 5, 0)
    You lean back and talk. They're good company — asking questions, listening to the answers, sharing their own stories. By the time they head back to their berth, you feel lighter than you have in days.
    -> transit.pass_time(1)
+ [Politely excuse yourself — you've got work to do]
    You explain you're in the middle of something and they nod, heading back without complaint. Back to work.
    -> transit.ship_options

/*

    Medical Emergency
    A passenger collapses with a medical emergency. The player must choose
    between calling a medical shuttle (against the passenger's wishes) or
    letting them stay aboard and gambling on the outcome.
    Only fires when carrying passenger cargo.

    // TODO: This event is a good candidate for a "delayed event outcome"
    // system — resolve the passenger's fate a day or two later instead of
    // immediately, to build tension. If another event would also benefit
    // from delayed resolution, build the system then.

*/
=== event_medical_emergency
A shout from the passenger berths snaps you out of your routine. One of your passengers has collapsed — they're conscious but in bad shape. You radio for emergency medical services and get a response: a fast medical shuttle can intercept your trajectory within hours.

But when you tell the passenger, they grab your arm. Their family is aboard — spouse, kids. The shuttle only has room for the patient. "Please," they say. "Don't send me away from them."

You look at the shuttle ETA on your console, then at the family huddled in the doorway. This feels like a bad idea. What if they get worse?

+ [Call the shuttle — their health comes first]
    -> medical_call_shuttle
+ [Let them stay — respect their wishes and do what you can]
    -> medical_stay_aboard

= medical_call_shuttle
You make the call. The passenger argues, then pleads, but you hold firm. When the shuttle docks, the medics transfer them quickly and professionally. The family watches from the airlock window as the shuttle pulls away.
~ Morale = MIN(MAX(Morale - 10, 0), 100)
~ ShipClock = ShipClock + 1
The ship is quiet afterward. You did the right thing — you know that. But the kids won't look at you, and the silence is heavier than it should be.
-> transit.pass_time(2)

= medical_stay_aboard
You tell the shuttle to stand by and turn back to the passenger. "Alright. You're staying. But you do exactly what I tell you."
~ Morale = MIN(Morale + 5, 100)
The family crowds in, grateful and terrified in equal measure. You dig out the first aid kit and do everything you can.
-> medical_stay_outcome

= medical_stay_outcome
~ temp outcome_roll = RANDOM(1, 100)
~ temp improve_chance = 50
~ temp worsen_chance = 90
{ has_medical_module():
    ~ improve_chance = 75
    ~ worsen_chance = 100  // no death possible with medical module
}
{
- outcome_roll <= improve_chance:
    Over the next few hours, colour returns to their face. Their breathing steadies. By evening they're sitting up, sipping water, and arguing with their spouse about whether they should have taken the shuttle. You take that as a good sign.
- outcome_roll <= worsen_chance:
    ~ Morale = MIN(MAX(Morale - 10, 0), 100)
    They don't improve. If anything, they get worse — fever spikes, breathing goes shallow. You do what you can, but you're a pilot, not a doctor. They're stable enough to make it to port, but it's going to be a rough ride. You can't shake the feeling you made the wrong call.
- else:
    // 10% chance without medical module — the worst outcome
    ~ Morale = MIN(MAX(Morale - 20, 0), 100)
    You do everything right. You follow every step in the emergency manual. It's not enough.
    They pass quietly in the small hours, family around them. You sit in the cockpit afterward, staring at the stars, wondering if you'd made a different choice whether it would have mattered.
    The family doesn't blame you. That almost makes it worse.
}
-> transit.pass_time(1)
