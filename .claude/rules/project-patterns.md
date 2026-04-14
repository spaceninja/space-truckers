# Space Truckers — Project Patterns

This document records useful patterns that would be helpful in future work. It is not intended for human readers, and can be written in a mode best suited for an AI reader.

## Data Modeling Pattern

Game data lookup functions uses LIST + function lookup tables (not Ink's built-in list values):

```ink
LIST CargoStats = From, To, Mass, Title, Express, Fragile
=== function CargoData(item, stat)
{ item == 001_Plums:
    ~ return cargo_row(stat, Earth, Mars, 5, ...)
}
```

## VAR Subset Pattern

When a subset of a LIST needs special treatment, define a VAR holding those members:

```ink
LIST Events = (A), (B), (C), (D)
VAR PassengerEvents = (C, D)    // subset requiring passengers
~ Events -= PassengerEvents      // bulk removal
```

## Ink Gotchas

- **Functions can't print text or use diverts.** Use knots/stitches/tunnels for narrative output.
- **Integer math:** `a * b / c` evaluates as `a * (b / c)`, truncating early. Store `a * b` in a temp first.
- **`~` on its own line:** Never inline `~ return` inside `{ condition: }`. Use a multi-line block.
- **VAR list init needs parens:** `VAR X = (A, B, C)` not `VAR X = A, B, C`.
- **Two conditional syntaxes, don't mix them:** Simple form puts the condition inline (`{ cond:` … `- else:`) and only supports `- else:` as a branch. Extended form puts `{` on its own line and uses `- condition:` for every branch including the first. Mixing them (simple opening + `- condition:` branch) is a compile error.
- **Threads (`<-`) are not tunnels (`-> ... ->`):** A stitch called via `<-` cannot use `->->` to return. Every branch must divert explicitly (e.g., `-> upgrade_menu`). To skip choices for a condition, gate them with `+ { condition }` rather than early-returning with `->->`.

## Test Helpers (tests/helpers/story.js)

- `createStory()` — compile fresh story instance
- `createListItem(story, 'ListName.Item')` — construct the InkList value representing a single LIST item
- `createListUnion(story, ...names)` — construct a multi-item InkList by unioning list-item values
- `continueToNextChoice(story)` — advance until the next choice point or end

Tests jump to specific knots via `story.ChoosePathString()` and set state via `story.variablesState["VarName"]`.

### Performance

`createStory()` compiles the full Ink source and is expensive (~200ms). Never call it in a loop. For statistical or iteration-based tests, compile once and use `story.ResetState()` between iterations:

```js
const s = createStory();
for (let i = 0; i < 30; i++) {
  s.ResetState();
  s.EvaluateFunction("some_function");
  // ... assert ...
}
```
