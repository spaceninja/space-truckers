# TITLE: Space Truckers
# AUTHOR: Scott

INCLUDE port.ink
INCLUDE ship.ink
INCLUDE events.ink
INCLUDE cargo.ink
INCLUDE locations.ink
INCLUDE functions.ink
INCLUDE modules.ink

VAR DEBUG = true

VAR PlayerBankBalance = 200
VAR PayRate = 3

LIST Manufacturers = Kepler, Olympus, Huygens
LIST FlightModes = Eco, Bal, Turbo

VAR ShipManufacturer = Kepler
VAR ShipEngineTier = 1
VAR ShipFuelCapacity = 300
VAR ShipFuel = 225
VAR ShipCargo = ()
VAR FlightMode = Bal

VAR Fatigue = 0           // 0–100 scale. Gravity-modified accumulation.
VAR Morale = 80           // 0–100 scale. Decays daily, boosted by recreation.
VAR ShipCondition = 100   // 0–100%. Degrades from skipped maintenance. Affects morale.
VAR EngineCondition = 100 // 0–100%. Degrades from skipped maintenance. Affects fuel cost.

// Maintenance backlog — 3-4 new tasks drawn daily via two-stage selection.
// Stage 1: 3 engine + 3 ship + 1 module (if installed) → Stage 2: draw 3-4.
// Skipped tasks age: fresh → stale → auto-resolve with condition penalty.
LIST EngineMaintTasks = EngTune, FuelLine, Injector, Coolant
LIST ShipMaintTasks = AirFilter, HullCheck, DrainLines, Scrub
LIST ModuleMaintTasks = RepDroneServo, RepDroneOptics, ClnDroneBrush, ClnDroneFilter, NavChipFlush, NavGyroCalib, CargoSensor, CargoSealCheck, EntWiring, EntDisplayClean, WellSanitize, WellCalib, PaxLifeSupp, PaxBerthClean
VAR Backlog = ()          // current maintenance tasks (accumulates daily)
VAR StaleBacklog = ()     // tasks that survived yesterday without completion
VAR CompletedToday = ()   // tasks completed this day, becomes tomorrow's cooldown
VAR MaintCooldown = ()    // yesterday's completed tasks, excluded from today's draw

VAR TripDay = 0           // Current day of trip (incremented in next_day)
VAR TripDuration = 0      // Total trip length in days
VAR FlipDone = false      // Has the ship flip been executed this trip?
VAR PaperworkDone = 0     // Chunks completed
VAR PaperworkTotal = 0    // Chunks required (calculated at departure)
VAR TripFuelCost = 0      // Base fuel cost of current trip (for % penalty calcs)
VAR TripFuelPenalty = 0   // Accumulated fuel penalty during transit
VAR NavCheckDueDay = 3    // Day next nav check is due
VAR NavPenaltyPct = 0     // Accumulated fuel penalty % for overdue nav checks
VAR CargoCheckDueDay = 2  // Day next cargo inspection is due
VAR CargoCheckPenaltyPct = 0 // Accumulated pay penalty % for overdue cargo inspections
VAR TaskCap = 7            // Max top-level tasks shown (excluding P5 Rest)
VAR TasksCompletedToday = 0 // Tasks completed this transit day

VAR EventChance = 0        // Escalating probability for random events (0–100)
VAR EventCooldownDay = -1  // TripDay of last event; prevents pile-ups same day
VAR CargoDamagePct = 0     // Accumulated cargo damage % (reduces delivery pay)

// Fresh ingredients — purchasable at port, unlock premium cooking options in transit.
// Each item corresponds to a port-specific ingredient and a named meal in do_cook().
LIST FreshIngredients = EarthStrawberries, EarthWagyu, LunaHerbs, LunaCheese, MarsPeppers, MarsHoney, CeresTruffles, CeresSake, GanymedeIceCream, GanymedeSalt, TitanMeats, TitanBerries
VAR PurchasedIngredients = ()  // subset of FreshIngredients currently in the galley

// Module system — ship modules that automate routine tasks.
LIST ShipModules = RepairDrones, CleaningDrones, AutoNav, CargoMgmt, Entertainment, WellnessSuite, PassengerModule
LIST ModuleStats = ModName, ModPrice, ModDesc
VAR InstalledModules = ()      // currently installed modules
VAR RefurbishedModules = ()    // subset of InstalledModules bought refurbished (80% max cap)
VAR RefurbishedEngine = false  // true if current engine was bought refurbished (80% max cap)

// Per-module condition (0 = not installed, 1-100 = condition)
VAR RepairDronesCondition = 0
VAR CleaningDronesCondition = 0
VAR AutoNavCondition = 0
VAR CargoMgmtCondition = 0
VAR EntertainmentCondition = 0
VAR WellnessSuiteCondition = 0
VAR PassengerModuleCondition = 0
VAR PassengerModuleTier = 0       // 0=not installed, 1=Basic Berths, 2=Standard Cabin, 3=Luxury Suite

// Passenger satisfaction — 0-100, starts at 50 (neutral) each trip.
// ≥70: pay bonus at delivery; ≤30: pay penalty. Status shown daily.
VAR PassengerSatisfaction = 50
VAR DailyPassengerTask = ()       // LIST value from PassengerTasks, () = no task today
VAR PassengerTaskCompleted = false


LIST EngineStats = FuelCap, EcoFuel, EcoSpeed, BalFuel, BalSpeed, TurboFuel, TurboSpeed, EngPrice

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
    //                       Cap   EcoFF EcoSpd BalFF BalSpd TurboFF TurboSpd  Price
    ~ return engine_db(stat, 300,  1.1,  1.0,   1.8,  1.5,   4.0,    2.5,     0)
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
//                           Cap   EcoFF EcoSpd BalFF BalSpd TurboFF TurboSpd  Price
- 2: ~ return engine_db(stat, 500, 0.8,  1.1,   1.5,  2.0,   3.0,    3.0,     1500)
- 3: ~ return engine_db(stat, 650, 0.5,  1.5,   0.9,  2.5,   1.8,    4.0,     2500)
- 4: ~ return engine_db(stat, 800, 0.3,  2.0,   0.6,  3.5,   1.2,    5.0,     4000)
}

/*

    Olympus Propulsion (Mars) — Turbo-optimized
    Best Turbo mode. Eco mode is weaker but still improves each tier.

*/
=== function OlympusData(tier, stat)
{ tier:
//                           Cap   EcoFF EcoSpd BalFF BalSpd TurboFF TurboSpd  Price
- 2: ~ return engine_db(stat, 500, 1.0,  1.1,   1.6,  1.8,   2.4,    3.5,     1500)
- 3: ~ return engine_db(stat, 650, 0.7,  1.3,   1.0,  2.3,   1.3,    4.5,     2500)
- 4: ~ return engine_db(stat, 800, 0.4,  1.8,   0.7,  3.2,   0.8,    5.5,     4000)
}

/*

    Huygens Deepspace (Titan) — Eco-optimized
    Best Eco mode. Turbo mode is weaker but still improves each tier.

*/
=== function HuygensData(tier, stat)
{ tier:
//                           Cap   EcoFF EcoSpd BalFF BalSpd TurboFF TurboSpd  Price
- 2: ~ return engine_db(stat, 500, 0.6,  1.2,   1.6,  1.8,   3.5,    2.7,     1500)
- 3: ~ return engine_db(stat, 650, 0.4,  1.8,   1.0,  2.3,   2.2,    3.5,     2500)
- 4: ~ return engine_db(stat, 800, 0.2,  2.3,   0.7,  3.2,   1.5,    4.5,     4000)
}

/*

    Engine Database Row
    Returns the requested stat for a single engine tier entry.

*/
=== function engine_db(stat, fuelCap, ecoFuel, ecoSpeed, balFuel, balSpeed, turboFuel, turboSpeed, price)
{ stat:
- FuelCap:    ~ return fuelCap
- EcoFuel:    ~ return ecoFuel
- EcoSpeed:   ~ return ecoSpeed
- BalFuel:    ~ return balFuel
- BalSpeed:   ~ return balSpeed
- TurboFuel:  ~ return turboFuel
- TurboSpeed: ~ return turboSpeed
- EngPrice:   ~ return price
}


