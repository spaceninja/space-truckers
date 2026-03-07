LIST CargoStats = From, To, Mass, Title, Express, Fragile, Hazardous, Passengers
LIST AllCargo =
    000_Ship,

    // Earth cargo 001 through 099
    (001_Plums), (002_Fish), (003_Water), (004_Seafood),

    // Moon cargo 101 through 199
    (101_Helium), (102_Moonshine), (103_Rocks), (104_Helium),

    // Mars cargo 201 through 299
    (201_Plums), (202_Beef), (203_Bugs), (204_Platinum),

    // Ceres cargo 301 through 399
    (301_Ore), (302_Ice), (303_Samples), (304_Colonists),

    // Ganymede cargo 401 through 499
    (401_Protein), (402_Metals), (403_Samples), (404_Team),

    // Titan cargo 501 through 599
    (501_Methane), (502_Polymers), (503_Samples), (504_Survey)

/*

    Cargo Database

    cargo_db args: data, from, to, mass, title, express, fragile, hazardous, passengers

*/
=== function CargoData(id, data)
{ id:
- 001_Plums:
    ~ return cargo_db(data, Earth, Luna,     10, "juicy plums",        1, 0, 0, 0)
- 002_Fish:
    ~ return cargo_db(data, Earth, Luna,     20, "fresh fish",         1, 0, 0, 0)
- 003_Water:
    ~ return cargo_db(data, Earth, Mars,     40, "clean water",        0, 0, 0, 0)
- 004_Seafood:
    ~ return cargo_db(data, Earth, Mars,     20, "assorted seafood",   1, 0, 0, 0)

- 101_Helium:
    ~ return cargo_db(data, Luna,  Earth,    20, "helium-3",           0, 0, 0, 0)
- 102_Moonshine:
    ~ return cargo_db(data, Luna,  Earth,    40, "moonshine",          0, 0, 0, 0)
- 103_Rocks:
    ~ return cargo_db(data, Luna,  Mars,     10, "moon rocks",         0, 0, 0, 0)
- 104_Helium:
    ~ return cargo_db(data, Luna,  Mars,     20, "helium-3",           0, 0, 0, 0)

- 201_Plums:
    ~ return cargo_db(data, Mars,  Earth,    10, "red plums",          1, 0, 0, 0)
- 202_Beef:
    ~ return cargo_db(data, Mars,  Earth,    20, "vat-grown beef",     1, 0, 0, 0)
- 203_Bugs:
    ~ return cargo_db(data, Mars,  Luna,     10, "nutritious bugs",    1, 0, 0, 0)
- 204_Platinum:
    ~ return cargo_db(data, Mars,  Luna,     40, "platinum",           0, 0, 0, 0)

- 301_Ore:
    ~ return cargo_db(data, Ceres, Mars,     40, "refined ore",        0, 0, 0, 0)
- 302_Ice:
    ~ return cargo_db(data, Ceres, Earth,    20, "ice cores",          0, 0, 0, 0)
- 303_Samples:
    ~ return cargo_db(data, Ceres, Luna,     10, "belt samples",       0, 1, 0, 0)
- 304_Colonists:
    ~ return cargo_db(data, Ceres, Mars,     10, "colonists",          0, 0, 0, 1) // TODO: transit events

- 401_Protein:
    ~ return cargo_db(data, Ganymede, Ceres, 20, "synthetic protein",  0, 0, 0, 0)
- 402_Metals:
    ~ return cargo_db(data, Ganymede, Mars,  40, "industrial metals",  0, 0, 0, 0)
- 403_Samples:
    ~ return cargo_db(data, Ganymede, Earth, 10, "Europa samples",     0, 1, 0, 0)
- 404_Team:
    ~ return cargo_db(data, Ganymede, Ceres, 10, "research team",      0, 0, 0, 1) // TODO: transit events

- 501_Methane:
    ~ return cargo_db(data, Titan, Ganymede, 40, "liquid methane",     0, 0, 1, 0)
- 502_Polymers:
    ~ return cargo_db(data, Titan, Ceres,   20, "exotic polymers",    0, 0, 0, 0)
- 503_Samples:
    ~ return cargo_db(data, Titan, Mars,    10, "atmosphere samples", 0, 1, 0, 0)
- 504_Survey:
    ~ return cargo_db(data, Titan, Ganymede, 10, "survey team",        0, 0, 0, 1) // TODO: transit events

- else:
    [ Error: no data associated with {id}. ]
}

/*

    Cargo Database Row
    Returns the requested stat for a single cargo entry.

*/
=== function cargo_db(data, fromData, toData, massData, titleData, isExpress, isFragile, isHazardous, isPassengers)
{ data:
- From:       ~ return fromData
- To:         ~ return toData
- Mass:       ~ return massData
- Title:      ~ return titleData
- Express:    ~ return isExpress
- Fragile:    ~ return isFragile
- Hazardous:  ~ return isHazardous
- Passengers: ~ return isPassengers
}

/*

    Computed Cargo Pay

    base_pay = FLOOR(mass × distance × PayRate)
    Each flag (Express, Fragile, Hazardous, Passengers) adds +50% of base_pay.

*/
=== function get_cargo_pay(cargo, distance)
~ temp mass = CargoData(cargo, Mass)
~ temp base_pay = FLOOR(mass * distance * PayRate)
~ temp total = base_pay
{ CargoData(cargo, Express):
    ~ total = total + base_pay / 2
}
{ CargoData(cargo, Fragile):
    ~ total = total + base_pay / 2
}
{ CargoData(cargo, Hazardous):
    ~ total = total + base_pay / 2
}
{ CargoData(cargo, Passengers):
    ~ total = total + base_pay / 2
}
~ return total

/*

    Cargo Helper Functions (used by port.ink departure checks)

*/

/*

    Returns true if any cargo in the hold is Express.

*/
=== function cargo_has_express(items)
~ temp item = pop(items)
{ item:
    { CargoData(item, Express):
        ~ return true
    }
    ~ return cargo_has_express(items)
}
~ return false

/*

    Returns the single Express destination if all Express cargo shares one destination,
    or Transit if there is no Express cargo, or if Express cargo exists for multiple destinations.

    Transit is used as a sentinel because no cargo is ever bound for Transit,
    and it keeps the return type consistent as an AllLocations list value throughout
    (returning 0 would cause a type error when comparing against real destinations).

*/
=== function cargo_express_destination(items)
~ return _cargo_express_destination_r(items, Transit) // Transit = "not yet found"

/*

    Internal recursive helper for cargo_express_destination.

*/
=== function _cargo_express_destination_r(items, found)
~ temp item = pop(items)
{ item:
    { CargoData(item, Express):
        { found == Transit: // no Express destination recorded yet
            ~ return _cargo_express_destination_r(items, CargoData(item, To))
        - else:
            { found != CargoData(item, To):
                ~ return Transit // conflict: Express cargo bound for multiple destinations
            }
        }
    }
    ~ return _cargo_express_destination_r(items, found)
}
~ return found

/*

    Returns true if the hold contains both Hazardous and non-Hazardous cargo.

*/
=== function cargo_is_mixed_hazardous(items)
~ return _cargo_is_mixed_hazardous_r(items, false, false)

/*

    Internal recursive helper for cargo_is_mixed_hazardous.

*/
=== function _cargo_is_mixed_hazardous_r(items, has_hazardous, has_clean)
~ temp item = pop(items)
{ item:
    { CargoData(item, Hazardous):
        ~ return _cargo_is_mixed_hazardous_r(items, true, has_clean)
    - else:
        ~ return _cargo_is_mixed_hazardous_r(items, has_hazardous, true)
    }
}
~ return has_hazardous and has_clean

/*

    Returns true if any cargo in the hold blocks Turbo mode (Fragile or Passengers).

*/
=== function cargo_blocks_turbo(items)
~ temp item = pop(items)
{ item:
    { CargoData(item, Fragile) or CargoData(item, Passengers):
        ~ return true
    }
    ~ return cargo_blocks_turbo(items)
}
~ return false

/*

    Gets a randomized selection of cargo from the specified port.
    Express cargo is filtered out if the destination is unreachable in Turbo
    at the player's current engine tier.

*/
=== function get_available_cargo(port, count)
~ temp _cargo = AllCargo
~ return validated_list_random_subset_of_size(_cargo, -> cargo_is_available, port, count)

/*

    Check if a piece of cargo is available at the given port.
    Cargo must originate from this port. Express cargo is only shown
    if the player can afford Turbo to the destination.

*/
=== function cargo_is_available(cargo, port)
~ temp from = CargoData(cargo, From)
{ from != port:
    ~ return false
}
{ CargoData(cargo, Express):
    ~ temp to = CargoData(cargo, To)
    ~ temp turbo_fuel = EngineData(ShipEngineTier, TurboFuel)
    ~ temp turbo_cost = get_trip_fuel_cost(port, to, turbo_fuel)
    ~ return turbo_cost <= ShipFuelCapacity
}
~ return true

/*

    Returns the total mass of a list of items.

*/
=== function total_mass(items)
~ temp item = pop(items)
{ item:
    ~ temp mass = CargoData(item, Mass)
    ~ items -= item
    ~ return mass + total_mass(items)
}
~ return 0
