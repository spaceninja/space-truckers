/*

    Arrive in Port

*/
=== port(location)
~ here = location

Welcome to {LocationData(here, Name)}!

- (port_opts)
+ { here == Luna } [Fly to {LocationData(Mars, Name)}] -> transit(Mars)
+ { here == Mars } [Fly to {LocationData(Luna, Name)}] -> transit(Luna)
- -> port_opts