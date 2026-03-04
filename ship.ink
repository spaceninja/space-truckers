TODO track daily tasks via action points
TODO ship flip is a required task at the halfway point
TODO paperwork is a required task for every flight
TODO ship modules degrade and need maintenance
TODO your stats affect your job performance
TODO stamina reduced by work, regained by sleep/eat
TODO misery increased by work, reduced by play, affected by cleanliness
TODO ship modules improve stat gain (better meals, maintenance, etc)
TODO ship modules have a percentage liklihood of breaking every day, based on condition
TODO you have a chance to fail tasks based on your condition (by not sleeping, you can do more, but you might fuck it up after awhile)

/*

    Transit

*/
=== transit(destination, fuel_cost, duration)
~ ShipFuel -= fuel_cost
~ here = Transit
Flying to {LocationData(destination, Name)} for {duration} days…
-> arrive_in_port(destination)

