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

  /// The value the block returned.
  public var value: T

  /// How long the block took, in milliseconds.
  public var during: Double

  init(name: String, experiment: Experiment<T>, block: Experiment<T>.ExperimentBlock) {
    self.name = name
    self.experiment = experiment

    now = Date()
    let start = DispatchTime.now()
    value = block()
    let end = DispatchTime.now()

    during = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1000000.0
  }

  func equivalentTo(other: Observation<T>, comparator: Experiment<T>.ComparatorBlock?) -> Bool {
    if let comparator = comparator {
      return comparator(value, other.value)
    } else {
      return value == other.value
    }
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
