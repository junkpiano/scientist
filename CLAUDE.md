# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Scientist is a small Swift library for carefully refactoring critical paths by running two (or more) code paths side by side — a `control` and one or more `candidate`s — comparing their results, and publishing whether they matched. It's a Swift port of [github/scientist](https://github.com/github/scientist).

## Commands

Build and test (Swift Package Manager):

```sh
swift build -v
swift test -v
```

Run a single test:

```sh
swift test --filter ScientistTests/testScience
```

Ruby tooling (danger, jazzy) is pinned via `mise` (`.ruby-version` / `mise.toml`, Ruby 3.3.12). Install gems with `bundle install` before running them.

Generate docs (jazzy, output goes to `docs/`):

```sh
bundle exec jazzy
```

CI (`.github/workflows/ci.yml`) runs `swift build`/`swift test` on macOS on every push/PR.

## Architecture

The library has one core flow, spread across `Sources/Scientist/`:

- **`Scientist<T>`** (`Scientist.swift`) — the public entry point. `Scientist().science(name:options:process:)` creates an `Experiment<T>`, hands it to the caller's closure for configuration, then calls `Experiment.run`. `T` must be `Equatable`.
- **`Experiment<T>`** (`Experiment.swift`) — holds the experiment configuration set up inside the `science` closure:
  - `use(control:)` / `tryNew(name:candidate:)` register named behavior blocks (control is stored under `Constants.defaultControlName`).
  - `enabled` decides whether the experiment actually runs candidates, or just executes the control's block directly (`shouldExperimentRun` requires >1 registered behavior *and* `enabled() == true`).
  - `compare` sets a custom equality block; without one, `Observation`s are compared with `==`.
  - `ignores` registers predicates that suppress specific mismatches from being reported.
  - `run(name:)` executes every registered behavior as an `Observation`, builds a `Result`, calls `publish`, and returns the control's value (or throws `ExperimentError` if the named behavior/control is missing).
- **`Observation<T>`** (`Observation.swift`) — wraps executing a single behavior block, capturing its return value, timestamp, and duration. Also defines array-difference operators (`-`, `-=`) used to exclude the control from the candidate list.
- **`Result<T>`** (`Result.swift`) — computed once per run: separates `candidates` from `control`, then diffs each candidate against control (via `Experiment.observationsAreEquivalent`) to populate `mismatches`, and further splits out `ignores` (mismatches matched by an `ignores` predicate). `matched()`/`mismatched()`/`ignored()` are the boolean summaries a `publish` handler typically checks.
- **`ExperimentError`** (`Error.swift`) — thrown when `run` can't find the requested behavior or produce a control value.
- **`Constants`** (`Constants.swift`) — internal default names (`"control"`, `"candidate"`, `"experiment"`) and the `run(options:)` key (`"run"`) used to pick a non-default behavior to execute/return.

Everything is generic over a single `Equatable` type `T` per experiment; there is no dynamic/heterogeneous candidate support.
