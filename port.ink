VAR PortCargo = ()

/*

    Arrive in Port

*/
=== arrive_in_port(port)
~ here = port
-> settle_trip_penalties ->
~ PortCargo = get_available_cargo(port, 5)

Welcome to {LocationData(port, Name)}!

- (port_opts)
+ [Load cargo]
     What do you want to ship?
    -> choose_cargo
+ [Manage cargo] -> manage_cargo
+ [Deliver cargo] -> deliver_cargo
+ [Buy fuel] -> fuel_station
+ { EngineCondition < 100 or ShipCondition < 100 } [Ship repairs] -> repair_services
+ [Ship upgrades] -> ship_upgrades
+ [Ship out!] -> ship_out
- -> port_opts

/*

    Choose Cargo

*/
= choose_cargo
~ temp _choices = PortCargo
current mass = {total_mass(ShipCargo)}t
- (top)
    ~ temp cargo = pop(_choices)
    { cargo:
        <- load(cargo)
        -> top
    }
-
+ [Done] -> port_opts

/*

    Load Cargo
    Presents a single load option for a cargo item at this port.

*/
= load(cargo)
~ temp toName = LocationData(CargoData(cargo, To), Name)
~ temp dist = get_distance(here, CargoData(cargo, To))
~ temp pay = get_cargo_pay(cargo, dist)
{ CargoData(cargo, Express):
    + [Load {CargoData(cargo, Title)} ({toName}, {CargoData(cargo, Mass)}t, € {pay}) — EXPRESS: Turbo only, direct route]
        ~ AllCargo -= cargo
        ~ PortCargo -= cargo
        ~ ShipCargo += cargo
        -> choose_cargo
- else:
    + [Load {CargoData(cargo, Title)} ({toName}, {CargoData(cargo, Mass)}t, € {pay})]
        ~ AllCargo -= cargo
        ~ PortCargo -= cargo
        ~ ShipCargo += cargo
        -> choose_cargo
}

/*

    Manage Cargo

*/
= manage_cargo
~ temp _choices = ShipCargo
current mass = {total_mass(ShipCargo)}t
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

/*

    Unload Cargo
    Presents a single unload option for a cargo item in the hold.

*/
= unload(cargo)
~ temp toName = LocationData(CargoData(cargo, To), Name)
~ temp dist = get_distance(CargoData(cargo, From), CargoData(cargo, To))
~ temp pay = get_cargo_pay(cargo, dist)
+ [Unload {CargoData(cargo, Title)} ({toName}, {CargoData(cargo, Mass)}t, € {pay})]
    ~ AllCargo += cargo
    ~ PortCargo += cargo
    ~ ShipCargo -= cargo
    -> manage_cargo

/*

    Settle Trip Penalties
    Called on arrival. Calculates missed nav check fuel penalties,
    applies accumulated fuel penalties, and handles the towing scenario.
    Paperwork penalties are applied separately during delivery.

*/
= settle_trip_penalties
// Nav check penalty: 10% of trip fuel per missed check
// Checks appear every 3 days (TripDay mod 3 == 0, TripDay > 0)
~ temp expected_checks = (TripDuration - 1) / 3
~ temp missed_checks = expected_checks - NavChecksCompleted
{ missed_checks > 0:
    ~ TripFuelPenalty = TripFuelPenalty + missed_checks * (TripFuelCost / 10)  // +10% trip fuel per missed check
}
// Apply accumulated fuel penalty
{ TripFuelPenalty > 0:
    ~ ShipFuel = ShipFuel - TripFuelPenalty
    { ShipFuel > 0:
        Course corrections and compensations burned {TripFuelPenalty} extra fuel this trip.
    - else:
        ~ ShipFuel = 0
        You ran out of fuel before reaching port. After drifting for days, a salvage tug picks up your distress beacon and tows you in. The tow fee is steep.
        ~ temp tow_fee = TripFuelCost * 2  // tow fee = 200% of trip fuel cost
        ~ PlayerBankBalance = PlayerBankBalance - tow_fee
        Tow fee: {tow_fee} €. Your balance is now {PlayerBankBalance} €.
    }
}
->->

/*

    Deliver Cargo
    Delivers all cargo destined for the current port.
    Incomplete paperwork reduces pay by 10% per missing chunk (capped at 50%).
    Cargo damage from transit events reduces pay by CargoDamagePct.
    Total combined penalty is capped at 75%.

*/
= deliver_cargo
~ temp _items = ShipCargo
~ temp delivery_count = 0
~ temp paperwork_penalty_pct = get_paperwork_penalty_pct(PaperworkDone, PaperworkTotal)
~ temp total_penalty_pct = MIN(paperwork_penalty_pct + CargoDamagePct, 75)
- (top)
~ temp cargo = pop(_items)
{ cargo:
    ~ temp to = CargoData(cargo, To)
    { to == here:
        ~ delivery_count++
        ~ ShipCargo -= cargo
        ~ temp dist = get_distance(CargoData(cargo, From), here)
        ~ temp pay = get_cargo_pay(cargo, dist)
        ~ temp penalty = pay * total_penalty_pct / 100
        ~ pay = pay - penalty
        ~ PlayerBankBalance += pay
        ~ temp fromName = LocationData(CargoData(cargo, From), Name)
        { penalty > 0:
            Delivered {CargoData(cargo, Title)} from {fromName} for {pay} € ({penalty} € in penalties).
        - else:
            Delivered {CargoData(cargo, Title)} from {fromName} for {pay} €.
        }
    }
    -> top
}
{ delivery_count > 0:
    { paperwork_penalty_pct > 0:
        Incomplete paperwork cost you {paperwork_penalty_pct}% of your delivery pay.
    }
    { CargoDamagePct > 0:
        Damaged cargo cost you an additional {CargoDamagePct}% of your delivery pay.
    }
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
~ temp price = get_fuel_price(here)
~ temp full_cost = get_fuel_purchase_cost(fuel_needed)
~ temp half_cost = get_fuel_purchase_cost(half_tank)
~ temp quarter_cost = get_fuel_purchase_cost(quarter_tank)
~ temp min_fuel = PlayerBankBalance / price
The current unit cost of fuel is {price} €. Your fuel gauge reads {ShipFuel}/{ShipFuelCapacity}. Your bank account balance is {PlayerBankBalance} €.
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

/*

    Buy Fuel
    Handles a single fuel purchase transaction.

*/
= buy_fuel(amount_requested)
~ temp fuel_needed = ShipFuelCapacity - ShipFuel
~ temp amount = MIN(fuel_needed, FLOOR(amount_requested))
~ temp cost = get_fuel_purchase_cost(amount)
{
- PlayerBankBalance < cost:
    "Sorry, your credit chip was declined."
- PlayerBankBalance >= cost:
    ~ ShipFuel = MIN(ShipFuel + amount, ShipFuelCapacity)
    ~ PlayerBankBalance -= MAX(cost, 0)
    "Thank you, come again!"
}
- -> fuel_station

/*

    Ship Repairs
    Pay to restore engine and ship condition at port.
    Engine repair: (100 - condition) × 2 €
    Cleaning service: (100 - condition) × 1 €

*/
= repair_services
~ temp engine_damage = 100 - EngineCondition
~ temp ship_damage = 100 - ShipCondition
~ temp engine_cost = engine_damage * 2
~ temp ship_cost = ship_damage * 1
Engine condition: {EngineCondition}% / Ship condition: {ShipCondition}%. Your balance: {PlayerBankBalance} €.
+ { EngineCondition < 100 and PlayerBankBalance >= engine_cost }
    [Engine repair — restore to 100% ({engine_cost} €)]
    ~ PlayerBankBalance -= engine_cost
    ~ EngineCondition = 100
    The mechanics go over your engine thoroughly. It's running like new.
    -> repair_services
+ { EngineCondition < 100 and PlayerBankBalance < engine_cost }
    [Engine repair — restore to 100% ({engine_cost} €) — can't afford #UNCLICKABLE]
    -> repair_services
+ { ShipCondition < 100 and PlayerBankBalance >= ship_cost }
    [Cleaning service — restore to 100% ({ship_cost} €)]
    ~ PlayerBankBalance -= ship_cost
    ~ ShipCondition = 100
    A cleaning crew sweeps through the ship. Everything is spotless.
    -> repair_services
+ { ShipCondition < 100 and PlayerBankBalance < ship_cost }
    [Cleaning service — restore to 100% ({ship_cost} €) — can't afford #UNCLICKABLE]
    -> repair_services
+ [Done] -> port_opts

/*

    Ship Out

*/
= ship_out
// Check 1: Hazardous mix
{ cargo_is_mixed_hazardous(ShipCargo):
    You can't depart with hazardous and non-hazardous cargo in the same hold. Remove the hazardous cargo or clear the hold first.
    -> port_opts
}
// Check 2: Express cargo for multiple destinations
~ temp express_dest = cargo_express_destination(ShipCargo)
{ cargo_has_express(ShipCargo) and express_dest == None:
    You have Express cargo bound for multiple destinations. Express contracts require a direct run — unload one before departing.
    -> port_opts
}
// Check 3: Express destination lock — only show the Express destination
{ express_dest != None:
    Your Express manifest locks your destination to {LocationData(express_dest, Name)}.
    -> flight_options(express_dest)
}
// Normal destination selection
+ {here != Earth}    [Go to {LocationData(Earth, Name)}]    -> flight_options(Earth)
+ {here != Luna}     [Go to {LocationData(Luna, Name)}]     -> flight_options(Luna)
+ {here != Mars}     [Go to {LocationData(Mars, Name)}]     -> flight_options(Mars)
+ {here != Ceres}    [Go to {LocationData(Ceres, Name)}]    -> flight_options(Ceres)
+ {here != Ganymede} [Go to {LocationData(Ganymede, Name)}] -> flight_options(Ganymede)
+ {here != Titan}    [Go to {LocationData(Titan, Name)}]    -> flight_options(Titan)
+ [Cancel] -> port_opts

// TODO: on engine upgrade, run: ~ ShipFuelCapacity = EngineData(ShipManufacturer, ShipEngineTier, FuelCap)

/*

    Flight Options
    Shows available flight modes for the chosen destination, filtered by cargo constraints and fuel.

*/
= flight_options(to)
~ temp eco_fuel    = EngineData(ShipManufacturer, ShipEngineTier, EcoFuel)
~ temp bal_fuel    = EngineData(ShipManufacturer, ShipEngineTier, BalFuel)
~ temp turbo_fuel  = EngineData(ShipManufacturer, ShipEngineTier, TurboFuel)
~ temp eco_speed   = EngineData(ShipManufacturer, ShipEngineTier, EcoSpeed)
~ temp bal_speed   = EngineData(ShipManufacturer, ShipEngineTier, BalSpeed)
~ temp turbo_speed = EngineData(ShipManufacturer, ShipEngineTier, TurboSpeed)
~ temp slow_cost   = get_trip_fuel_cost(here, to, eco_fuel)
~ temp norm_cost   = get_trip_fuel_cost(here, to, bal_fuel)
~ temp fast_cost   = get_trip_fuel_cost(here, to, turbo_fuel)
// Apply engine degradation fuel penalty to displayed costs
~ slow_cost = slow_cost + get_engine_fuel_penalty(slow_cost)
~ norm_cost = norm_cost + get_engine_fuel_penalty(norm_cost)
~ fast_cost = fast_cost + get_engine_fuel_penalty(fast_cost)
~ temp slow_time   = get_trip_duration(here, to, eco_speed)
~ temp norm_time   = get_trip_duration(here, to, bal_speed)
~ temp fast_time   = get_trip_duration(here, to, turbo_speed)
// Check 4: mode constraints from cargo flags
~ temp has_express    = cargo_has_express(ShipCargo)
~ temp blocks_turbo   = cargo_blocks_turbo(ShipCargo)
You have {ShipFuel} fuel, and a total mass of {total_mass(ShipCargo)}t.
{EngineCondition < 100:
    Engine condition: {EngineCondition}% — fuel costs increased.
}
+ {can_use_flight_mode(has_express, ShipFuel, slow_cost)}
    [Economy Mode ({slow_cost} fuel, {slow_time} days)]
    -> transit(to, slow_cost, slow_time, Eco)
+ {not can_use_flight_mode(has_express, ShipFuel, slow_cost)}
    [Economy Mode ({slow_cost} fuel, {slow_time} days) #UNCLICKABLE]
    { has_express: Express cargo requires Turbo mode. - else: You do not have enough fuel to use economy mode. }
    -> port_opts
+ {can_use_flight_mode(has_express, ShipFuel, norm_cost)}
    [Balance Mode ({norm_cost} fuel, {norm_time} days)]
    -> transit(to, norm_cost, norm_time, Bal)
+ {not can_use_flight_mode(has_express, ShipFuel, norm_cost)}
    [Balance Mode ({norm_cost} fuel, {norm_time} days) #UNCLICKABLE]
    { has_express: Express cargo requires Turbo mode. - else: You do not have enough fuel to use balance mode. }
    -> port_opts
+ {can_use_flight_mode(blocks_turbo, ShipFuel, fast_cost)}
    [Turbo Mode ({fast_cost} fuel, {fast_time} days)]
    -> transit(to, fast_cost, fast_time, Turbo)
+ {not can_use_flight_mode(blocks_turbo, ShipFuel, fast_cost)}
    [Turbo Mode ({fast_cost} fuel, {fast_time} days) #UNCLICKABLE]
    { blocks_turbo: Fragile or passenger cargo cannot use Turbo mode. - else: You do not have enough fuel to use turbo mode. }
    -> port_opts
+ [Cancel] -> port_opts

/*

    Can Use Flight Mode
    Returns true if the mode is available: cargo doesn't block it and there is enough fuel.
    For Eco/Balance, pass has_express as is_blocked.
    For Turbo, pass blocks_turbo as is_blocked.

*/
=== function can_use_flight_mode(is_blocked, fuel, cost)
~ return not is_blocked and fuel >= cost

/*

    Get Fuel Purchase Cost
    Returns the euro cost of purchasing a given amount of fuel at the current port.
    Formula: FLOOR(amount × fuel_price)

*/
=== function get_fuel_purchase_cost(amount)
~ return FLOOR(amount * get_fuel_price(here))
