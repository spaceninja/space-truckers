/*

    Module Data Lookup
    Returns the requested stat for a given module.
    Follows the same pattern as EngineData/CargoData.

*/
=== function ModuleData(module, stat)
{ module:
- DroneBay:       ~ return module_row(stat, "Drone Bay", 600, "Maintenance drones that auto-complete daily tasks")
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
- DroneBay:       ~ return DroneBayCondition
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
- DroneBay:       ~ DroneBayCondition = value
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
=== function get_drone_capacity()
~ temp cond = get_module_condition(DroneBay)
~ temp per_drone = 0
{ cond >= 75:
    ~ per_drone = 2
}
{ cond >= 50 and per_drone == 0:
    ~ per_drone = 1
}
~ return per_drone * DroneBayTier

/*

    Get Module Max Condition
    Returns the maximum condition a module can be repaired to.

*/
=== function get_module_max_condition(module)
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

    Drone Bay Tier Helpers
    Price for fresh install at each tier (cumulative — used for upgrade delta math).
    Upgrade cost = DroneBayTierPrice(next) - DroneBayTierPrice(current).

*/
=== function DroneBayTierPrice(tier)
{ tier:
- 1: ~ return 600
- 2: ~ return 1000
}
~ return 0

/*

    Drone Bay Tier Name
    Display name for each tier of the drone bay module.

*/
=== function DroneBayTierName(tier)
{ tier:
- 1: ~ return "Single Drone"
- 2: ~ return "Dual Drones"
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
- DroneBayServo:  ~ return DroneBay
- DroneBayOptics: ~ return DroneBay
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
- DroneBay:       ~ return (DroneBayServo, DroneBayOptics)
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
{ is_module_active(DroneBay):
    -> process_drone ->
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
= process_drone
~ temp capacity = get_drone_capacity()
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
~ complete_maintenance_task(task)
~ processed++
-> drone_notify(task) ->
-> drone_loop

= drone_notify(task)
{ shuffle:
-   A maintenance drone handles the {MaintName(task)} before you're even out of your bunk.
-   Your drone takes care of the {MaintName(task)} overnight.
-   You wake to find a drone has already finished the {MaintName(task)}.
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
Engine: {manufacturer_name(ShipManufacturer)} Tier {ShipEngineTier}, fuel capacity {ShipFuelCapacity}.
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
+ { DroneBayTier < 2 } [Drone Bay — {DroneBayTier == 0: install|upgrade}] -> drone_bay_upgrades
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
{
- module == PassengerModule:
    {PassengerTierName(PassengerModuleTier)}: {cond}%{ cond < 50: — degraded}{ cond >= 50 and cond < 75: — reduced}
- module == DroneBay:
    {DroneBayTierName(DroneBayTier)}: {cond}%{ cond < 50: — OFFLINE}{ cond >= 50 and cond < 75: — reduced}
- else:
    {module_name(module)}: {cond}%{ cond < 50: — OFFLINE}{ cond >= 50 and cond < 75: — reduced}
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
~ temp _avail = LIST_ALL(ShipModules) - InstalledModules - PassengerModule - DroneBay
{ LIST_COUNT(_avail) <= 0:
    ->->
}
- (browse_next)
~ temp module = pop(_avail)
~ temp price = ModuleData(module, ModPrice)
<- buy_module_choices(module, price)
{ LIST_COUNT(_avail) > 0:
    -> browse_next
}
->->

= buy_module_choices(module, price)
+ { PlayerBankBalance >= price } [Buy {module_name(module)} ({price} €)]
    ~ PlayerBankBalance -= price
    ~ install_module(module, 100)
    {module_name(module)} installed at 100% condition.
    -> upgrade_menu
+ { PlayerBankBalance < price } [Buy {module_name(module)} ({price} €) — can't afford #UNCLICKABLE]
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
~ temp new_cap = EngineData(mfg, tier, FuelCap)
+ { avail and PlayerBankBalance >= price }
    [{manufacturer_name(mfg)} Tier {tier} ({price} €, {new_cap} fuel capacity)]
    ~ PlayerBankBalance -= price
    ~ ShipManufacturer = mfg
    ~ ShipEngineTier = tier
    ~ ShipFuelCapacity = new_cap
    ~ ShipFuel = MIN(ShipFuel, ShipFuelCapacity)
    The installation crew works through the night. By morning, a gleaming {manufacturer_name(mfg)} Tier {tier} engine hums in your hold. Fuel capacity: {ShipFuelCapacity}.
    -> upgrade_menu
+ { avail and PlayerBankBalance < price }
    [{manufacturer_name(mfg)} Tier {tier} ({price} €) — can't afford #UNCLICKABLE]
    -> upgrade_menu

/*

    Passenger Module Upgrades
    Tiered install/upgrade menu for the passenger module.
    Tier 1 (Basic Berths): 200€.
    Tier 2 (Standard Cabin): 200€ upgrade delta (400 total).
    Tier 3 (Luxury Suite): 400€ upgrade delta (800 total).

*/
= passenger_module_upgrades
{ PassengerModuleTier == 0:
    No passenger facilities aboard. Installing passenger berths lets you take on passenger cargo.
- else:
    Current: {PassengerTierName(PassengerModuleTier)}, condition {get_module_condition(PassengerModule)}%.
}
~ temp next_tier = PassengerModuleTier + 1
{ next_tier <= 3:
    ~ temp next_price = PassengerTierPrice(next_tier)
    ~ temp upgrade_cost = next_price - PassengerTierPrice(PassengerModuleTier)
    <- passenger_buy_choice(next_tier, upgrade_cost)
}
+ [Back] -> upgrade_menu
- -> upgrade_menu

= passenger_buy_choice(tier, price)
+ { PlayerBankBalance >= price }
    [Install {PassengerTierName(tier)} ({price} €)]
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
    [Install {PassengerTierName(tier)} ({price} €) — can't afford #UNCLICKABLE]
    -> upgrade_menu

/*

    Drone Bay Upgrades
    Tiered install/upgrade menu for the drone bay.
    Tier 1 (Single Drone): 600€.
    Tier 2 (Dual Drones): 400€ upgrade delta (1000€ total).

*/
= drone_bay_upgrades
{ DroneBayTier == 0:
    No maintenance drones aboard. A Drone Bay lets drones auto-complete daily maintenance tasks.
- else:
    Current: {DroneBayTierName(DroneBayTier)}, condition {get_module_condition(DroneBay)}%.
}
~ temp next_tier = DroneBayTier + 1
{ next_tier <= 2:
    ~ temp upgrade_cost = DroneBayTierPrice(next_tier) - DroneBayTierPrice(DroneBayTier)
    <- drone_bay_buy_choice(next_tier, upgrade_cost)
}
+ [Back] -> upgrade_menu
- -> upgrade_menu

= drone_bay_buy_choice(tier, price)
+ { PlayerBankBalance >= price }
    [Install {DroneBayTierName(tier)} ({price} €)]
    ~ PlayerBankBalance -= price
    { DroneBayTier == 0:
        ~ install_module(DroneBay, 100)
    }
    ~ DroneBayTier = tier
    {
    - tier == 1:
        A single maintenance drone is installed in the bay. It will auto-complete up to two maintenance tasks per day.
    - tier == 2:
        A second drone joins the bay. Two drones means up to four tasks handled automatically each day.
    }
    -> upgrade_menu
+ { PlayerBankBalance < price }
    [Install {DroneBayTierName(tier)} ({price} €) — can't afford #UNCLICKABLE]
    -> upgrade_menu
