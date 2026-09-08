//
//  Observation.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/29.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation

/// What a single behavior returned, and what it cost to get there.
///
/// One is created per registered behavior each time an experiment runs, and they reach a
/// publish handler through ``Result``.
public struct Observation<T: Equatable> {
  /// When the block started running.
  public var now: Date

  /// The experiment this observation belongs to.
  public var experiment: Experiment<T>

  /// The name the behavior was registered under, `"control"` by default.
  public var name: String

  /// The value the block returned, or `nil` if it threw.
  public var value: T?

  /// The error the block threw, or `nil` if it returned normally.
  ///
  /// A candidate that fails is an outcome worth recording, not a reason to take the
  /// caller down with it, so the error is captured here instead of propagating. Only the
  /// control's error reaches the caller, from ``Experiment/run(name:)``.
  public var error: Error?

  /// Whether the block threw.
  public var raised: Bool {
    return error != nil
  }

  /// How long the block took, in milliseconds.
  ///
  /// Measured whether the block returned or threw.
  public var during: Double

  init(name: String, experiment: Experiment<T>, block: Experiment<T>.ExperimentBlock) {
    self.name = name
    self.experiment = experiment

    now = Date()
    let start = DispatchTime.now()
    do {
      value = try block()
    } catch {
      self.error = error
    }
    let end = DispatchTime.now()

    during = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1000000.0
  }

  func equivalentTo(
    other: Observation<T>,
    comparator: Experiment<T>.ComparatorBlock?,
    errorComparator: Experiment<T>.ErrorComparatorBlock?
  ) -> Bool {
    switch (error, other.error) {
    case (let error?, let otherError?):
      if let errorComparator = errorComparator {
        return errorComparator(error, otherError)
      }
      return Observation.errorsAreEquivalent(error, otherError)
    case (nil, nil):
      guard let value = value, let otherValue = other.value else {
        return false
      }
      if let comparator = comparator {
        return comparator(value, otherValue)
      }
      return value == otherValue
    default:
      // One threw and the other did not, which is the mismatch worth knowing about.
      return false
    }
  }

  /// Errors are not `Equatable`, so stand in for it the way the Ruby original does: two
  /// errors match when they are the same type and describe themselves the same way.
  /// Register ``Experiment/compareErrors(_:)`` for anything more specific.
  private static func errorsAreEquivalent(_ lhs: Error, _ rhs: Error) -> Bool {
    return type(of: lhs) == type(of: rhs) && String(describing: lhs) == String(describing: rhs)
  }

}

func - <T: Equatable>(left: [Observation<T>], right: Observation<T>?) -> [Observation<T>] {
  return left.filter {
    guard let right = right else {
      return true
    }

    return $0.name != right.name
  }
}

func -= <T: Equatable>(left: inout [Observation<T>], right: Observation<T>?) {
  guard let right = right else {
    return
  }

  let temp = left
  left = temp - right
}

func -= <T: Equatable>(left: inout [Observation<T>], right: [Observation<T>]) {
  let temp = left
  left = temp - right
}

func - <T: Equatable>(left: [Observation<T>], right: [Observation<T>]) -> [Observation<T>] {
  var result = left
  for obv in right {
    result -= obv
  }
  return result
}
