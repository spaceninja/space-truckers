LIST Ports = Earth, Mars

LIST Data = From, To, Mass, Pay, Title

LIST Cargo = 
    // Earth cargo 001 through 099
    (001_Plums), (002_Fish), (003_Water),
    // Mars cargo 101 through 199
    (101_Plums), (102_Beef), (103_Bugs)

VAR here = Earth

TODO track weight
TODO track bank balance
TODO track inventory
TODO allow adding multiple cargos
TODO unload on arrival
TODO prevent leaving if overloaded
TODO allow removing loaded cargo

-> choose_shipment(here)

=== choose_shipment(port)
~ temp choices = available_cargo(port, 3)

Welcome to {port}! What do you want to ship?

- (top)
    ~ temp cargo = pop(choices)
    { cargo:
        <- cargo_choice(cargo)
        -> top
    }
- (bottom)
+ [Nevermind] -> DONE

=== cargo_choice(cargo)
+ [{CargoData(cargo, Title)} ({CargoData(cargo, Mass)}t, {CargoData(cargo, Pay)} €)]
    ~ Cargo -= cargo
    -> ship_it(cargo)

=== ship_it(cargo)
Your cargo is {CargoData(cargo, Title)} from {CargoData(cargo, From)} bound for {CargoData(cargo, To)}, with a mass of {CargoData(cargo, Mass)} metric tons, which pays {CargoData(cargo, Pay)} euros.
{ here:
    - Earth:
        Flying to Mars…
        ~ here = Mars
        -> choose_shipment(Mars)
    - Mars:
        Flying to Earth…
        ~ here = Earth
        -> choose_shipment(Earth)
}

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
- 101_Plums:
    ~ return cargo_db(stat, Mars, Earth, 20, 200, "Martian plums")
- 102_Beef:
    ~ return cargo_db(stat, Mars, Earth, 30, 300, "Martian beef")
- 103_Bugs:
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

    Cargo Functions

*/
=== function available_cargo(port, count)
~ temp CargoCopy = Cargo
~ return validated_list_random_subset_of_size(CargoCopy, -> is_from, port, count)

=== function is_from(cargo, port)
~ temp from = CargoData(cargo, From)
~ return from == port

/*

    Standard Functions

*/
=== function pop(ref _list) 
~ temp el = LIST_MIN(_list) 
~ _list -= el
~ return el 

=== function pop_random(ref list) 
~ temp el = LIST_RANDOM(list) 
~ list -= el 
~ return el

=== function list_random_subset_of_size(sourceList, n) 
{ n > 0:
    ~ temp el = pop_random(sourceList) 
    { el: 
        ~ return el + list_random_subset_of_size(sourceList, n-1)
    }
}
~ return () 

=== function validated_list_random_subset_of_size(sourceList, -> validator, arg, n) 
{ n > 0:
    ~ temp el = pop_random(sourceList) 
    { el: 
        {
        - validator(el, arg):
            ~ return el + validated_list_random_subset_of_size(sourceList, validator, arg, n-1)
        - else:
            ~ return validated_list_random_subset_of_size(sourceList, validator, arg, n)
        }
    }
}
~ return () 
