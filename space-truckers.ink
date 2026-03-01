INCLUDE cargo.ink
INCLUDE functions.ink

LIST Locations = Transit, Earth, Mars, Moon
LIST Data = From, To, Mass, Pay, Title

VAR here = Earth
VAR BankBalance = 1000
VAR ShipCapacity = 40
VAR ShipCargo = ()
VAR PortCargo = ()

TODO unload on arrival (add payment)
TODO allow removing loaded cargo

-> arrive_in_port(here)

/*

    Arrive in Port

*/
=== arrive_in_port(port)
// Randomly select available cargo when arriving in port
// ~ temp choices = available_cargo(port, 3)
~ here = port
~ PortCargo = list_random_subset_of_size(AllCargo, 3)

Welcome to {port}! What do you want to ship?

- (port_opts)
+ [Choose cargo] -> choose_cargo
+ [Ship out!] -> ship_out
- -> port_opts

/*

    Choose Cargo

*/
= choose_cargo
~ temp _choices = PortCargo
current mass = {total_mass(ShipCargo)} / {ShipCapacity}t
- (top)
    ~ temp cargo = pop(_choices)
    { cargo:
        <- accept(cargo)
        -> top
    }
-
+ [Done] -> port_opts

= accept(cargo)
+ [{CargoData(cargo, Title)} ({CargoData(cargo, Mass)}t, {CargoData(cargo, Pay)} €)]
    ~ AllCargo -= cargo  // not available for future selection
    ~ PortCargo -= cargo // not available for current selection
    ~ ShipCargo += cargo // add to ship's cargo
    Your cargo is {CargoData(cargo, Title)} from {CargoData(cargo, From)} bound for {CargoData(cargo, To)}, with a mass of {CargoData(cargo, Mass)} metric tons, which pays {CargoData(cargo, Pay)} euros.
    -> choose_cargo

/*

    Ship Out

*/
= ship_out
{ total_mass(ShipCargo) > ShipCapacity:
    Oops! You've added more mass than your ship can haul to your destination. You'll need to put something back before you can ship out.
    -> port_opts
}
Have a nice trip!
{ here:
    - Earth:
        -> transit(Mars)
    - Mars:
        -> transit(Earth)
    - else:
        -> END // something went very wrong
}

/*

    Transit

*/
= transit(destination)
~ here = Transit
Flying to {destination}…
-> arrive_in_port(destination)
