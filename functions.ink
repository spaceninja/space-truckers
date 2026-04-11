/*

	Tests if the flow passes a particular gather on this turn.

	Usage: 

	- (welcome)
		"Welcome!"
	- (opts)
		*	{came_from(->welcome)}
			"Welcome to you!"
		*	"Er, what?"
			-> opts
		*	"Can we get on with it?"
		
*/
=== function came_from(-> x) 
~ return TURNS_SINCE(x) == 0

/*

	Tests if the flow passes a particular gather "very recently" - that is, within the last 3 turns.

	Usage: 

	- (welcome)
		"Welcome!"
	- (opts)
		*	{seen_very_recently(->welcome)}
			"Sorry, hello, yes."
		+	"Er, what?"
			-> opts
		*	"Can we get on with it?"
		
*/
=== function seen_very_recently(-> x)
~ return TURNS_SINCE(x) >= 0 && TURNS_SINCE(x) <= 3

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

/*

    Returns true if the given manufacturer's engines are sold at the current port.
    Kepler: Earth, Luna, Ceres
    Olympus: Mars, Ceres
    Huygens: Ganymede, Titan, Ceres

*/
=== function manufacturer_available_here(mfg)
{ mfg:
- Kepler:  ~ return here == Earth or here == Luna or here == Ceres
- Olympus: ~ return here == Mars or here == Ceres
- Huygens: ~ return here == Ganymede or here == Titan or here == Ceres
}
~ return false

/*

    Returns the full display name of an engine manufacturer.

*/
=== function manufacturer_name(mfg)
{ mfg:
- Kepler:  ~ return "Kepler Drive Systems"
- Olympus: ~ return "Olympus Propulsion"
- Huygens: ~ return "Huygens Deepspace"
}
~ return "Unknown"
