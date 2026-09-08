//
//  Experiment.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

/// Runs a control block alongside one or more candidate blocks, compares what they
/// returned, and hands the outcome to ``publish``.
///
/// Configure an experiment inside the closure passed to
/// ``Scientist/science(name:options:_:)``: register the existing code path with
/// ``use(control:)``, each new one with ``tryNew(name:candidate:)``, and set ``enabled``
/// to decide whether the candidates run at all.
///
/// Whatever the candidates return, ``run(name:)`` returns the value of the behavior it
/// ran as the control — by default the one registered with ``use(control:)`` — so putting
/// a code path under experiment does not change what the caller sees.
final public class Experiment<T: Equatable> {
  /// A behavior under experiment: either the control or a candidate.
  public typealias ExperimentBlock = () -> T

  /// Decides whether a candidate's value is equivalent to the control's.
  ///
  /// Used in place of `==` when one is registered with ``compare(_:)``.
  public typealias ComparatorBlock = (_ control: T, _ candidate: T) -> Bool

  /// Type of block which define the conditions to ignore comparing observations.
  public typealias IgnoreObservationsBlock = (
    _ control: Observation<T>, _ candidate: Observation<T>
  ) -> Bool

  /// Whether the candidates run.
  ///
  /// Defaults to `{ false }`, so an experiment stays dormant until you opt in. It is
  /// evaluated by ``run(name:)`` once at least two behaviors are registered, which is
  /// where a feature flag or a percentage rollout belongs.
  public var enabled: () -> Bool = { return false }

  /// Arbitrary values carried alongside the experiment.
  ///
  /// A publish handler reads them back from ``Result/experiment``, which is useful for
  /// tagging published data with a request id, a user segment, and the like.
  public var context: [String: Any] = [:]

  /// Called with the ``Result`` once every behavior has run.
  ///
  /// This is where the outcome is recorded — a metrics backend, a log, an error reporter.
  /// It is not called when the experiment does not run; see ``enabled``.
  public var publish: ((Result<T>) -> Void)?

  /// The name this experiment was created with.
  public private(set) var name: String

  private var behaviors: [String: ExperimentBlock] = [:]
  private var comparator: ComparatorBlock?
  private var ignoreConditions: [IgnoreObservationsBlock] = []

  /// Registers the existing code path, under the name `"control"`.
  ///
  /// Its value is what ``run(name:)`` returns and what the candidates are compared
  /// against, unless the run names another behavior to use in its place.
  ///
  /// - Parameter control: Block producing the current behavior.
  public func use(control: @escaping ExperimentBlock) {
    tryNew(name: Constants.defaultControlName, candidate: control)
  }

  /// Registers a code path to compare against the control.
  ///
  /// Call it more than once to compare several candidates in the same experiment.
  /// Registering two candidates under the same name keeps only the last one.
  ///
  /// - Parameters:
  ///   - name: Identifies the candidate in the published ``Result``. Defaults to
  ///     `"candidate"`.
  ///   - candidate: Block producing the new behavior.
  public func tryNew(name: String? = nil, candidate: @escaping ExperimentBlock) {
    let blockName = name ?? Constants.defaultCandidateName
    behaviors[blockName] = candidate
  }

  /// Registers a condition that suppresses mismatches it matches.
  ///
  /// Ignored mismatches are reported in ``Result/ignores`` instead of
  /// ``Result/mismatches``, which keeps known-acceptable differences out of the mismatch
  /// count without hiding them. Conditions accumulate: a mismatch is ignored when any of
  /// them returns `true`.
  ///
  /// - Parameter condition: Returns `true` for a mismatch that should be ignored.
  public func ignores(_ condition: @escaping IgnoreObservationsBlock) {
    ignoreConditions.append(condition)
  }

  /// Compares observations with `compare` instead of `==`.
  ///
  /// Use it when equality is not the right test — values that carry a timestamp, an
  /// ordering that does not matter, a tolerance on a floating-point result.
  ///
  /// - Parameter compare: Returns `true` when the two values count as equivalent.
  public func compare(_ compare: @escaping ComparatorBlock) {
    comparator = compare
  }

  /// Runs every registered behavior, publishes the result, and returns the control's
  /// value.
  ///
  /// When ``enabled`` returns `false`, or fewer than two behaviors are registered, only
  /// the named block runs: nothing is compared and ``publish`` is not called.
  ///
  /// - Parameter name: Which behavior to treat as the control, both for comparison and
  ///   for the returned value. Defaults to `"control"`.
  /// - Returns: The value returned by the named behavior.
  /// - Throws: ``ExperimentError/behaviorNotFound`` if no behavior is registered under
  ///   `name`, or ``ExperimentError/valueNotReturned`` if the run produced no observation
  ///   for it.
  public func run(name: String? = nil) throws -> T {
    let executedBehavior: String = name ?? Constants.defaultControlName

    guard let block = behaviors[executedBehavior] else {
      throw ExperimentError.behaviorNotFound
    }

    if shouldExperimentRun == false {
      return block()
    }

    var observations: [Observation<T>] = []
    for key in behaviors.keys {
      if let block = behaviors[key] {
        observations.append(Observation<T>(name: key, experiment: self, block: block))
      }
    }

    let control: Observation<T>? = observations.first { (obv) -> Bool in
      return obv.name == executedBehavior
    }

    let result = Result<T>(experiment: self, observations: observations, control: control)

    publish(result: result)

    if let control = control {
      return control.value
    }

    throw ExperimentError.valueNotReturned
  }

  init(name: String = Constants.defaultExperimentName) {
    self.name = name
  }

  func observationsAreEquivalent(control: Observation<T>, candidate: Observation<T>) -> Bool {
    return control.equivalentTo(other: candidate, comparator: comparator)
  }

  func ignoresMismatchedObservations(control: Observation<T>, candidate: Observation<T>) -> Bool {
    var result: Bool = false
    for condition in ignoreConditions {
      if condition(control, candidate) {
        result = true
      }
    }
    return result
  }

  private func publish(result: Result<T>) {
    publish?(result)
  }

  private var shouldExperimentRun: Bool {
    return behaviors.count > 1 && enabled()
  }
}
