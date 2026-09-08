//
//  Science.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

/// The entry point for running an experiment.
///
/// Each instance is generic over the single `Equatable` type its experiments return:
///
/// ```swift
/// let allowed = try Scientist<Bool>().science { experiment in
///   experiment.enabled = { true }
///   experiment.publish = { result in metrics.record(result) }
///   experiment.use { legacyCheck(user) }
///   experiment.tryNew { user.allowed }
/// }
/// ```
public struct Scientist<T: Equatable> {
  var defaultScientistContext: [String: Any]

  /// Creates a scientist whose experiments start with an empty context.
  public init() {
    self.init(with: nil)
  }

  /// Creates a scientist that seeds every experiment's ``Experiment/context`` with the
  /// given values.
  ///
  /// - Parameter context: Values applied to each experiment before the configuration
  ///   closure runs, so the closure can add to or replace them.
  public init(with context: [String: Any]? = nil) {
    defaultScientistContext = context ?? [:]
  }

  /// Configures an experiment and runs it.
  ///
  /// - Parameters:
  ///   - name: Identifies the experiment in the published ``Result``.
  ///   - options: Run options. `"run"` names the behavior to treat as the control,
  ///     both for comparison and for the returned value.
  ///   - process: Closure that registers the behaviors on the ``Experiment``.
  /// - Returns: The value returned by the control behavior.
  /// - Throws: Whatever the control behavior threw, or ``ExperimentError`` if the
  ///   requested behavior is missing or produced no value. A candidate that throws is
  ///   recorded, not propagated.
  public func science(
    name: String = "", options: [String: Any] = [:], _ process: (Experiment<T>) -> Void
  ) throws -> T {
    return try Scientist.run(name: name, options: options) { (experiment) in
      experiment.context = defaultScientistContext
      process(experiment)
    }
  }

  /// Configures an experiment and runs it, without a scientist instance.
  ///
  /// Same as ``science(name:options:_:)``, except that no default context is applied.
  ///
  /// - Parameters:
  ///   - name: Identifies the experiment in the published ``Result``.
  ///   - options: Run options. `"run"` names the behavior to treat as the control,
  ///     both for comparison and for the returned value.
  ///   - process: Closure that registers the behaviors on the ``Experiment``.
  /// - Returns: The value returned by the control behavior.
  /// - Throws: Whatever the control behavior threw, or ``ExperimentError`` if the
  ///   requested behavior is missing or produced no value. A candidate that throws is
  ///   recorded, not propagated.
  public static func run(
    name: String = "", options: [String: Any] = [:], _ process: (Experiment<T>) -> Void
  ) throws -> T {
    let exp = Experiment<T>(name: name)
    process(exp)

    let runName: String? = options[Constants.runParameter] as? String
    return try exp.run(name: runName)
  }
}
