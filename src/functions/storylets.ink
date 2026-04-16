LIST Acts = Act1, Act2
VAR Act = Act1

/*

    Act-Restricted Storylets Demo

*/
=== storylets ===
The beginning!
- (opts)
    // pick top 2 stories to choose from
    <- listAvailableStorylets(2, -> opts)
    // Let the player go to act two
    * {Act == Act1} [Go to Act 2]
        ~ Act = Act2
        -> opts
    // provide a fallback if there's nothing available
    * ->
-   There was nothing else to do.
    -> END

/*

    Storylet Database
    Linking storylet LIST values to their index functions.

*/
LIST StoryletProps = Content, Condition, ChoiceText
LIST Storylets = StoryA, StoryB, StoryC, StoryD, StoryE, StoryF // in priority order
VAR Act1Storylets = (StoryA, StoryB, StoryC)
VAR Act2Storylets = (StoryD, StoryE, StoryF)

// A database to return each story's database
=== function StoryletDatabase(storylet)
   { storylet:
   -  StoryA:   ~ return -> StoryletData_Avocado
   -  StoryB:   ~ return -> StoryletData_Bananas
   -  StoryC:   ~ return -> StoryletData_Crumpets
   -  StoryD:   ~ return -> StoryletData_Cucumber
   -  StoryE:   ~ return -> StoryletData_Apples
   -  StoryF:   ~ return -> StoryletData_Danishes
   }

/*

    Story Content
    Each storylet is a database function / content pair.

*/

=== function StoryletData_Avocado(prop)
    { prop:
    -   ChoiceText: Visit the Avocado Witch
    -   Condition:  ~ return not witch_content  // once only
    -   Content:    ~ return -> witch_content
    }

=== witch_content
    You visit the witch.
    ->->

=== function StoryletData_Bananas(prop)
    { prop:
    -   ChoiceText:  Now you have met the King, visit the Banana Boy!
    -   Condition:  ~ return king_content && not boy_content // once only
    -   Content:    ~ return -> boy_content
    }

=== boy_content
    You visit the boy.
    ->->

=== function StoryletData_Crumpets(prop)
    { prop:
    -   ChoiceText: Visit the Crumpet King
    -   Condition:  ~ return not king_content  // once only
    -   Content:    ~ return -> king_content
    }

=== king_content
    You visit the king.
    ->->

=== function StoryletData_Cucumber(prop)
    { prop:
    -   ChoiceText: Visit the Cucumber Sorcerer
    -   Condition:  ~ return not sorcerer_content  // once only
    -   Content:    ~ return -> sorcerer_content
    }

=== sorcerer_content
    You visit the sorcerer.
    ->->

=== function StoryletData_Apples(prop)
    { prop:
    -   ChoiceText:  Now you have met the Queen, visit the Apple Girl!
    -   Condition:  ~ return queen_content && not girl_content // once only
    -   Content:    ~ return -> girl_content
    }

=== girl_content
    You visit the girl.
    ->->

=== function StoryletData_Danishes(prop)
    { prop:
    -   ChoiceText: Visit the Danish Queen
    -   Condition:  ~ return not queen_content  // once only
    -   Content:    ~ return -> queen_content
    }

=== queen_content
    You visit the queen.
    ->->



/*

    Storylet Functionality
    The following functions run through the storylet database and find available storylets, in priority order

*/
VAR AvailableStorylets = ()

// 1. Clear and populate shortlist, then print choices.
=== listAvailableStorylets(max, -> backTo) ===
    ~ AvailableStorylets = ()
    { Act:
    - Act1: ~ computeStorylets(Act1Storylets, max)
    - Act2: ~ computeStorylets(Act2Storylets, max)
    }
    -> offerStorylets(AvailableStorylets, backTo)

// 2. Recursively check for available stories to add to the shortlist.
== function computeStorylets(list, max)
    // pull one story to evaluate (in ascending storylet order)
    ~ temp current = LIST_MIN(list)
    // if we have a story and we haven't hit max:
    { current && max > 0:
        // remove from consideration for future loops
        ~ list -= current
        // get the story's database function
        ~ temp storyletFunction = StoryletDatabase(current)
        // if the story is available:
        { storyletFunction(Condition):
            // add to shortlist
            ~ AvailableStorylets += current
            ~ max--
        }
        // loop
        ~ computeStorylets(list, max)
    }

// 3. Recursively display choices for the shortlisted stories.
=== offerStorylets(list, -> backTo) ===
    // pull one story from shortlist (in ascending storylet order)
    ~ temp current = LIST_MIN(list)
    // if we have a story:
    { current:
        // remove story from shortlist
        ~ list -= current
        // get the story's database function
        ~ temp storyletFunction = StoryletDatabase(current)
        // display a choice for this story
        +   [{storyletFunction(ChoiceText)}]
            ~ temp whereTo = storyletFunction(Content)
            -> whereTo -> backTo
    }
    // if the list isn't empty, keep looping
    { list:
        -> offerStorylets(list, backTo)
    }
    // if the list is empty, we're done
    -> DONE
