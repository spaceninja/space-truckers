INCLUDE port.ink
INCLUDE ship.ink
INCLUDE cargo.ink
INCLUDE locations.ink
INCLUDE functions.ink


VAR PlayerBankBalance = 200
VAR PayRate = 3

VAR ShipEngineTier = 1
VAR ShipFuelCapacity = 300
VAR ShipFuel = 225
VAR ShipCargo = ()

LIST EngineStats = FuelCap, EcoFuel, EcoSpeed, BalFuel, BalSpeed, TurboFuel, TurboSpeed

-> arrive_in_port(here)
//-> transit(Mars, 300, 7)

/*

    Engine Database
    Returns the requested stat for a given engine tier.

*/
=== function EngineData(tier, stat)
{ tier:
- 1:
    ~ return engine_db(stat, 300, 1.1, 1.0, 2.0, 1.5, 4.0, 2.5)
- 2:
    ~ return engine_db(stat, 500, 0.8, 1.0, 1.5, 2.0, 3.0, 3.0)
- 3:
    ~ return engine_db(stat, 650, 0.5, 1.5, 0.9, 2.5, 1.8, 4.0)
- 4:
    ~ return engine_db(stat, 800, 0.3, 2.0, 0.6, 3.5, 1.2, 5.0)
}

/*

    Engine Database Row
    Returns the requested stat for a single engine tier entry.

*/
=== function engine_db(stat, fuelCap, ecoFuel, ecoSpeed, balFuel, balSpeed, turboFuel, turboSpeed)
{ stat:
- FuelCap:    ~ return fuelCap
- EcoFuel:    ~ return ecoFuel
- EcoSpeed:   ~ return ecoSpeed
- BalFuel:    ~ return balFuel
- BalSpeed:   ~ return balSpeed
- TurboFuel:  ~ return turboFuel
- TurboSpeed: ~ return turboSpeed
}

// TODO: implement engine upgrade purchase UI
// To upgrade: ~ ShipEngineTier++; ~ ShipFuelCapacity = EngineData(ShipEngineTier, FuelCap)
