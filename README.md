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

## Development

please run test before you send pull request

`swift test`

On Linux, `./scripts/swift-container.sh` runs the same commands inside a Swift container.

## Porting from

- [github/scientist](https://github.com/github/scientist)

## Author

- Yusuke Ohashi <[github](https://github.com/junkpiano), [Twitter](https://twitter.com/junkpiano)>
