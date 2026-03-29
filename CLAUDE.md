# Space Truckers

An interactive fiction game written in [Ink](https://github.com/inkle/ink) (inkle's narrative scripting language). The player hauls cargo between solar system ports, managing fuel, maintenance, fatigue, and morale during transit. Progression comes from engine upgrades and ship modules that automate routine tasks.

Key docs: `docs/developer-guide.md` (design rationale), `docs/player-guide.md` (gameplay). Project-specific code patterns are in `.claude/rules/project-patterns.md`. Open GitHub issues track remaining module system work.

## PR Branching

Always create feature branches from the latest `main`, never from another feature branch:

```bash
git fetch origin
git checkout -b my-feature origin/main
```

Before opening a PR, verify it contains only the intended commits: `git log --oneline origin/main..HEAD`. If extra commits are present, create a fresh branch off `origin/main` and cherry-pick only the intended ones.

## Simulator / Game Data Sync

`simulator.html` has a GAME DATA block (top of `<script>`) that mirrors constants from the Ink source. When editing either file, check the other stays in sync:

| simulator.html | Ink source |
|---|---|
| `PAY_RATE` | `space-truckers.ink` — `VAR PayRate` |
| `SHIP_MASS` | `space-truckers.ink` — ship hull mass |
| `ENGINES` | `engines.ink` — `EngineData` table |
| `LOCATION_NAMES` / `LOCATION_DISPLAY` | `locations.ink` — `LocationData Name` |
| `DISTANCES` | `locations.ink` — `get_distance` |
| `FUEL_PRICES` | `locations.ink` — `FuelPrice` |

New constants added to `simulator.html` must include a citation comment pointing to the Ink source.

## Documentation

Before opening a PR, review `docs/developer-guide.md` and `docs/player-guide.md` to check if changes in the PR require documentation updates. Update them as part of the PR.

## Testing

Always run `npm test` before opening a PR. CI runs `npm run lint` then `npm test` — both must pass.
