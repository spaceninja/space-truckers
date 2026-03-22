# TITLE: Space Truckers
# AUTHOR: Scott

INCLUDE port.ink
INCLUDE ship.ink
INCLUDE cargo.ink
INCLUDE locations.ink
INCLUDE functions.ink


VAR PlayerBankBalance = 200
VAR PayRate = 3

LIST Manufacturers = Kepler, Olympus, Huygens

VAR ShipManufacturer = Kepler
VAR ShipEngineTier = 1
VAR ShipFuelCapacity = 300
VAR ShipFuel = 225
VAR ShipCargo = ()

LIST EngineStats = FuelCap, EcoFuel, EcoSpeed, BalFuel, BalSpeed, TurboFuel, TurboSpeed

-> arrive_in_port(here)

/*

    Engine Database
    Returns the requested stat for a given manufacturer and engine tier.

    Manufacturers:
      Kepler  (Earth)  — balanced, best Balance mode
      Olympus (Mars)   — turbo-optimized, best Turbo mode
      Huygens (Titan)  — eco-optimized, best Eco mode

    Tier 1 is a universal starter engine shared by all manufacturers.

*/
=== function EngineData(mfg, tier, stat)
{ tier == 1:
    //                       Cap   EcoFF EcoSpd BalFF BalSpd TurboFF TurboSpd
    ~ return engine_db(stat, 300,  1.1,  1.0,   1.8,  1.5,   4.0,    2.5)
}
{ mfg:
- Kepler:  ~ return KeplerData(tier, stat)
- Olympus: ~ return OlympusData(tier, stat)
- Huygens: ~ return HuygensData(tier, stat)
}

/*

    Kepler Drive Systems (Earth) — Balanced
    Best Balance mode at every tier. Solid all-rounder.

*/
=== function KeplerData(tier, stat)
{ tier:
//                           Cap   EcoFF EcoSpd BalFF BalSpd TurboFF TurboSpd
- 2: ~ return engine_db(stat, 500, 0.8,  1.1,   1.5,  2.0,   3.0,    3.0)
- 3: ~ return engine_db(stat, 650, 0.5,  1.5,   0.9,  2.5,   1.8,    4.0)
- 4: ~ return engine_db(stat, 800, 0.3,  2.0,   0.6,  3.5,   1.2,    5.0)
}

/*

    Olympus Propulsion (Mars) — Turbo-optimized
    Best Turbo mode. Eco mode is weaker but still improves each tier.

*/
=== function OlympusData(tier, stat)
{ tier:
//                           Cap   EcoFF EcoSpd BalFF BalSpd TurboFF TurboSpd
- 2: ~ return engine_db(stat, 500, 1.0,  1.1,   1.6,  1.8,   2.4,    3.5)
- 3: ~ return engine_db(stat, 650, 0.7,  1.3,   1.0,  2.3,   1.3,    4.5)
- 4: ~ return engine_db(stat, 800, 0.4,  1.8,   0.7,  3.2,   0.8,    5.5)
}

/*

    Huygens Deepspace (Titan) — Eco-optimized
    Best Eco mode. Turbo mode is weaker but still improves each tier.

*/
=== function HuygensData(tier, stat)
{ tier:
//                           Cap   EcoFF EcoSpd BalFF BalSpd TurboFF TurboSpd
- 2: ~ return engine_db(stat, 500, 0.6,  1.2,   1.6,  1.8,   3.5,    2.7)
- 3: ~ return engine_db(stat, 650, 0.4,  1.8,   1.0,  2.3,   2.2,    3.5)
- 4: ~ return engine_db(stat, 800, 0.2,  2.3,   0.7,  3.2,   1.5,    4.5)
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
// To upgrade: ~ ShipManufacturer = Olympus; ~ ShipEngineTier = 2; ~ ShipFuelCapacity = EngineData(ShipManufacturer, ShipEngineTier, FuelCap)
// Availability: Kepler at Earth/Luna, Olympus at Mars, Huygens at Ganymede/Titan, all at Ceres
