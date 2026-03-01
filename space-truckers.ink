INCLUDE cargo.ink
INCLUDE functions.ink

LIST Locations = Transit, Earth, Mars, Luna
LIST Data = From, To, Mass, Pay, Title

VAR here = Earth
VAR BankBalance = 1000
VAR ShipCapacity = 40
VAR ShipCargo = ()
VAR PortCargo = ()

-> arrive_in_port(here)

TODO track fuel capacity
TODO track fuel expenditure (mass x distance)
TODO allow to buy fuel
TODO check fuel level before departing
TODO add more ports
TODO add more cargo
TODO define distances between ports

/*

    Arrive in Port

*/
=== arrive_in_port(port)
~ here = port

// Randomly select available cargo when arriving in port
~ PortCargo = available_cargo(port, 3)

Welcome to {port}! What do you want to ship?

- (port_opts)
+ [Load cargo] -> choose_cargo
+ [Manage cargo] -> manage_cargo
+ [Deliver cargo] -> deliver_cargo
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
+ [Load {CargoData(cargo, Title)} ({CargoData(cargo, To)}, {CargoData(cargo, Mass)}t, {CargoData(cargo, Pay)} €)]
    ~ AllCargo -= cargo
    ~ PortCargo -= cargo
    ~ ShipCargo += cargo
    Your cargo is {CargoData(cargo, Title)} from {CargoData(cargo, From)} bound for {CargoData(cargo, To)}, with a mass of {CargoData(cargo, Mass)} metric tons, which pays {CargoData(cargo, Pay)} euros.
    -> choose_cargo

/*

    Manage Cargo

*/
= manage_cargo
~ temp _choices = ShipCargo
current mass = {total_mass(ShipCargo)} / {ShipCapacity}t
{ LIST_COUNT(ShipCargo) == 0:
    You have no cargo loaded.
}
- (top)
    ~ temp cargo = pop(_choices)
    { cargo:
        <- reject(cargo)
        -> top
    }
-
+ [Done] -> port_opts

= reject(cargo)
+ [Unload {CargoData(cargo, Title)} ({CargoData(cargo, To)}, {CargoData(cargo, Mass)}t, {CargoData(cargo, Pay)} €)]
    ~ AllCargo += cargo
    ~ PortCargo += cargo
    ~ ShipCargo -= cargo
    -> manage_cargo

/*

    Deliver Cargo

*/
= deliver_cargo
~ temp _items = ShipCargo
- (top)
~ temp cargo = pop(_items)
~ temp delivery_count = 0
{ cargo:
    ~ temp to = CargoData(cargo, To)
    { to == here:
        Delivered {CargoData(cargo, Title)} from {CargoData(cargo, From)} for {CargoData(cargo, Pay)} €.
        ~ delivery_count++
        ~ ShipCargo -= cargo
        ~ BankBalance += CargoData(cargo, Pay)
    }
    -> top
}
{ delivery_count > 0:
    All cargo for {here} delivered! Your bank account balance is {BankBalance} €.
- else:
    You have no cargo to deliver to {here}.
}
+ [Done] -> port_opts

/*

    Ship Out

*/
= ship_out
{ total_mass(ShipCargo) > ShipCapacity:
    Oops! You've added more mass than your ship can haul to your destination. You'll need to put something back before you can ship out.
    -> port_opts
}
+ {here != Earth} [Go to Earth] -> transit(Earth)
+ {here != Luna} [Go to Luna] -> transit(Luna)
+ {here != Mars} [Go to Mars] -> transit(Mars)
+ [Cancel] -> port_opts

/*

    Transit

*/
= transit(destination)
~ here = Transit
Flying to {destination}…
-> arrive_in_port(destination)
