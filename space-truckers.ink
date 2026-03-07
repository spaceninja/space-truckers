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

=== function EngineData(tier, stat)
{ tier:
- 1:
    ~ return engine_db(stat, 300, 11, 10, 20, 15, 40, 25)
- 2:
    ~ return engine_db(stat, 500,  8, 10, 15, 20, 30, 30)
- 3:
    ~ return engine_db(stat, 650,  5, 15,  9, 25, 18, 40)
- 4:
    ~ return engine_db(stat, 800,  3, 20,  6, 35, 12, 50)
}

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
