/*

    Module Data Lookup
    Returns the requested stat for a given module.
    Follows the same pattern as EngineData/CargoData.

*/
=== function ModuleData(module, stat)
{ module:
- RepairDrones:   ~ return module_row(stat, "Repair Drones", 800, "Auto-complete engine maintenance tasks")
- CleaningDrones: ~ return module_row(stat, "Cleaning Drones", 600, "Auto-complete ship maintenance tasks")
- AutoNav:        ~ return module_row(stat, "Auto-Nav Computer", 600, "Auto-complete navigation checks")
- CargoMgmt:      ~ return module_row(stat, "Cargo Management", 500, "Auto-file paperwork daily")
- Entertainment:  ~ return module_row(stat, "Entertainment System", 400, "Improved recreation and morale boosts")
- WellnessSuite:  ~ return module_row(stat, "Wellness Suite", 500, "Daily health benefits and emergency medical care")
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
- Entertainment:  ~ return EntertainmentCondition
- WellnessSuite:  ~ return WellnessSuiteCondition
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
- Entertainment:  ~ EntertainmentCondition = value
- WellnessSuite:  ~ WellnessSuiteCondition = value
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
{ InstalledModules ? WellnessSuite:
    -> process_wellness ->
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
{ is_engine_task(task) == engine_only:
    ~ complete_maintenance_task(task)
    ~ processed++
    -> drone_notify(task, engine_only) ->
}
-> drone_loop

= drone_notify(task, engine_only)
{ engine_only:
    { shuffle:
    -   The repair drone whirs to life, handling the {maint_task_name(task)} before you're even out of your bunk.
    -   Your repair drone takes care of the {maint_task_name(task)} overnight.
    -   You wake to find the repair drone has already finished the {maint_task_name(task)}.
    }
- else:
    { shuffle:
    -   The cleaning drone has already handled the {maint_task_name(task)}.
    -   Your cleaning drone quietly takes care of the {maint_task_name(task)}.
    -   You notice the cleaning drone has been busy — the {maint_task_name(task)} is done.
    }
}
->->

= process_auto_nav
~ temp nav_cond = get_module_condition(AutoNav)
{ TripDay > 0 and TripDay mod 3 == 0 and NavChecksCompleted < TripDay / 3:
    { nav_cond >= 75:
        ~ NavChecksCompleted++
        { shuffle:
        -   The auto-nav computer completes the course correction while you eat breakfast.
        -   A soft chime — the nav computer has finished today's trajectory check.
        -   Navigation check auto-completed. The computer confirms you're on course.
        }
    - else:
        { nav_cond >= 50:
            { NavChecksCompleted mod 2 == 0:
                ~ NavChecksCompleted++
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
{ PaperworkDone < PaperworkTotal:
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

= process_wellness
~ temp well_cond = get_module_condition(WellnessSuite)
{ well_cond >= 75:
    ~ Fatigue = MAX(Fatigue - 5, 0)
    ~ Morale = MIN(Morale + 2, 100)
    { shuffle:
    -   You squeeze in a quick session in the ship's gym. Your body thanks you.
    -   The autodoc dispenses your daily vitamin pack. It's the little things.
    -   You spend twenty minutes under the sunlight simulator. Somehow it actually helps.
    -   You check in with the remote therapy service. Just talking helps more than you expected.
    -   The hair trimmer takes care of business. You look almost human again.
    -   You grab the painkiller the autodoc recommends for the ache in your shoulder. Problem solved.
    }
- else:
    { well_cond >= 50:
        ~ Fatigue = MAX(Fatigue - 3, 0)
        ~ Morale = MIN(Morale + 1, 100)
        { shuffle:
        -   The gym equipment is acting up again, but you manage a short session.
        -   The autodoc is running slow, but eventually dispenses your supplements.
        -   The sunlight simulator flickers a bit, but you take what you can get.
        }
    }
}
->->

/*

    Degrade All Modules
    Tunnel called when the diagnostic task is skipped for too long.
    Reduces all installed module conditions by 5 (floored at 1).

*/
=== degrade_all_modules
~ temp _modules = InstalledModules
{ LIST_COUNT(_modules) <= 0:
    ->->
}
- (degrade_next)
~ temp module = pop(_modules)
~ temp cond = get_module_condition(module)
~ set_module_condition(module, MAX(cond - 5, 1))
{ LIST_COUNT(_modules) > 0:
    -> degrade_next
}
Your modules are showing signs of neglect. All module conditions have degraded.
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
~ temp available = LIST_ALL(ShipModules) - InstalledModules
{ LIST_COUNT(available) > 0:
    + [Browse available modules] -> browse_modules
}
+ { has_damaged_modules() } [Repair modules] -> repair_modules
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
{module_name(module)}: {cond}%{max_cond < 100: /{max_cond}% max (refurbished)}{ cond < 50: — OFFLINE}{ cond >= 50 and cond < 75: — reduced}
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
~ temp _avail = LIST_ALL(ShipModules) - InstalledModules
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
{ not manufacturer_available_here(mfg): ->-> }
~ temp price = EngineData(mfg, tier, EngPrice)
~ temp half_price = price / 2
~ temp new_cap = EngineData(mfg, tier, FuelCap)
+ { PlayerBankBalance >= price }
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
+ { PlayerBankBalance < price }
    [{manufacturer_name(mfg)} Tier {tier} — new ({price} €) — can't afford #UNCLICKABLE]
    ->->
+ { PlayerBankBalance >= half_price }
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
+ { PlayerBankBalance < half_price }
    [{manufacturer_name(mfg)} Tier {tier} — refurbished ({half_price} €) — can't afford #UNCLICKABLE]
    ->->
