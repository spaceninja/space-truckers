LIST AllLocations = Transit, Earth, Mars, Luna, Ceres, Ganymede, Titan
LIST LocationStats = Earth, Luna, Mars, Ceres, Ganymede, Titan, Name

VAR here = Earth

/*

    Location Database

    Distances (internal units — never shown to player):
    Earth↔Luna=5, Earth↔Mars=14, Earth↔Ceres=22, Earth↔Ganymede=40, Earth↔Titan=52
    Luna↔Mars=8,  Luna↔Ceres=18, Luna↔Ganymede=38, Luna↔Titan=50
    Mars↔Ceres=10, Mars↔Ganymede=26, Mars↔Titan=36
    Ceres↔Ganymede=18, Ceres↔Titan=28
    Ganymede↔Titan=16

*/
=== function LocationData(id, data)
{ id:
- Earth:
    ~ return location_db(data,  0,  5, 14, 22, 40, 52, "Earth")
- Luna:
    ~ return location_db(data,  5,  0,  8, 18, 38, 50, "Moon Base")
- Mars:
    ~ return location_db(data, 14,  8,  0, 10, 26, 36, "Mars")
- Ceres:
    ~ return location_db(data, 22, 18, 10,  0, 18, 28, "Ceres Station")
- Ganymede:
    ~ return location_db(data, 40, 38, 26, 18,  0, 16, "Ganymede Outpost")
- Titan:
    ~ return location_db(data, 52, 50, 36, 28, 16,  0, "Titan Base")
- else:
    [ Error: no location data associated with {id}. ]
}

=== function location_db(id, toEarthData, toLunaData, toMarsData, toCeresData, toGanymedeData, toTitanData, nameData)
{ id:
- Earth:    ~ return toEarthData
- Luna:     ~ return toLunaData
- Mars:     ~ return toMarsData
- Ceres:    ~ return toCeresData
- Ganymede: ~ return toGanymedeData
- Titan:    ~ return toTitanData
- Name:     ~ return nameData
}

/*

    Get Distance

*/
=== function get_distance(from, to)
~ return LocationData(from, to)

/*

    Get Fuel Cost

    fuel_factor is passed in ×10 (from EngineData), so divide by 10.
    Formula: FLOOR(distance × mass × fuel_factor / 10)

*/
=== function get_trip_fuel_cost(from, to, fuel_factor)
~ temp mass = total_mass(ShipCargo) + 5
~ temp distance = get_distance(from, to)
~ temp cost = FLOOR(distance * mass * fuel_factor / 10)
~ return cost

/*

    Get Trip Duration

    speed is passed in ×10 (from EngineData), so multiply distance by 10 before dividing.
    Formula: MAX(FLOOR(distance × 10 / speed), 1)

*/
=== function get_trip_duration(from, to, speed)
~ temp distance = get_distance(from, to)
~ temp time = MAX(FLOOR(distance * 10 / speed), 1)
~ return time

/*

    Get Fuel Price

    Returns fuel price stored ×10 (so €1.2 = 12, €1.0 = 10, €0.8 = 8).
    Divide by 10 in port.ink when computing euro costs.

    Inner system (Earth, Luna, Mars): €1.2
    Belt (Ceres):                     €1.0
    Outer system (Ganymede, Titan):   €0.8

*/
=== function get_fuel_price(location)
{ location:
- Earth:
- Luna:
- Mars:
    ~ return 12
- Ceres:
    ~ return 10
- Ganymede:
- Titan:
    ~ return 8
}
