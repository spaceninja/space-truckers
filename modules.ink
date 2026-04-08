/*

    Module Data Lookup
    Returns the requested stat for a given module.
    Follows the same pattern as EngineData/CargoData.

*/
=== function ModuleData(module, stat)
{ module:
- RepairDrones:   ~ return module_row(stat, "Repair Drones", 800, "Auto-complete engine maintenance tasks")
- CleaningDrones: ~ return module_row(stat, "Cleaning Drones", 600, "Auto-complete ship maintenance tasks")
- AutoNav:        ~ return module_row(stat, "Auto-Nav Computer", 500, "Auto-complete navigation checks")
- CargoMgmt:      ~ return module_row(stat, "Cargo Management", 700, "Auto-complete cargo inspections and paperwork")
- PassengerModule: ~ return module_row(stat, "Passenger Module", 200, "Passenger berths and facilities")
}
~ return 0

/*

    Module Data Row
    Returns the requested stat for a single module entry.

*/
=== function module_row(stat, name, price, desc)
{ stat:
- ModName:  ~ return name
- ModPrice: ~ return price
- ModDesc:  ~ return desc
}
~ return 0

/*

    Get Module Condition
    Returns the condition of a module (0 = not installed, 1-100 = condition).

*/
=== function get_module_condition(module)
{ module:
- RepairDrones:   ~ return RepairDronesCondition
- CleaningDrones: ~ return CleaningDronesCondition
- AutoNav:        ~ return AutoNavCondition
- CargoMgmt:      ~ return CargoMgmtCondition
- PassengerModule: ~ return PassengerModuleCondition
}
~ return 0

/*

    Set Module Condition
    Sets the condition of a module.

*/
=== function set_module_condition(module, value)
{ module:
- RepairDrones:   ~ RepairDronesCondition = value
- CleaningDrones: ~ CleaningDronesCondition = value
- AutoNav:        ~ AutoNavCondition = value
- CargoMgmt:      ~ CargoMgmtCondition = value
- PassengerModule: ~ PassengerModuleCondition = value
}

/*

    Is Module Active
    Returns true if the module is installed and condition >= 50.

*/
=== function is_module_active(module)
~ return (InstalledModules ? module) and (get_module_condition(module) >= 50)

/*

    Get Drone Capacity
    Returns the number of tasks a drone module can auto-complete per day.
    75-100%: 2 tasks, 50-74%: 1 task, below 50%: offline.

*/
=== function get_drone_capacity(module)
~ temp cond = get_module_condition(module)
{ cond >= 75:
    ~ return 2
}
{ cond >= 50:
    ~ return 1
}
~ return 0

/*

    Get Module Max Condition
    Returns the maximum condition a module can be repaired to.
    Refurbished modules cap at 80%.

*/
=== function get_module_max_condition(module)
{ RefurbishedModules ? module:
    ~ return 80
}
~ return 100

/*

    Get Module Repair Cost
    Returns the cost to fully repair a module.
    Formula: (max_condition - current_condition) × module_price / 100

*/
=== function get_module_repair_cost(module)
~ temp max_cond = get_module_max_condition(module)
~ temp current = get_module_condition(module)
~ temp price = ModuleData(module, ModPrice)
~ temp damage = max_cond - current
~ return damage * price / 100

/*

    Module Name Helper
    Returns the display name of a module.

*/
=== function module_name(module)
~ return ModuleData(module, ModName)

/*

    Install Module
    Sets up a module as installed with the given starting condition.

*/
=== function install_module(module, condition)
~ InstalledModules += module
~ set_module_condition(module, condition)

/*

    Passenger Module Tier Helpers
    Price for fresh install at each tier (cumulative — used for upgrade delta math).
    Upgrade cost = PassengerTierPrice(next) - PassengerTierPrice(current).

*/
=== function PassengerTierPrice(tier)
{ tier:
- 1: ~ return 200
- 2: ~ return 400
- 3: ~ return 800
}
~ return 0

/*

    Passenger Tier Name
    Display name for each tier of the passenger module.

*/
=== function PassengerTierName(tier)
{ tier:
- 1: ~ return "Basic Berths"
- 2: ~ return "Standard Cabin"
- 3: ~ return "Luxury Suite"
}
~ return "None"

/*

    Has Damaged Modules
    Returns true if any installed module is below max condition.

*/
=== function has_damaged_modules()
~ temp _modules = InstalledModules
~ return has_damaged_modules_loop(_modules)

/*

    Has Damaged Modules Loop
    Recursive helper for has_damaged_modules().

*/
=== function has_damaged_modules_loop(ref _modules)
{ LIST_COUNT(_modules) <= 0:
    ~ return false
}
~ temp module = pop(_modules)
{ get_module_condition(module) < get_module_max_condition(module):
    ~ return true
}
~ return has_damaged_modules_loop(_modules)

/*

    Module Maintenance Classification
    Functions for identifying and mapping module maintenance tasks.

*/

// Is this task a module maintenance task?
=== function is_module_maint(task)
~ return LIST_ALL(ModuleMaintTasks) ? task

// Maps a module maintenance task to its parent module.
=== function maint_task_module(task)
{ task:
- RepDroneServo:  ~ return RepairDrones
- RepDroneOptics: ~ return RepairDrones
- ClnDroneBrush:  ~ return CleaningDrones
- ClnDroneFilter: ~ return CleaningDrones
- NavChipFlush:   ~ return AutoNav
- NavGyroCalib:   ~ return AutoNav
- CargoSensor:    ~ return CargoMgmt
- CargoSealCheck: ~ return CargoMgmt
- PaxLifeSupp:    ~ return PassengerModule
- PaxBerthClean:  ~ return PassengerModule
}
~ return ()

// Returns the maintenance tasks belonging to a specific module.
=== function module_tasks_for(mod)
{ mod:
- RepairDrones:   ~ return (RepDroneServo, RepDroneOptics)
- CleaningDrones: ~ return (ClnDroneBrush, ClnDroneFilter)
- AutoNav:        ~ return (NavChipFlush, NavGyroCalib)
- CargoMgmt:      ~ return (CargoSensor, CargoSealCheck)
- PassengerModule: ~ return (PaxLifeSupp, PaxBerthClean)
}
~ return ()

// Returns the union of maintenance tasks for all installed modules.
=== function available_module_tasks()
~ temp _mods = InstalledModules
~ return available_module_tasks_loop(_mods)

=== function available_module_tasks_loop(ref _mods)
{ LIST_COUNT(_mods) <= 0:
    ~ return ()
}
~ temp mod = pop(_mods)
~ return module_tasks_for(mod) + available_module_tasks_loop(_mods)

/*

    Module Auto-Tasks
    Tunnel called from next_day() and transit start.
    All installed modules run their daily auto-complete logic here:
    drones handle maintenance backlog tasks, other modules handle
    nav checks, paperwork, and wellness effects.

*/
=== module_auto_tasks
{ is_module_active(RepairDrones):
    -> process_drone(RepairDrones, true) ->
}
{ is_module_active(CleaningDrones):
    -> process_drone(CleaningDrones, false) ->
}
{ InstalledModules ? AutoNav:
    -> process_auto_nav ->
}
{ InstalledModules ? CargoMgmt:
    -> process_cargo_mgmt ->
}
->->

/*

    Process Drone
    Tunnel that handles a single drone module's auto-completion.
    Loops through stale tasks first, then fresh, completing up to capacity.
    Uses gathers for looping to keep temp vars in scope.

*/
= process_drone(module, engine_only)
~ temp capacity = get_drone_capacity(module)
~ temp processed = 0
~ temp stale_pass = true
~ temp candidates = Backlog ^ StaleBacklog
- (drone_loop)
{ LIST_COUNT(candidates) <= 0 or processed >= capacity:
    { stale_pass and processed < capacity:
        ~ stale_pass = false
        ~ candidates = Backlog
        -> drone_loop
    }
    ->->
}
~ temp task = pop(candidates)
// Skip module tasks — drones only handle engine/ship tasks
{ is_module_maint(task):
    -> drone_loop
}
{ is_engine_maint(task) == engine_only:
    ~ complete_maintenance_task(task)
    ~ processed++
    -> drone_notify(task, engine_only) ->
}
-> drone_loop

= drone_notify(task, engine_only)
{ engine_only:
    { shuffle:
    -   The repair drone whirs to life, handling the {MaintName(task)} before you're even out of your bunk.
    -   Your repair drone takes care of the {MaintName(task)} overnight.
    -   You wake to find the repair drone has already finished the {MaintName(task)}.
    }
- else:
    { shuffle:
    -   The cleaning drone has already handled the {MaintName(task)}.
    -   Your cleaning drone quietly takes care of the {MaintName(task)}.
    -   You notice the cleaning drone has been busy — the {MaintName(task)} is done.
    }
}
->->

= process_auto_nav
~ temp nav_cond = get_module_condition(AutoNav)
{ TripDay >= NavCheckDueDay:
    { nav_cond >= 75:
        ~ NavCheckDueDay = TripDay + 3
        { shuffle:
        -   The auto-nav computer completes the course correction while you eat breakfast.
        -   A soft chime — the nav computer has finished today's trajectory check.
        -   Navigation check auto-completed. The computer confirms you're on course.
        }
    - else:
        { nav_cond >= 50:
            { TripDay mod 2 == 0:
                ~ NavCheckDueDay = TripDay + 3
                The auto-nav computer struggles through the course correction. It's running slow, but gets the job done.
            - else:
                The auto-nav is acting up again. It wasn't able to handle today's nav check. You make a mental note to get it looked at next time you're in port.
            }
        }
    }
}
->->

= process_cargo_mgmt
~ temp cargo_cond = get_module_condition(CargoMgmt)
~ temp did_task = false
// Cargo inspections take priority — they expire, paperwork doesn't
{ TripDay >= CargoCheckDueDay:
    { cargo_cond >= 75:
        ~ CargoCheckDueDay = TripDay + get_cargo_check_interval()
        ~ did_task = true
        { shuffle:
        -   The cargo management system runs the daily hold inspection automatically. All clear.
        -   A soft ping from cargo management — today's inspection is done. Seals and tie-downs checked.
        -   The cargo system completes its inspection sweep. Everything in the hold is secure.
        }
    - else:
        { cargo_cond >= 50:
            { TripDay mod 2 == 0:
                ~ CargoCheckDueDay = TripDay + get_cargo_check_interval()
                ~ did_task = true
                The cargo management system struggles through the hold inspection. It flags a few things but gets the job done.
            - else:
                The cargo management system tried to run an inspection but couldn't finish. It's running slow — you should get it looked at.
            }
        }
    }
}
// If no inspection was done (or none was due), try paperwork
{ not did_task and PaperworkDone < PaperworkTotal:
    { cargo_cond >= 75:
        ~ PaperworkDone = PaperworkDone + 1
        { PaperworkDone >= PaperworkTotal:
            The cargo management system files the last of your paperwork. All customs documentation handled automatically.
        - else:
            { shuffle:
            -   The cargo management system files a chunk of paperwork overnight. {PaperworkTotal - PaperworkDone} chunks remaining.
            -   Your cargo system auto-processed some customs forms. {PaperworkTotal - PaperworkDone} chunks left.
            }
        }
    - else:
        { cargo_cond >= 50:
            { TripDay mod 2 == 1:
                ~ PaperworkDone = PaperworkDone + 1
                The cargo management system pings — it managed to file a chunk of paperwork, but it's taking longer than it should. You make a mental note to have a tech look at it next time you're in port.
            }
        }
    }
}
->->

/*

    Ship Upgrades
    Port menu for buying and repairing modules.

*/
=== ship_upgrades
Engine: {manufacturer_name(ShipManufacturer)} Tier {ShipEngineTier}{RefurbishedEngine: (Refurbished — {get_engine_max_condition()}% max)}, condition {EngineCondition}%, fuel capacity {ShipFuelCapacity}.
{ LIST_COUNT(InstalledModules) > 0:
    Installed modules:
    -> show_module_status ->
}
- (upgrade_menu)
~ temp available = LIST_ALL(ShipModules) - InstalledModules - PassengerModule
{ LIST_COUNT(available) > 0:
    + [Browse available modules] -> browse_modules
}
+ { has_damaged_modules() } [Repair modules] -> repair_modules
+ { PassengerModuleTier < 3 } [Passenger module — {PassengerModuleTier == 0: install|upgrade}] -> passenger_module_upgrades
+ { ShipEngineTier < 4 and (manufacturer_available_here(Kepler) or manufacturer_available_here(Olympus) or manufacturer_available_here(Huygens)) }
    [Browse engine upgrades] -> engine_upgrades
+ [Back] -> arrive_in_port.port_opts
- -> upgrade_menu

/*

    Show Module Status
    Tunnel that displays condition of all installed modules.

*/
= show_module_status
~ temp _modules = InstalledModules
{ LIST_COUNT(_modules) <= 0:
    ->->
}
- (status_next)
~ temp module = pop(_modules)
~ temp cond = get_module_condition(module)
~ temp max_cond = get_module_max_condition(module)
{ module == PassengerModule:
    {PassengerTierName(PassengerModuleTier)}: {cond}%{max_cond < 100: /{max_cond}% max (refurbished)}{ cond < 50: — degraded}{ cond >= 50 and cond < 75: — reduced}
- else:
    {module_name(module)}: {cond}%{max_cond < 100: /{max_cond}% max (refurbished)}{ cond < 50: — OFFLINE}{ cond >= 50 and cond < 75: — reduced}
}
{ LIST_COUNT(_modules) > 0:
    -> status_next
}
->->

/*

    Browse Modules
    Shows available modules for purchase.

*/
= browse_modules
~ temp available = LIST_ALL(ShipModules) - InstalledModules
{ LIST_COUNT(available) <= 0:
    No modules available for purchase.
    -> upgrade_menu
}
Available modules:
-> browse_module_list ->
+ [Back] -> upgrade_menu
- -> upgrade_menu

= browse_module_list
~ temp _avail = LIST_ALL(ShipModules) - InstalledModules - PassengerModule
{ LIST_COUNT(_avail) <= 0:
    ->->
}
- (browse_next)
~ temp module = pop(_avail)
~ temp price = ModuleData(module, ModPrice)
~ temp half_price = price / 2
<- buy_module_choices(module, price, half_price)
{ LIST_COUNT(_avail) > 0:
    -> browse_next
}
->->

= buy_module_choices(module, price, half_price)
+ { PlayerBankBalance >= price } [Buy {module_name(module)} — new ({price} €)]
    ~ PlayerBankBalance -= price
    ~ install_module(module, 100)
    {module_name(module)} installed at 100% condition.
    -> upgrade_menu
+ { PlayerBankBalance < price } [Buy {module_name(module)} — new ({price} €) — can't afford #UNCLICKABLE]
    -> upgrade_menu
+ { PlayerBankBalance >= half_price } [Buy {module_name(module)} — refurbished ({half_price} €)]
    ~ PlayerBankBalance -= half_price
    ~ install_module(module, 60)
    ~ RefurbishedModules += module
    {module_name(module)} installed at 60% condition (refurbished — 80% max).
    -> upgrade_menu
+ { PlayerBankBalance < half_price } [Buy {module_name(module)} — refurbished ({half_price} €) — can't afford #UNCLICKABLE]
    -> upgrade_menu

/*

    Repair Modules
    Shows installed modules and offers repair options.

*/
= repair_modules
{ not has_damaged_modules():
    All modules are in top condition.
    -> upgrade_menu
}
-> repair_module_list ->
+ [Back] -> upgrade_menu
- -> upgrade_menu

= repair_module_list
~ temp _modules = InstalledModules
{ LIST_COUNT(_modules) <= 0:
    ->->
}
- (repair_next)
~ temp module = pop(_modules)
~ temp cond = get_module_condition(module)
~ temp max_cond = get_module_max_condition(module)
{ cond < max_cond:
    <- repair_module_choice(module, cond, max_cond)
}
{ LIST_COUNT(_modules) > 0:
    -> repair_next
}
->->

= repair_module_choice(module, cond, max_cond)
~ temp cost = get_module_repair_cost(module)
+ { PlayerBankBalance >= cost } [Repair {module_name(module)} — {cond}% → {max_cond}% ({cost} €)]
    ~ PlayerBankBalance -= cost
    ~ set_module_condition(module, max_cond)
    {module_name(module)} repaired to {max_cond}%.
    -> repair_modules
+ { PlayerBankBalance < cost } [Repair {module_name(module)} — {cond}% → {max_cond}% ({cost} €) — can't afford #UNCLICKABLE]
    -> repair_modules

/*

    Engine Upgrades
    Lets the player purchase a Tier N+1 engine from manufacturers available at the current port.
    Follows the same new/refurbished pattern as module purchases.

    engine_upgrades     — entry point, lists available options
    engine_buy_choices  — threaded stitch offering new/refurb/can't-afford choices per manufacturer

*/
= engine_upgrades
~ temp next_tier = ShipEngineTier + 1
Available Tier {next_tier} engines at this port:
<- engine_buy_choices(Kepler, next_tier)
<- engine_buy_choices(Olympus, next_tier)
<- engine_buy_choices(Huygens, next_tier)
+ [Back] -> upgrade_menu
- -> upgrade_menu

= engine_buy_choices(mfg, tier)
~ temp avail = manufacturer_available_here(mfg)
~ temp price = EngineData(mfg, tier, EngPrice)
~ temp half_price = price / 2
~ temp new_cap = EngineData(mfg, tier, FuelCap)
+ { avail and PlayerBankBalance >= price }
    [{manufacturer_name(mfg)} Tier {tier} — new ({price} €, {new_cap} fuel capacity)]
    ~ PlayerBankBalance -= price
    ~ ShipManufacturer = mfg
    ~ ShipEngineTier = tier
    ~ ShipFuelCapacity = new_cap
    ~ ShipFuel = MIN(ShipFuel, ShipFuelCapacity)
    ~ EngineCondition = 100
    ~ RefurbishedEngine = false
    The installation crew works through the night. By morning, a gleaming {manufacturer_name(mfg)} Tier {tier} engine hums in your hold. Fuel capacity: {ShipFuelCapacity}.
    -> upgrade_menu
+ { avail and PlayerBankBalance < price }
    [{manufacturer_name(mfg)} Tier {tier} — new ({price} €) — can't afford #UNCLICKABLE]
    -> upgrade_menu
+ { avail and PlayerBankBalance >= half_price }
    [{manufacturer_name(mfg)} Tier {tier} — refurbished ({half_price} €, {new_cap} fuel capacity)]
    ~ PlayerBankBalance -= half_price
    ~ ShipManufacturer = mfg
    ~ ShipEngineTier = tier
    ~ ShipFuelCapacity = new_cap
    ~ ShipFuel = MIN(ShipFuel, ShipFuelCapacity)
    ~ EngineCondition = 60
    ~ RefurbishedEngine = true
    A refurbished {manufacturer_name(mfg)} Tier {tier} engine, showing some wear but still solid. Installed at 60% condition — max 80% after repairs. Fuel capacity: {ShipFuelCapacity}.
    -> upgrade_menu
+ { avail and PlayerBankBalance < half_price }
    [{manufacturer_name(mfg)} Tier {tier} — refurbished ({half_price} €) — can't afford #UNCLICKABLE]
    -> upgrade_menu

/*

    Passenger Module Upgrades
    Tiered install/upgrade menu for the passenger module.
    Tier 1 (Basic Berths): 200€ fresh install or 100€ refurbished.
    Tier 2 (Standard Cabin): 200€ upgrade delta (400 total).
    Tier 3 (Luxury Suite): 400€ upgrade delta (800 total).
    Refurbished option only available for initial Tier 1 install.

*/
= passenger_module_upgrades
{ PassengerModuleTier == 0:
    No passenger facilities aboard. Installing passenger berths lets you take on passenger cargo.
- else:
    Current: {PassengerTierName(PassengerModuleTier)}{RefurbishedModules ? PassengerModule: (refurbished — {get_module_max_condition(PassengerModule)}% max)}, condition {get_module_condition(PassengerModule)}%.
}
~ temp next_tier = PassengerModuleTier + 1
{ next_tier <= 3:
    ~ temp next_price = PassengerTierPrice(next_tier)
    ~ temp upgrade_cost = next_price - PassengerTierPrice(PassengerModuleTier)
    ~ temp half_cost = upgrade_cost / 2
    <- passenger_buy_choice(next_tier, upgrade_cost, half_cost)
}
+ [Back] -> upgrade_menu
- -> upgrade_menu

= passenger_buy_choice(tier, price, half_price)
// New install/upgrade
+ { PlayerBankBalance >= price }
    [Install {PassengerTierName(tier)} — new ({price} €)]
    ~ PlayerBankBalance -= price
    { PassengerModuleTier == 0:
        ~ install_module(PassengerModule, 100)
    }
    ~ PassengerModuleTier = tier
    {
    - tier == 1:
        Basic berths installed at 100% condition. You can now take on passenger cargo.
    - tier == 2:
        Standard cabins fitted out. Passengers will be comfortable enough. Small daily satisfaction bonus active when module is above 50%.
    - tier == 3:
        Luxury suites installed. Your ship is practically a cruise liner. Enhanced daily satisfaction bonus active when module is above 50%.
    }
    -> upgrade_menu
+ { PlayerBankBalance < price }
    [Install {PassengerTierName(tier)} — new ({price} €) — can't afford #UNCLICKABLE]
    -> upgrade_menu
// Refurbished option — only for initial Tier 1 install
+ { PassengerModuleTier == 0 and PlayerBankBalance >= half_price }
    [Install {PassengerTierName(tier)} — refurbished ({half_price} €)]
    ~ PlayerBankBalance -= half_price
    ~ install_module(PassengerModule, 60)
    ~ RefurbishedModules += PassengerModule
    ~ PassengerModuleTier = tier
    Basic Berths installed at 60% condition (refurbished — 80% max). You can now take on passenger cargo.
    -> upgrade_menu
+ { PassengerModuleTier == 0 and PlayerBankBalance < half_price }
    [Install {PassengerTierName(tier)} — refurbished ({half_price} €) — can't afford #UNCLICKABLE]
    -> upgrade_menu
