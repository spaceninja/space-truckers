/*

    Welcome to Mars

*/
=== welcome_to_mars
~ here = Mars

Welcome to {LocationData(here, Name)}!

Outside is dusty, but red!

- (mars_opts)
+ [Fly to {LocationData(Luna, Name)}] -> transit(Luna)
- -> mars_opts