/*

    Buy Fuel

*/
=== function buy_fuel(amount_requested)
// safety check that they don't ask for more fuel than capacity
~ temp fuel_needed = ShipFuelCapacity - ShipFuel
~ temp amount = MIN(fuel_needed, FLOOR(amount_requested))
// calculate the cost for the real amount of fuel
~ temp cost = INT(amount * FuelCost)
{
- BankBalance < cost:
    “Sorry, your credit chip was declined.”
- BankBalance >= cost:
    ~ ShipFuel = MIN(ShipFuel + amount, 100)
    ~ BankBalance -= MAX(cost, 0)
    “Thank you, come again!”
}

/*

    Get Fuel Cost
    
    TODO: Three grades of engines?
    
      A B C
          1
        2 2
      3 3 3 // Grade C economy = B balance = A turbo
      4 4
      5
*/
=== function get_fuel_cost(from, to, efficiency)
~ temp mass = total_mass(ShipCargo) + 5 // add 5 for the ship itself
~ temp distance = get_distance(from, to)
~ temp cost = FLOOR(distance * mass * efficiency)
DEBUG {distance}km * {mass}t * {efficiency}e = {cost} fuel
~ return cost

/*

    Get Trip Duration
    
    TODO: should mass factor in?

*/
=== function get_trip_duration(from, to, efficiency)
~ temp distance = get_distance(from, to)
~ temp time = MAX(FLOOR(distance / efficiency), 1)
DEBUG {distance}km / {efficiency}e = {time} days
~ return time

/*

	Takes the bottom element from a list, and returns it, modifying the list.

	Returns the empty list () if the source list is empty.

	Usage: 

	LIST fruitBowl = (apple), (banana), (melon)

	I eat the {pop(fruitBowl)}. Now the bowl contains {fruitBowl}.

*/
=== function pop(ref _list) 
~ temp el = LIST_MIN(_list) 
~ _list -= el
~ return el 

/*

	Takes a random element from a list, and returns it, modifying the list.

	Returns the empty list () if the source list is empty.

	Usage: 

	LIST fruitBowl = (apple), (banana), (melon)

	I eat the {pop_random(fruitBowl)}. Now the bowl contains {fruitBowl}.

*/
=== function pop_random(ref _list) 
~ temp el = LIST_RANDOM(_list) 
~ _list -= el
~ return el 
    
/*

	Returns a randomised subset of items from a list, up to a given size.

	Returns the empty list () if the source list is empty, and the complete list if it runs out of items to pick.

	Dependencies: 

		Requires "pop_random".

	Usage: 

		LIST fruitBowl = (apple), (banana), (melon)

		I put into my bag: {list_random_subset_of_size(fruitBowl, 2)}. 

*/
=== function list_random_subset_of_size(sourceList, n) 
{ n > 0:
    ~ temp el = pop_random(sourceList) 
    { el: 
        ~ return el + list_random_subset_of_size(sourceList, n-1)
    }
}
~ return () 

/*

	Returns a randomised subset of items that match a validator function from a list, up to a given size.

	Returns the empty list () if the source list is empty, or if no items match the validator function, and the complete list if it runs out of items to pick.

	Dependencies: 

		Requires "pop_random".

	Usage: 

		LIST fruitBowl = (apple), (banana), (melon)

		I put into my bag: {list_random_subset_of_size(fruitBowl, -> is_color, yellow, 2)}. 

*/
=== function validated_list_random_subset_of_size(sourceList, -> validator, arg, n) 
{ n > 0:
    ~ temp el = pop_random(sourceList) 
    { el: 
        {
        - validator(el, arg):
            ~ return el + validated_list_random_subset_of_size(sourceList, validator, arg, n-1)
        - else:
            ~ return validated_list_random_subset_of_size(sourceList, validator, arg, n)
        }
    }
}
~ return () 
