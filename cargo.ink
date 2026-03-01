LIST AllCargo = 
    // Earth cargo 001 through 099
    (001_Plums), (002_Fish), (003_Water),

    // Moon cargo 101 through 199
    (101_Helium), (102_Moonshine), (103_Rocks),

    // Mars cargo 201 through 299
    (201_Plums), (202_Beef), (203_Bugs)

/*

    Cargo Database

*/
=== function CargoData(id, stat)
{ id:
- 001_Plums:
    ~ return cargo_db(stat, Earth, Mars, 20, 200, "Juicy plums")
- 002_Fish:
    ~ return cargo_db(stat, Earth, Mars, 30, 300, "Fresh fish")
- 003_Water:
    ~ return cargo_db(stat, Earth, Mars, 40, 1000, "Clean water")
- 101_Helium:
    ~ return cargo_db(stat, Moon, Earth, 20, 300, "Helium-3")
- 102_Moonshine:
    ~ return cargo_db(stat, Moon, Earth, 30, 300, "Moonshine")
- 103_Rocks:
    ~ return cargo_db(stat, Moon, Earth, 20, 100, "Moon rocks")
- 201_Plums:
    ~ return cargo_db(stat, Mars, Earth, 20, 200, "Martian plums")
- 202_Beef:
    ~ return cargo_db(stat, Mars, Earth, 30, 300, "Martian beef")
- 203_Bugs:
    ~ return cargo_db(stat, Mars, Earth, 20, 100, "Martian bugs")
- else:
    [ Error: no data associated with {id}. ]
}

=== function cargo_db(id, fromData, toData, massData, payData, titleData)
{id:
- From:  ~ return fromData
- To:    ~ return toData
- Mass:  ~ return massData
- Pay:   ~ return payData
- Title: ~ return titleData
}

/*

    Gets a randomized selection of cargo from the specified port.

*/
=== function available_cargo(port, count)
~ temp _cargo = AllCargo
~ return validated_list_random_subset_of_size(_cargo, -> is_from, port, count)

/*

    Check if a piece of cargo is from the specified port.

*/
=== function is_from(cargo, port)
~ temp from = CargoData(cargo, From)
~ return from == port

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
