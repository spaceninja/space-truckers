---
name: ink-syntax
description: Provides syntax reference and authoring guidance for the Ink scripting language (inkle/ink). Use when writing, editing, or reviewing .ink files, when asked about Ink syntax, knots, stitches, choices, diverts, variables, lists, or any Ink language feature.
---

# Ink Language Syntax

Ink is a narrative scripting language for interactive stories. Files use the `.ink` extension.

## Core Building Blocks

### Content & Comments
```ink
Plain text is printed as-is.

// Single-line comment (ignored by compiler)
/* Multi-line comment */
TODO: Compiler prints this as a reminder
```

### Choices
```ink
* Once-only choice (disappears after selected)
+ Sticky choice (always available)
* [Bracketed text] suppresses choice text from output
* Prefix [only in choice] suffix in output   // before=both, inside=choice only, after=output only
```

### Knots & Stitches
```ink
=== knot_name ===      // top-level section; === name is fine too
= stitch_name          // sub-section inside a knot
```

### Diverts
```ink
-> knot_name           // jump to knot
-> knot_name.stitch    // jump to stitch
-> END                 // end the story
-> DONE                // end a thread (not the whole story)
<>                     // glue: suppress line break
```

### Gathers
```ink
- Gather point: rejoins branching flow
-- Nested gather (level 2)
- (label) Named gather: can be diverted to or tested
```

## Variables & Logic

```ink
VAR gold = 0              // global variable (int, float, string, bool, or divert)
CONST MAX = 100           // constant
~ temp x = 5              // temporary variable (scoped to current stitch)

~ gold = gold + 7         // assignment
~ gold++                  // increment
```

### Conditionals
```ink
{ condition: text if true | text if false }
{ condition: text if true }

{ x > 0:
    ~ y = x - 1
- else:
    ~ y = x + 1
}

{
    - x == 0: zero
    - x > 0: positive
    - else: negative
}
```

### Conditional Choices
```ink
* { condition } [Choice only shown if condition is true]
* { not visited_paris } [Go to Paris] -> visit_paris
+ { visit_paris } [Return to Paris] -> visit_paris
```

## Variable Text

```ink
{one|two|three}          // sequence: shows next each visit, sticks on last
{&Monday|Tuesday|Wed}    // cycle: loops
{!once|twice|thrice}     // once-only: blank after exhausted
{~Heads|Tails}           // shuffle: random

{variable_name}          // print variable value
```

## Functions

```ink
=== function my_func(a, b) ===
    ~ return a + b

~ result = my_func(3, 4)

=== function alter(ref x, k) ===   // ref = pass by reference
    ~ x = x + k
```

Functions cannot contain stitches, choices, or diverts.

## Tunnels

```ink
-> crossing_the_date_line ->    // run sub-story, then return
->->                            // exit tunnel (return to caller)
-> tunnel_a -> tunnel_b -> done // chain tunnels
```

## Threads

```ink
<- thread_knot             // fork in content from another knot
-> DONE                    // mark intentional end of a thread
```

## Lists (State Tracking)

```ink
LIST State = off, (on), standby    // brackets = initial value
VAR device = State                 // variable holding list state

~ device = on              // set single value
~ device++                 // advance to next value
~ device += on             // add value (multi-valued)
~ device -= off            // remove value
~ device = ()              // clear

{ device == on }           // equality
{ device ? on }            // containment (has)
{ device !? off }          // does not contain
{LIST_COUNT(device)}       // number of active values
{LIST_MIN(device)}         // lowest active value
{LIST_MAX(device)}         // highest active value
{LIST_ALL(device)}         // all possible values
```

## Read Counts & Game Queries

```ink
{ knot_name }              // true if knot has been visited
{ knot_name > 2 }          // visited more than 2 times
CHOICE_COUNT()             // number of choices created so far in this chunk
TURNS()                    // total turns since game began
TURNS_SINCE(-> knot)       // turns since knot visited; -1 = never seen
RANDOM(1, 6)               // random integer, inclusive
SEED_RANDOM(42)            // seed for deterministic testing
```

## Validating Ink Code

After editing any `.ink` file, always run the compiler to catch errors before committing:

```bash
npm run lint
```

This runs `inkjs-compiler space-truckers.ink` (the project entry point), which compiles all included files and reports errors. `TODO:` lines are informational and can be ignored. Any `ERROR:` lines must be fixed.

**Common errors to watch for:**
- `~` must be on its own line — never inline inside `{ }`. Use a multi-line block instead:
  ```ink
  // Wrong:
  { condition: ~ return true }
  
  // Correct:
  { condition:
      ~ return true
  }
  ```
- Functions cannot contain diverts (`->`) — use recursion instead of gather+loop patterns.
- Every flow path in a function must end with `~ return` or fall through to one.

## Include Files

```ink
INCLUDE other_file.ink     // always at top of file, outside knots
```

## Common Patterns

**Loop with fallback:**
```ink
=== find_help ===
* The woman in the hat[?] pushes you aside. -> find_help
* The man with the briefcase[?] ignores you. -> find_help
* ->
    You give up.
    -> END
```

**Question hub (re-entrant):**
```ink
- (opts)
    * [Ask about X] ... -> opts
    * [Ask about Y] ... -> opts
    * { opts > 1 } [Done talking] -> continue
- -> opts
```

**Parameterised knot as tunnel:**
```ink
-> generic_sleep(-> wake_up) ->

=== generic_sleep(-> waking) ===
You drift off...
-> waking
```

## Additional Reference

For complete documentation on advanced list operations, multi-list state machines, threads, and the full weave syntax, see [reference.md](reference.md).
