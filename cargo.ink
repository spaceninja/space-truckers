LIST AllCargo = 
    000_Ship,

    // Earth cargo 001 through 099
    (001_Plums), (002_Fish), (003_Water), (004_Seafood),

    // Moon cargo 101 through 199
    (101_Helium), (102_Moonshine), (103_Rocks), (104_Helium),

    // Mars cargo 201 through 299
    (201_Plums), (202_Beef), (203_Bugs), (204_Platinum)

/*

    Cargo Database

*/
=== function CargoData(id, data)
{ id:
- 001_Plums:
    ~ return cargo_db(data, Earth, Luna, 10, 200, "juicy plums")
- 002_Fish:
    ~ return cargo_db(data, Earth, Luna, 20, 400, "fresh fish")
- 003_Water:
    ~ return cargo_db(data, Earth, Mars, 40, 800, "clean water")
- 004_Seafood:
    ~ return cargo_db(data, Earth, Mars, 20, 400, "assorted seafood")

- 101_Helium:
    ~ return cargo_db(data, Luna, Earth, 20, 400, "helium-3")
- 102_Moonshine:
    ~ return cargo_db(data, Luna, Earth, 40, 800, "moonshine")
- 103_Rocks:
    ~ return cargo_db(data, Luna, Mars, 10, 200, "moon rocks")
- 104_Helium:
    ~ return cargo_db(data, Luna, Mars, 20, 400, "helium-3")

- 201_Plums:
    ~ return cargo_db(data, Mars, Earth, 10, 200, "red plums")
- 202_Beef:
    ~ return cargo_db(data, Mars, Earth, 20, 400, "vat-grown beef")
- 203_Bugs:
    ~ return cargo_db(data, Mars, Luna, 10, 200, "nutritious bugs")
- 204_Platinum:
    ~ return cargo_db(data, Mars, Luna, 40, 800, "platinum")

- else:
    [ Error: no data associated with {id}. ]
}

=== function cargo_db(data, fromData, toData, massData, payData, titleData)
{data:
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
