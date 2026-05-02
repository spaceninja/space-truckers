LIST ShipLocations = Cabin, (Cockpit), (EngineRoom), (Hall)
VAR ShipDestination = Transit
VAR BobbyLocation = Hall

/*

    Transit

*/
=== transit(destination)
~ here = Transit
~ ShipDestination = destination
~ BobbyLocation = LIST_RANDOM(ShipLocations)
-> cabin

= hall
You see the stairs leading up to the cockpit, and a number of doors, most still locked.
{BobbyLocation == Hall: Bobby Troubles is here.}
- (hall_opts)
+ {BobbyLocation == Hall} [Talk to Bobby] -> talk_to_bobby ->
+ [Go to the cockpit] -> cockpit ->
+ [Go to the engine room] -> engine_room
+ [Go to your cabin] -> cabin
- -> hall_opts

= cabin
You wake up in your bunk. The ship's AI informs you that you're about 2/3 of the way to {LocationData(ShipDestination, Name)}.
- (cabin_opts)
+ [Study for your exam] -> scene_demo
+ [Leave your cabin] -> hall
- -> cabin_opts

= cockpit
Here you are in the cockpit. The seat is uncomfortable, but the view can't be beat.
{BobbyLocation == Cockpit: Bobby Troubles is here.}
- (cockpit_opts)
+ [Repair the console] -> scene_demo
+ {BobbyLocation == Cockpit} [Talk to Bobby] -> talk_to_bobby ->
+ [Leave the cockpit] -> hall
- -> cockpit_opts

= engine_room
The engine room is intimidating and full of machinery.
{BobbyLocation == EngineRoom: Bobby Troubles is here.}
- (engine_room_opts)
+ [Investigate that knocking sound] -> scene_demo
+ {BobbyLocation == EngineRoom} [Talk to Bobby] -> talk_to_bobby ->
+ [Leave the engine room] -> hall
- -> engine_room_opts

=== talk_to_bobby
"Bobby, how'd you get stuck in here?"
You grin as you free the troublesome robot from his predicament.
+ [I love that robot]
+ [I don't know why I keep that thing around]
- (redirect_bobby)
~ temp currentBobbyLocation = BobbyLocation
~ BobbyLocation = LIST_RANDOM(ShipLocations)
{ currentBobbyLocation == BobbyLocation:
    -> redirect_bobby
}
He bumbles off towards the {BobbyLocation}, chirping cheerfully.
->->

=== scene_demo
This is an example of a scene that might play out after you choose how to spend your trip.
+ [End the scene] -> port(ShipDestination)

=== function bobby_in(location)
~ return BobbyLocation == location and not came_from(-> talk_to_bobby)