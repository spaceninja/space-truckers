VAR ShipDestination = Transit
VAR FlipDone = false

/*

    Transit

*/
=== transit(destination)
~ here = Transit
~ ShipDestination = destination
Flying to {LocationData(destination, Name)}…
-> ship_options

/*

    Ship Options

*/
= ship_options
{ not FlipDone: <- task_flip }
+ { DEBUG } [\[DEBUG\] Skip Trip]
    -> arrive_in_port(ShipDestination)
-> DONE

/*

    Task Stitches
    Each stitch injects one choice into ship_options via threading (<-).
    Direct-action tasks show AP cost. Group tasks use exploratory phrasing.

*/
= task_flip
+ [Do a sick flip] -> do_flip
+ [Do a sweet flip] -> do_flip

/*

    Ship Flip
    Required once per trip at the midpoint. The ship rotates 180 degrees
    to begin deceleration.

*/
= do_flip
~ FlipDone = true
You initiate the flip sequence. The stars wheel past the viewport as the ship rotates 180 degrees. Engines now pointing forward for deceleration. Textbook.
-> ship_options
