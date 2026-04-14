# Space Truckers

An interactive fiction game written in [Ink](https://github.com/inkle/ink) (inkle's narrative scripting language).

Project-specific code patterns are in `.claude/rules/project-patterns.md`.

## Skills

Consult these project skills when working in their domains:

- `/ink-syntax` — Ink language reference. Use when writing or editing `.ink` files.
- `/ink-testing` — Testing conventions, helpers, and performance guidelines. Use when writing or modifying tests.

## Documentation

Before opening a PR, review `.claude/rules/project-patterns.md` to check if changes in the PR require documentation updates. If so, update as part of the PR.

## Testing

Always run `npm test` and `npm run lint` before opening a PR — both must pass.

## PR Branching

Always create feature branches from the latest `main`, never from another feature branch:

```bash
git fetch origin
git checkout -b my-feature origin/main
```

Before opening a PR, verify it contains only the intended commits: `git log --oneline origin/main..HEAD`. If extra commits are present, create a fresh branch off `origin/main` and cherry-pick only the intended ones.
