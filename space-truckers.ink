INCLUDE cargo.ink
INCLUDE ports.ink
INCLUDE functions.ink


LIST Data = From, To, Mass, Pay, Title, Distance

VAR here = Earth
VAR BankBalance = 50
VAR ShipFuel = 750
VAR ShipFuelCapacity = 1000
VAR FuelCost = 1.5
VAR ShipCapacity = 40
VAR ShipCargo = ()
VAR PortCargo = ()
VAR EconomyMode = 3
VAR BalanceMode = 4
VAR TurboMode = 5

-> arrive_in_port(here)

TODO add more ports
TODO add more cargo

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
+ [Buy fuel] -> fuel_station
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
        <- load(cargo)
        -> top
    }
-
+ [Done] -> port_opts

= load(cargo)
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
        <- unload(cargo)
        -> top
    }
-
+ [Done] -> port_opts

= unload(cargo)
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

    Buy Fuel

*/
= fuel_station
~ temp fuel_needed = ShipFuelCapacity - ShipFuel
~ temp half_tank = ShipFuelCapacity / 2
~ temp quarter_tank = ShipFuelCapacity / 4
~ temp full_cost = INT(fuel_needed * FuelCost)
~ temp half_cost = INT(half_tank * FuelCost)
~ temp quarter_cost = INT(quarter_tank * FuelCost)
~ temp min_fuel = BankBalance / FuelCost
The current unit cost of fuel is {FuelCost} €. Your fuel gauge reads {ShipFuel}/{ShipFuelCapacity}. Your bank account balance is {BankBalance} €.
{ShipFuel < ShipFuelCapacity:
    + {BankBalance >= full_cost}
        [Fill it up ({full_cost} €)]
        ~ buy_fuel(fuel_needed)
        -> fuel_station
    + {BankBalance < full_cost}
        [Put in {BankBalance} €]
        ~ buy_fuel(min_fuel)
        -> fuel_station
    + {fuel_needed > half_tank and BankBalance > half_cost}
        [Half tank ({half_cost} €)]
        ~ buy_fuel(half_tank)
        -> fuel_station
    + {fuel_needed > quarter_tank and BankBalance > quarter_cost}
        [Quarter tank ({quarter_cost} €)]
        ~ buy_fuel(quarter_tank)
        -> fuel_station
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
+ {here != Earth} [Go to Earth] -> flight_options(Earth)
+ {here != Luna} [Go to Luna] -> flight_options(Luna)
+ {here != Mars} [Go to Mars] -> flight_options(Mars)
+ [Cancel] -> port_opts

= flight_options(to)
~ temp slow_cost = get_fuel_cost(here, to, EconomyMode)
~ temp norm_cost = get_fuel_cost(here, to, BalanceMode)
~ temp fast_cost = get_fuel_cost(here, to, TurboMode)
~ temp slow_time = get_trip_duration(here, to, EconomyMode)
~ temp norm_time = get_trip_duration(here, to, BalanceMode)
~ temp fast_time = get_trip_duration(here, to, TurboMode)
+ {ShipFuel >= slow_cost}
    [Economy Mode ({slow_cost} fuel, {slow_time} days)]
    -> transit(to, slow_cost, slow_time)
+ {ShipFuel < slow_cost}
    [Economy Mode ({slow_cost} fuel, {slow_time} days) #UNCLICKABLE]
    You do not have enough fuel to use economy mode.
    -> port_opts
+ {ShipFuel >= norm_cost}
    [Balance Mode ({norm_cost} fuel, {norm_time} days)]
    -> transit(to, norm_cost, norm_time)
+ {ShipFuel < norm_cost}
    [Balance Mode ({norm_cost} fuel, {norm_time} days) #UNCLICKABLE]
    You do not have enough fuel to use balance mode.
    -> port_opts
+ {ShipFuel >= fast_cost}
    [Turbo Mode ({fast_cost} fuel, {fast_time} days)]
    -> transit(to, fast_cost, fast_time)
+ {ShipFuel < fast_cost}
    [Turbo Mode ({fast_cost} fuel, {fast_time} days) #UNCLICKABLE]
    You do not have enough fuel to use turbo mode.
    -> port_opts
+ [Cancel] -> port_opts

/*

    Transit

*/
= transit(destination, fuel, duration)
~ ShipFuel -= fuel_station
~ here = Transit
Flying to {destination} for {duration} days…
-> arrive_in_port(destination)
