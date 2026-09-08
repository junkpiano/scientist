//
//  MismatchError.swift
//  Scientist
//

/// Thrown by ``Experiment/run(name:)`` when ``Experiment/raiseOnMismatches`` is set and a
/// candidate did not match the control.
///
/// It carries a summary rather than the ``Result`` itself: `Error` refines `Sendable` in
/// Swift 6, and a `Result` holds its `Experiment`, which is a mutable class. The summary
/// is what a failing test needs to say which candidate diverged and what it produced.
/// Register ``Experiment/raiseWith(_:)`` for anything richer.
public struct MismatchError: Error, CustomStringConvertible {
  /// One candidate that did not match the control.
  public struct Mismatch: Sendable {
    /// The name the candidate was registered under.
    public let name: String

    /// What the control produced: its value, or the error it threw.
    public let control: String

    /// What the candidate produced: its value, or the error it threw.
    public let candidate: String
  }

  /// The name of the experiment that mismatched.
  public let experimentName: String

  /// The candidates that did not match the control and were not ignored.
  public let mismatches: [Mismatch]

  public var description: String {
    let detail = mismatches.map { mismatch in
      "\(mismatch.name): control \(mismatch.control), candidate \(mismatch.candidate)"
    }.joined(separator: "; ")
    return "experiment \"\(experimentName)\" mismatched — \(detail)"
  }

  init<T: Equatable>(result: Result<T>) {
    experimentName = result.experiment.name
    let control = result.control
    mismatches = result.mismatches.map { candidate in
      Mismatch(
        name: candidate.name,
        control: control.map(MismatchError.describe) ?? "had no control",
        candidate: MismatchError.describe(candidate))
    }
  }

  /// Describes an outcome so that two different ones cannot read the same way.
  ///
  /// The type is named because two error types can describe themselves identically, and
  /// that difference is exactly what made the run mismatch. The `threw` and `returned`
  /// prefixes keep a thrown error apart from a value that happens to read like one.
  private static func describe<T: Equatable>(_ observation: Observation<T>) -> String {
    if let error = observation.error {
      return "threw \(type(of: error)): \(error)"
    }
    if let value = observation.value {
      return "returned \(value)"
    }
    return "produced nothing"
  }
}
