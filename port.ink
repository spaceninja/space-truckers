VAR PortFuelCost = 1.5
VAR PortCargo = ()

/*

    Arrive in Port

*/
=== arrive_in_port(port)
~ here = port
~ PortCargo = get_available_cargo(port, 3)

Welcome to {LocationData(port, Name)}!

- (port_opts)
+ [Load cargo]
     What do you want to ship?
    -> choose_cargo
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
current mass = {total_mass(ShipCargo)} / {ShipCargoCapacity}t
- (top)
    ~ temp cargo = pop(_choices)
    { cargo:
        <- load(cargo)
        -> top
    }
-
+ [Done] -> port_opts

= load(cargo)
~ temp toName = LocationData(CargoData(cargo, To), Name)
+ [Load {CargoData(cargo, Title)} ({toName}, {CargoData(cargo, Mass)}t, € {CargoData(cargo, Pay)})]
    ~ AllCargo -= cargo
    ~ PortCargo -= cargo
    ~ ShipCargo += cargo
    -> choose_cargo

/*

    Manage Cargo

*/
= manage_cargo
~ temp _choices = ShipCargo
current mass = {total_mass(ShipCargo)} / {ShipCargoCapacity}t
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
~ temp toName = LocationData(CargoData(cargo, To), Name)
+ [Unload {CargoData(cargo, Title)} ({toName}, {CargoData(cargo, Mass)}t, € {CargoData(cargo, Pay)})]
    ~ AllCargo += cargo
    ~ PortCargo += cargo
    ~ ShipCargo -= cargo
    -> manage_cargo

/*

    Deliver Cargo

*/
= deliver_cargo
~ temp _items = ShipCargo
~ temp delivery_count = 0
- (top)
~ temp cargo = pop(_items)
{ cargo:
    ~ temp to = CargoData(cargo, To)
    { to == here:
        ~ delivery_count++
        ~ ShipCargo -= cargo
        ~ PlayerBankBalance += CargoData(cargo, Pay)
        ~ temp fromName = LocationData(CargoData(cargo, From), Name)
        Delivered {CargoData(cargo, Title)} from {fromName} for {CargoData(cargo, Pay)} €.
    }
    -> top
}
{ delivery_count > 0:
    All cargo for {LocationData(here, Name)} delivered! Your bank account balance is {PlayerBankBalance} €.
- else:
    You have no cargo to deliver to {LocationData(here, Name)}.
}
+ [Done] -> port_opts

/*

    Buy Fuel

*/
= fuel_station
~ temp fuel_needed = ShipFuelCapacity - ShipFuel
~ temp half_tank = ShipFuelCapacity / 2
~ temp quarter_tank = ShipFuelCapacity / 4
~ temp full_cost = INT(fuel_needed * PortFuelCost)
~ temp half_cost = INT(half_tank * PortFuelCost)
~ temp quarter_cost = INT(quarter_tank * PortFuelCost)
~ temp min_fuel = PlayerBankBalance / PortFuelCost
The current unit cost of fuel is {PortFuelCost} €. Your fuel gauge reads {ShipFuel}/{ShipFuelCapacity}. Your bank account balance is {PlayerBankBalance} €.
{ShipFuel < ShipFuelCapacity:
    + {PlayerBankBalance >= full_cost}
        [Fill it up ({full_cost} €)]
        -> buy_fuel(fuel_needed)
    + {PlayerBankBalance < full_cost}
        [Put in {PlayerBankBalance} €]
        -> buy_fuel(min_fuel)
    + {fuel_needed > half_tank and PlayerBankBalance > half_cost}
        [Half tank ({half_cost} €)]
        -> buy_fuel(half_tank)
    + {fuel_needed > quarter_tank and PlayerBankBalance > quarter_cost}
        [Quarter tank ({quarter_cost} €)]
        -> buy_fuel(quarter_tank)
}
+ [Done] -> port_opts

= buy_fuel(amount_requested)
// safety check that they don't ask for more fuel than capacity
~ temp fuel_needed = ShipFuelCapacity - ShipFuel
~ temp amount = MIN(fuel_needed, FLOOR(amount_requested))
// calculate the cost for the real amount of fuel
~ temp cost = INT(amount * PortFuelCost)
{
- PlayerBankBalance < cost:
    “Sorry, your credit chip was declined.”
- PlayerBankBalance >= cost:
    ~ ShipFuel = MIN(ShipFuel + amount, 100)
    ~ PlayerBankBalance -= MAX(cost, 0)
    “Thank you, come again!”
}
- -> fuel_station

/*

    Ship Out

*/
= ship_out
{ total_mass(ShipCargo) > ShipCargoCapacity:
    Oops! You've added more mass than your ship can haul to your destination. You'll need to put something back before you can ship out.
    -> port_opts
}
+ {here != Earth} [Go to {LocationData(Earth, Name)}] -> flight_options(Earth)
+ {here != Luna} [Go to {LocationData(Luna, Name)}] -> flight_options(Luna)
+ {here != Mars} [Go to {LocationData(Mars, Name)}] -> flight_options(Mars)
+ [Cancel] -> port_opts

= flight_options(to)
~ temp slow_cost = get_trip_fuel_cost(here, to, ShipEconomyMode)
~ temp norm_cost = get_trip_fuel_cost(here, to, ShipBalanceMode)
~ temp fast_cost = get_trip_fuel_cost(here, to, ShipTurboMode)
~ temp slow_time = get_trip_duration(here, to, ShipEconomyMode)
~ temp norm_time = get_trip_duration(here, to, ShipBalanceMode)
~ temp fast_time = get_trip_duration(here, to, ShipTurboMode)
You have {ShipFuel} fuel, and a total mass of {total_mass(ShipCargo)}t.
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
