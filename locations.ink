LIST AllLocations = Transit, Earth, Mars, Luna
LIST LocationStats = Distance, Name

VAR here = Earth

/*

    Location Database

*/
=== function LocationData(id, data)
{ id:
- Earth:
    ~ return location_db(data, 0, 10, 20, "Earth")
- Luna:
    ~ return location_db(data, 10, 0, 10, "Moon Base")
- Mars:
    ~ return location_db(data, 20, 10, 0, "Mars")
- else:
    [ Error: no data associated with {id}. ]
}

=== function location_db(id, toEarthData, toLunaData, toMarsData, nameData)
{id:
- Earth: ~ return toEarthData
- Luna:  ~ return toLunaData
- Mars:  ~ return toMarsData
- Name:  ~ return nameData
}

/*

    Get Distance

*/
=== function get_distance(from, to)
~ return LocationData(from, to)

/*

    Get Fuel Cost
    
    TODO: Three grades of engines?
    
      A B C
          1
        2 2
      3 3 3 // Grade C economy = B balance = A turbo
      4 4
      5
*/
=== function get_trip_fuel_cost(from, to, efficiency)
~ temp mass = total_mass(ShipCargo) + 5 // add 5 for the ship itself
~ temp distance = get_distance(from, to)
~ temp cost = FLOOR(distance * mass * efficiency)
DEBUG {distance}km * {mass}t * {efficiency}e = {cost} fuel
~ return cost

/*

    Get Trip Duration
    
    TODO: should mass factor in?
    Should never be shorter than 2 days
    Should probably never be longer than 14 days

*/
=== function get_trip_duration(from, to, efficiency)
~ temp distance = get_distance(from, to)
~ temp time = MAX(FLOOR(distance / efficiency), 1)
DEBUG {distance}km / {efficiency}e = {time} days
~ return time
