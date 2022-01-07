# Scientist

[![CocoaPods](https://img.shields.io/cocoapods/v/Scientist.svg)](https://cocoapods.org/pods/Scientist)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/junkpiano/scientist.svg?branch=master)](https://travis-ci.org/junkpiano/scientist)
[![codecov](https://codecov.io/gh/junkpiano/scientist/branch/master/graph/badge.svg)](https://codecov.io/gh/junkpiano/scientist)
[![Documentation](https://raw.githubusercontent.com/junkpiano/scientist/master/docs/badge.svg?sanitize=true)](https://junkpiano.github.io/scientist/)

A Swift library for carefully refactoring critical paths.

## Installation

### Cocoapods

`pod 'Scientist', '~> 0.3.0'`

### Carthage

`github "junkpiano/scientist" ~> 0.3.0`

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/junkpiano/scientist.git", from: "0.3.0")
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

Full Documentation is available [Here](https://junkpiano.github.io/scientist/).

## Development

Simply,

`open Scientist.xcodeproj`

please run test before you send pull request

`swift test`

## Porting from

- [github/scientist](https://github.com/github/scientist)

## Author

- Yusuke Ohashi <[github](https://github.com/junkpiano), [Twitter](https://twitter.com/junkpiano)>
