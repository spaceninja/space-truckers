TODO ship flip is a required task at the halfway point
TODO paperwork is a required task for every flight
TODO ship modules degrade and need maintenance
TODO your stats affect your job performance
TODO stamina reduced by work, regained by sleep/eat
TODO misery increased by work, reduced by play, affected by cleanliness
TODO ship modules improve stat gain (better meals, maintenance, etc)
TODO ship modules have a percentage likelihood of breaking every day, based on condition
TODO you have a chance to fail tasks based on your condition (by not sleeping, you can do more, but you might fuck it up after awhile)

VAR ShipClock = 0
VAR ShipDestination = Transit
VAR AP = 6
VAR ActionPointsMax = 6
VAR AwakeDuration = 0

/*

    Transit

*/
=== transit(destination, fuel_cost, duration)
~ here = Transit
~ ShipDestination = destination
~ ShipFuel -= fuel_cost
~ ShipClock = duration
Flying to {LocationData(destination, Name)} for {duration} days…
-> ship_options

/*

    Ship Options

*/
= ship_options
{AwakeDuration > ActionPointsMax: If you don't get some sleep soon, you'll start making mistakes.}
<center><em><small>{ShipClock} days to {LocationData(ShipDestination, Name)} / {AP} AP remaining</small></em></center>
- (ship_opts)
+ [Short Task (1 AP)]
    -> pass_time(1)
+ [Long Task (2 AP)]
    -> pass_time(2)
+ {can_sleep()} [Nap (1 AP)]
    -> sleep(1)
+ {can_sleep()} [Sleep (2 AP)]
    -> sleep(2)
-> END

/*

    Sleep

*/
= sleep(amount)
~ AwakeDuration = 0
{ amount > 1:
    You fall into your bunk and sleep like the dead.
    -> pass_time(2)
- else:
    You grab a quick power nap in the captain's chair. It's better than nothing.
    -> pass_time(1)
}

/*

    Pass Time
    Reduce the available action point.

*/
= pass_time(amount)
~ AP -= amount
{ not came_from(-> sleep):
    ~ AwakeDuration += amount
}
{ AP > 0:
    -> ship_options
- else:
    -> next_day(AP)
}

/*

    Next Day
    Advance the clock and reset the available action points.

*/
= next_day(rollover)
~ ShipClock--
~ AP = ActionPointsMax + rollover
{ ShipClock == 0:
    -> arrive_in_port(ShipDestination)
}
-> ship_options

/*

    Can The Player Sleep?
    Checks if it's been long enough since the player last slept to offer sleep actions again.

*/
=== function can_sleep()
~ return AwakeDuration >= ActionPointsMax - 2
