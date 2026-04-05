# Recreation Depth — Cooking, Narrative Food, Port Shopping

**Issue:** #30  
**Date:** 2026-04-04

## Summary

Expanded the recreation system with a cooking sub-menu, diverse recipe list, fresh ingredient shopping at port, narrative food references throughout transit, and a new coffee machine event. Also fixed a bug where Entertainment module tasks appeared as standalone choices instead of inside the "Take a break" sub-menu.

## Design Decisions

### Food as Narrative, Not Mechanic

Eating as a biological need is handled through narrative flavor text only — shuffle variants in sleep wake-up text, next_day transitions, post-workout lines, and movie snack references. The player never clicks to "eat a meal." Eating just happens in the fiction.

Cooking in the recreation menu is reframed as treating yourself — not addressing hunger, but the experience of making something special. This puts it in the same category as watching a movie.

### Cooking Sub-Menu

"Heat up some rations" replaced with "Cook a special meal" (2 AP, +12 morale base, +15 for fresh ingredient meals). Each session draws 4+ random recipes from a 12-item `Recipes` LIST (diverse global cuisines). Fresh ingredients the player has purchased are always shown first, then random standard recipes fill to 4 choices.

Selection uses the same `pop_random()` / `list_random_subset_of_size()` pattern as daily maintenance task selection.

### Fresh Ingredients at Port

New "Go shopping" option in port menu. Each port stocks 2 items tied to that location. Purchasing adds the item to `PurchasedIngredients` (subset of `FreshIngredients` LIST in space-truckers.ink). Cooking with a fresh ingredient removes it — single-use, no inventory tracking needed.

### Entertainment Module Bug Fix

Video games and listen to music were appearing as standalone P4 top-level choices. They now live inside `relax_options` as inline-guarded choices (`{ is_module_active(Entertainment) }`), which is where they belong thematically.

### Coffee Machine Event

New random event (non-passenger, so always eligible). Offers repair (2 AP, small morale boost) or ignore (−15 morale). Passenger context text if carrying passengers (additional −5 morale if ignored).

## Files Changed

| File | Changes |
|---|---|
| `ship.ink` | Recipes LIST, cooking sub-menu, do_cook tunnel, recipe_name function, narrative food shuffle text in sleep/next_day/recreation, Entertainment tasks moved to relax_options |
| `port.ink` | Go Shopping menu, FreshIngredientData lookup, ingredients_at function, FreshIngredientStats LIST, port arrival food flavor text |
| `space-truckers.ink` | FreshIngredients LIST, PurchasedIngredients VAR |
| `events.ink` | CoffeeMachine event, added to Events LIST |
| `tests/integration/transit.test.js` | Updated relax sub-menu test |
| `tests/integration/modules.test.js` | Updated Entertainment and overdue module tests |
| `tests/integration/events.test.js` | Updated event count from 5 to 6 |
| `docs/developer-guide.md` | Updated recreation and Entertainment module sections |
| `docs/player-guide.md` | Updated recreation, added port shopping section |
