/*

    Arrive in Port

*/
=== arrive_in_port(port)
~ here = port

Welcome to {LocationData(port, Name)}!
{ shuffle:
-   The station hum is almost soothing after days of engine drone. You stand in the docking bay for a moment, just listening.
-   Gravity again. Your knees complain, but the rest of you is grateful.
-   The bustle of the docking bay washes over you — other ships, other crews, other stories. It's good to be somewhere.
-   You take a breath of station air. Recycled, sure, but different recycled. That counts for something.
}

- (port_opts)
+ { here == Luna } [Fly to {LocationData(Earth, Name)}] -> transit(Earth)
+ { here == Earth } [Fly to {LocationData(Luna, Name)}] -> transit(Luna)
+ { DEBUG } [Cheats] -> debug_cheats
+ { DEBUG } [Storylets Demo] -> storylets
- -> port_opts

/*

    Debug Cheats
    Only available when DEBUG = true.

*/
= debug_cheats
- (cheat_menu)
+ [Back] -> port_opts
- -> cheat_menu
