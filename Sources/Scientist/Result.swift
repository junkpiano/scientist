//
//  Result.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/28.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation

/// What one run of an experiment produced.
///
/// It is built once per run and handed to ``Experiment/publish``, which is the only place
/// the outcome is reported.
public struct Result<T: Equatable> {

  /// The experiment that produced this result.
  ///
  /// Its ``Experiment/name`` and ``Experiment/context`` identify what was measured.
  public let experiment: Experiment<T>

  /// The observation the candidates were compared against, and whose value the run
  /// returned.
  ///
  /// This is the behavior named `"control"` unless the `"run"` option named another one.
  public let control: Observation<T>?

  /// Every observation, the control included.
  public let observations: [Observation<T>]

  /// Every observation except the control.
  public let candidates: [Observation<T>]

  /// Candidates that did not match the control and were not ignored.
  public var mismatches: [Observation<T>] = []

  /// Candidates that did not match the control but were suppressed by a condition
  /// registered with ``Experiment/ignores(_:)``.
  public var ignores: [Observation<T>] = []

  /// Whether any candidate mismatched the control without being ignored.
  public func mismatched() -> Bool {
    return mismatches.count > 0
  }

  /// Whether any mismatch was ignored.
  public func ignored() -> Bool {
    return ignores.count > 0
  }

  /// Whether every candidate matched the control.
  ///
  /// An ignored mismatch is not a match: a result with ignored candidates reports `false`
  /// here and `false` from ``mismatched()`` alike.
  public func matched() -> Bool {
    return !mismatched() && !ignored()
  }

  init(experiment: Experiment<T>, observations: [Observation<T>], control: Observation<T>? = nil) {
    self.experiment = experiment
    self.observations = observations
    self.control = control
    self.candidates = observations - control
    evaluateCandidate()
  }

  private mutating func evaluateCandidate() {
    guard let control = control else {
      return
    }

    mismatches = candidates.filter { (candidate) -> Bool in
      return experiment.observationsAreEquivalent(control: control, candidate: candidate) == false
    }

    ignores = mismatches.filter({ (mismatch) -> Bool in
      experiment.ignoresMismatchedObservations(control: control, candidate: mismatch)
    })

    mismatches -= ignores
  }
}
