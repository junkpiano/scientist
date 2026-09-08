# Scientist

[![CI](https://github.com/junkpiano/scientist/actions/workflows/ci.yml/badge.svg)](https://github.com/junkpiano/scientist/actions/workflows/ci.yml)

A Swift library for carefully refactoring critical paths.

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/junkpiano/scientist.git", from: "0.6.0")
]
```

## Usage

```swift
    func allow(user: User) -> Bool {
      do {
        return try Scienctist<Bool>().science({
          experiment in
          // required to enable Experiment
          experiment.enabled = { return true }

          // alternatively, you can use A/B test-like logic.
          experiment.enabled = {
            return Int(arc4random_uniform(6) + 1) % 3 == 0
          }

          experiment.publish = { result in
            // do something to publish Result data.
            // send to your log server(Graphite, InfluxDB, etc.), or 3rd party logger like NewRelic, Firebase.
          }

          experiment.use {
            return module.check_user(user)
          }

          experiment.tryNew {
            return user.allowed
          }
        })
      } catch {
        return false
      }
    }
```

Full Documentation is available [Here](https://junkpiano.github.io/scientist/documentation/scientist).

## Comparing implementations from different coding agents

An experiment runs several implementations of the same thing against real traffic and
reports whether they agreed, which makes it a way to compare code written by different
coding agents. Register each agent's version as its own candidate and let production
inputs decide:

```swift
let total = try Scientist<Int>().science(name: "checkout total") { experiment in
  // Sample 5% of traffic.
  experiment.enabled = { Int.random(in: 1...100) <= 5 }

  experiment.use { currentTotal(cart) }                    // what ships today
  experiment.tryNew(name: "agent-a") { agentATotal(cart) }
  experiment.tryNew(name: "agent-b") { agentBTotal(cart) }

  experiment.publish = { result in
    for observation in result.observations {
      metrics.record("\(result.experiment.name).\(observation.name).ms", observation.during)
    }
    for mismatch in result.mismatches {
      metrics.increment("\(result.experiment.name).\(mismatch.name).mismatch")
    }
  }
}
```

Every `Observation` carries both the value its block returned and `during`, how long it
took in milliseconds, so a publish handler sees each half of the comparison: whether an
agent's version agrees with the one in production, and what it cost to run. The control's
value is what gets returned either way, so an agent's implementation cannot change the
result while it is being evaluated.

Two things worth knowing before reading anything into the numbers:

- This is not a benchmark harness. Each behavior runs once per experiment, in-process and
  in sequence, with no warmup, so a single `during` is mostly noise. The signal is in
  aggregating many runs over the inputs the code actually sees.
- A candidate that traps takes the process down with it. `ExperimentBlock` cannot throw,
  so an implementation you do not trust yet needs to handle its own failures inside the
  block.

## Development

please run test before you send pull request

`swift test`

On Linux, `./scripts/swift-container.sh` runs the same commands inside a Swift container.

## Porting from

- [github/scientist](https://github.com/github/scientist)

## Author

- Yusuke Ohashi <[github](https://github.com/junkpiano), [Twitter](https://twitter.com/junkpiano)>
