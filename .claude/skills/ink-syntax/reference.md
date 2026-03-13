# Ink Language — Extended Reference

## Weave in Depth

Weave is ink's key structural innovation: choices and gathers form a forward-flowing chain without needing explicit knot names.

```ink
=== escape ===
I ran through the forest.

    * I checked my pockets. <>
    * I kept on running. <>
    * I cheered. <>

- The road was near!

    * I reached the road[]. And would you believe it?
    * (aside) I should mention Mackie is reliable[]. Normally.

- The road was empty. Mackie was gone.
```

### Nested Weave
```ink
- "Murder or suicide?"
    * "Murder!"
        "Who did it?"
        * * "Japp!"
        * * "Hastings!"
        - - "You must be joking!"
        * * "I am deadly serious."
    * "Suicide!"
        "Are you sure?"
        * * "Quite sure."
- Mrs. Christie lowered her manuscript.
```

Level depth: `*`, `* *`, `* * *`… / `-`, `- -`, `- - -`…

### Labelled Gathers & Options
```ink
- (hub)
    * (greet) [Greet him] 'Hello.'
    * (threaten) 'Get out of my way.'
- 'Hmm,' he replies.
* { greet } 'Nice day?' // only if greeted
* { threaten } [Shove him] -> fight    // only if threatened
```

---

## Advanced Variable Text

### Multiline Alternatives
```ink
{ stopping:
    - I entered the casino.
    - I entered again.
    - Once more, I went in.
}

{ shuffle:
    - Ace of Hearts.
    - King of Spades.
}

{ cycle:
    - I held my breath.
    - I waited impatiently.
}

{ once:
    - Would my luck hold?
    - Could I win?
}
```

### Modified Shuffles
```ink
{ shuffle once:   ... }     // play once, then nothing
{ shuffle stopping: ... }   // shuffle all-but-last, then stick on last
```

---

## Lists — Advanced Operations

### Comparing Lists
- `A > B` — every value in A is numerically greater than every value in B
- `A >= B` — A's range entirely overlaps or exceeds B's range
- Standard `==`, `!=`, `<`, `<=` also work for single-value lists

### Intersection
```ink
{ desiredValues ^ actualValues }   // returns overlapping elements
{ LIST_COUNT(a ^ b) > 0: overlap exists }
```

### Inversion
```ink
~ GuardsOnDuty = LIST_INVERT(GuardsOnDuty)  // flip all in/out states
```

### Range Slice
```ink
LIST_RANGE(LIST_ALL(primeNumbers), 10, 20)   // values between 10–20 inclusive
```

### Type-refreshing an Empty List
```ink
LIST ValueList = first, second, third
VAR myList = ()
~ myList = ValueList()     // empty list that knows its type; LIST_ALL works
```

### Multi-family Lists
```ink
LIST Characters = Alfred, Batman, Robin
LIST Props = champagne_glass, newspaper

VAR BallroomContents = (Alfred, Batman, newspaper)

* { BallroomContents ? (Batman, Alfred) } [Talk to both] ...
```

---

## Tunnels — Advanced

### Returning Somewhere Else from a Tunnel
```ink
=== hurt(x) ===
    ~ stamina -= x
    { stamina <= 0:
        ->-> youre_dead    // return, but divert to youre_dead instead of caller
    }
    ->->
```

### Conversation Loop with Tunnel Exit
```ink
-> talk_to_jim ->

=== talk_to_jim ===
- (opts)
    * [Ask about shields] -> shields ->
    * [Stop talking]      ->->
- -> opts

= shields
    { warp_lacels : ->-> argue }    // break out to argue if other topic visited
    "Shields are fine."
    ->->
```

---

## Threads — Advanced

Threads fork content and collect options from multiple sources before presenting them together. Unlike tunnels, they do **not** run a separate flow to completion; they gather options and the chosen branch becomes the main flow.

```ink
== hallway ==
<- characters_present(HALLWAY)
* [Open the drawers] -> examine_drawers
* [Leave] -> corridor
- -> run_location

== characters_present(room)
    { generals_location == room: <- general_dialogue }
    { doctors_location == room:  <- doctor_dialogue  }
    -> DONE
```

Key rules:
- Global variables are **not** forked between threads.
- Threads end when they run out of content; mark intentional ends with `-> DONE`.
- `-> END` inside a thread ends the **entire story**, not just the thread.

---

## Parameters & Divert Targets as Values

```ink
VAR current_epilogue = -> everybody_dies

=== continue_or_quit ===
* [Give up] -> current_epilogue    // diverts to the stored divert

=== generic_sleep(-> waking) ===
You fall asleep.
-> waking
```

---

## String Queries

```ink
{ "Yes, please." == "Yes, please." }   // true
{ "No, thanks." != "Yes, please." }    // true
{ "Yes, please" ? "ease" }             // substring test; true
```

---

## Common Helper Functions

These patterns appear in most inkle projects:

```ink
// Clamp a stat
=== function harm(x) ===
    { stamina < x:
        ~ stamina = 0
    - else:
        ~ stamina = stamina - x
    }

// Alter by delta (inline-friendly)
=== function alter(ref x, k) ===
    ~ x = x + k

// Check if just visited
=== function came_from(-> x) ===
    ~ return TURNS_SINCE(x) == 0

// Change a list property cleanly
=== function changeStateTo(ref stateVar, newState) ===
    ~ stateVar -= LIST_ALL(newState)
    ~ stateVar += newState
```

---

## Compiler Warnings to Know

| Situation | Fix |
|-----------|-----|
| Flow runs out without `-> END` or choice | Add `-> END` or `-> DONE` |
| Thread ends without content | Add `-> DONE` |
| Ambiguous list value (two lists share a name) | Use `ListName.value` syntax |
| Loose end in tunnel | Ensure all paths reach `->->` |
