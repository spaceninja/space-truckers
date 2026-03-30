/*

    Module Data Lookup
    Returns the requested stat for a given module.
    Follows the same pattern as EngineData/CargoData.

*/
=== function ModuleData(module, stat)
{ module:
- RepairDrones:   ~ return module_row(stat, "Repair Drones", 600, "Auto-complete engine maintenance tasks")
- CleaningDrones: ~ return module_row(stat, "Cleaning Drones", 500, "Auto-complete ship maintenance tasks")
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

    Drone Auto-Tasks
    Tunnel called from next_day() and transit start.
    Active drones auto-complete maintenance tasks from the backlog,
    preferring stale tasks over fresh ones.

*/
=== drone_auto_tasks
{ is_module_active(RepairDrones):
    -> process_drone(RepairDrones, true) ->
}
{ is_module_active(CleaningDrones):
    -> process_drone(CleaningDrones, false) ->
}
->->

/*

    Process Drone
    Tunnel that handles a single drone module's auto-completion.
    Two passes: stale tasks first, then fresh tasks.
    Uses gathers for looping to keep temp vars in scope.

*/
= process_drone(module, engine_only)
~ temp capacity = get_drone_capacity(module)
~ temp processed = 0
// Pass 1: stale tasks
~ temp candidates = Backlog ^ StaleBacklog
- (drone_pass_1)
{ LIST_COUNT(candidates) <= 0 or processed >= capacity:
    -> drone_pass_2_start
}
~ temp task = pop(candidates)
{ is_engine_task(task) == engine_only:
    ~ complete_maintenance_task(task)
    ~ processed++
    -> drone_notify(task, engine_only) ->
}
-> drone_pass_1
// Pass 2: fresh tasks
- (drone_pass_2_start)
~ candidates = Backlog
- (drone_pass_2)
{ LIST_COUNT(candidates) <= 0 or processed >= capacity:
    ->->
}
~ task = pop(candidates)
{ is_engine_task(task) == engine_only:
    ~ complete_maintenance_task(task)
    ~ processed++
    -> drone_notify(task, engine_only) ->
}
-> drone_pass_2

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
