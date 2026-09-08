//
//  ScientistTests.swift
//  ScientistTests
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import XCTest

@testable import Scientist

class ScientistTests: XCTestCase {

  func testDisabledExperimentReturnsControlWithoutPublishing() throws {
    var published = false
    var candidateRan = false

    let returnValue = try Scientist<Bool>().science { experiment in
      // `enabled` defaults to false, so the candidate must never be executed.
      experiment.publish = { _ in published = true }

      experiment.use(control: { true })
      experiment.tryNew(candidate: {
        candidateRan = true
        return false
      })
    }

    XCTAssertTrue(returnValue)
    XCTAssertFalse(candidateRan, "candidate should not run while the experiment is disabled.")
    XCTAssertFalse(published, "publish should not be called while the experiment is disabled.")
  }

  func testMatchingCandidateIsReportedAsMatched() throws {
    var result: Result<String>?

    let returnValue = try Scientist<String>().science(name: "matching") { experiment in
      experiment.enabled = { true }
      experiment.publish = { result = $0 }

      experiment.use(control: { "test" })
      experiment.tryNew(candidate: { "test" })
    }

    XCTAssertEqual(returnValue, "test")

    let published = try XCTUnwrap(result, "publish should have been called.")
    XCTAssertEqual(published.experiment.name, "matching")
    XCTAssertEqual(published.candidates.count, 1)
    XCTAssertEqual(published.control?.name, "control")
    XCTAssertEqual(published.mismatches.count, 0)
    XCTAssertFalse(published.mismatched())
    XCTAssertFalse(published.ignored())
    XCTAssertTrue(published.matched())
  }

  func testMismatchingCandidateIsReportedAsMismatched() throws {
    var result: Result<String>?

    let returnValue = try Scientist<String>().science { experiment in
      experiment.enabled = { true }
      experiment.publish = { result = $0 }

      experiment.use(control: { "control value" })
      experiment.tryNew(candidate: { "candidate value" })
    }

    XCTAssertEqual(returnValue, "control value", "the control's value is always returned.")

    let published = try XCTUnwrap(result, "publish should have been called.")
    XCTAssertEqual(published.mismatches.map { $0.name }, ["candidate"])
    XCTAssertTrue(published.mismatched())
    XCTAssertFalse(published.ignored())
    XCTAssertFalse(published.matched(), "a mismatched result must not report as matched.")
  }

  func testComparatorOverridesEquality() throws {
    var result: Result<String>?

    _ = try Scientist<String>().science { experiment in
      experiment.enabled = { true }
      experiment.publish = { result = $0 }

      experiment.use(control: { "TEST" })
      experiment.tryNew(candidate: { "test" })

      // Values differ under `==`, but are equivalent case-insensitively.
      experiment.compare { control, candidate in
        control.lowercased() == candidate.lowercased()
      }
    }

    let published = try XCTUnwrap(result, "publish should have been called.")
    XCTAssertEqual(published.mismatches.count, 0)
    XCTAssertTrue(published.matched())
  }

  func testIgnoredMismatchIsNotReportedAsMismatchOrMatch() throws {
    var result: Result<Int>?

    _ = try Scientist<Int>().science { experiment in
      experiment.enabled = { true }
      experiment.publish = { result = $0 }

      experiment.use(control: { 1 })
      experiment.tryNew(name: "ignored", candidate: { 2 })
      experiment.tryNew(name: "reported", candidate: { 3 })

      experiment.ignores { _, candidate in candidate.name == "ignored" }
    }

    let published = try XCTUnwrap(result, "publish should have been called.")
    XCTAssertEqual(published.ignores.map { $0.name }, ["ignored"])
    XCTAssertEqual(published.mismatches.map { $0.name }, ["reported"])
    XCTAssertTrue(published.ignored())
    XCTAssertTrue(published.mismatched())
    XCTAssertFalse(published.matched())
  }

  func testFullyIgnoredMismatchIsNeitherMismatchedNorMatched() throws {
    var result: Result<Int>?

    _ = try Scientist<Int>().science { experiment in
      experiment.enabled = { true }
      experiment.publish = { result = $0 }

      experiment.use(control: { 1 })
      experiment.tryNew(candidate: { 2 })

      experiment.ignores { _, _ in true }
    }

    let published = try XCTUnwrap(result, "publish should have been called.")
    XCTAssertEqual(published.ignores.map { $0.name }, ["candidate"])
    XCTAssertEqual(published.mismatches.count, 0)
    XCTAssertTrue(published.ignored())
    XCTAssertFalse(published.mismatched())
    XCTAssertFalse(
      published.matched(), "an ignored mismatch is not a match, even with no mismatches left.")
  }

  func testRunOptionSelectsWhichBehaviorIsTheControl() throws {
    var result: Result<String>?

    let returnValue = try Scientist<String>().science(
      name: "run option", options: [Constants.runParameter: "candidate"]
    ) { experiment in
      experiment.enabled = { true }
      experiment.publish = { result = $0 }

      experiment.use(control: { "old" })
      experiment.tryNew(candidate: { "new" })
    }

    XCTAssertEqual(returnValue, "new", "the named behavior's value is returned.")

    let published = try XCTUnwrap(result, "publish should have been called.")
    XCTAssertEqual(published.control?.name, "candidate")
    XCTAssertEqual(published.mismatches.map { $0.name }, ["control"])
  }

  func testMissingBehaviorThrows() {
    XCTAssertThrowsError(
      try Scientist<Bool>().science(options: [Constants.runParameter: "nope"]) { experiment in
        experiment.enabled = { true }
        experiment.use(control: { true })
        experiment.tryNew(candidate: { false })
      }
    ) { error in
      guard case ExperimentError.behaviorNotFound = error else {
        return XCTFail("unexpected error: \(error)")
      }
    }
  }

  func testEveryBehaviorIsObserved() throws {
    var result: Result<Bool>?

    _ = try Scientist<Bool>().science { experiment in
      experiment.enabled = { true }
      experiment.publish = { result = $0 }

      experiment.use(control: { true })
      experiment.tryNew(candidate: { true })
    }

    let published = try XCTUnwrap(result, "publish should have been called.")
    XCTAssertEqual(published.observations.count, 2)
    XCTAssertEqual(Set(published.observations.map { $0.name }), ["control", "candidate"])
  }

  // MARK: - Behaviors that throw

  private enum TestError: Error {
    case boom
    case other
  }

  // Two distinct types that describe themselves identically, to pin down that the default
  // error comparison looks at the type and not only the description.
  private struct DescribedError: Error, CustomStringConvertible {
    let description: String
  }

  private struct OtherDescribedError: Error, CustomStringConvertible {
    let description: String
  }

  func testThrowingCandidateIsRecordedAndDoesNotReachTheCaller() throws {
    var result: Result<String>?

    let returnValue = try Scientist<String>().science { experiment in
      experiment.enabled = { true }
      experiment.publish = { result = $0 }

      experiment.use(control: { "control value" })
      experiment.tryNew(candidate: { throw TestError.boom })
    }

    XCTAssertEqual(returnValue, "control value", "a candidate's failure is not the caller's.")

    let published = try XCTUnwrap(result, "publish should have been called.")
    let candidate = try XCTUnwrap(published.candidates.first)
    XCTAssertTrue(candidate.raised)
    XCTAssertNil(candidate.value)
    XCTAssertEqual(candidate.error as? TestError, .boom)
    XCTAssertEqual(published.mismatches.map { $0.name }, ["candidate"])
    XCTAssertFalse(published.matched())
  }

  func testThrowingControlPublishesThenPropagates() throws {
    var result: Result<String>?

    XCTAssertThrowsError(
      try Scientist<String>().science { experiment in
        experiment.enabled = { true }
        experiment.publish = { result = $0 }

        experiment.use(control: { throw TestError.boom })
        experiment.tryNew(candidate: { "candidate value" })
      }
    ) { error in
      XCTAssertEqual(error as? TestError, .boom, "the control's error is the caller's.")
    }

    let published = try XCTUnwrap(result, "the result is published before the error propagates.")
    let control = try XCTUnwrap(published.control)
    XCTAssertTrue(control.raised)
    XCTAssertEqual(published.mismatches.map { $0.name }, ["candidate"])
  }

  func testBehaviorsThatThrowTheSameErrorMatch() throws {
    var result: Result<String>?

    XCTAssertThrowsError(
      try Scientist<String>().science { experiment in
        experiment.enabled = { true }
        experiment.publish = { result = $0 }

        experiment.use(control: { throw TestError.boom })
        experiment.tryNew(candidate: { throw TestError.boom })
      }
    ) { error in
      XCTAssertEqual(error as? TestError, .boom)
    }

    let published = try XCTUnwrap(result, "publish should have been called.")
    XCTAssertEqual(published.mismatches.count, 0, "the same failure on both sides is a match.")
    XCTAssertTrue(published.matched())
  }

  func testBehaviorsThatThrowDifferentErrorsMismatch() throws {
    var result: Result<String>?

    XCTAssertThrowsError(
      try Scientist<String>().science { experiment in
        experiment.enabled = { true }
        experiment.publish = { result = $0 }

        experiment.use(control: { throw TestError.boom })
        experiment.tryNew(candidate: { throw TestError.other })
      }
    ) { error in
      XCTAssertEqual(error as? TestError, .boom, "the control's error, not the candidate's.")
    }

    let published = try XCTUnwrap(result, "publish should have been called.")
    XCTAssertEqual(published.mismatches.map { $0.name }, ["candidate"])
  }

  func testRunOptionSelectsWhichErrorPropagates() {
    XCTAssertThrowsError(
      try Scientist<String>().science(options: [Constants.runParameter: "candidate"]) {
        experiment in
        experiment.enabled = { true }

        experiment.use(control: { throw TestError.boom })
        experiment.tryNew(candidate: { throw TestError.other })
      }
    ) { error in
      XCTAssertEqual(error as? TestError, .other, "the named behavior's error is the caller's.")
    }
  }

  func testDefaultErrorComparisonDistinguishesTypesWithTheSameDescription() throws {
    var result: Result<String>?

    XCTAssertThrowsError(
      try Scientist<String>().science { experiment in
        experiment.enabled = { true }
        experiment.publish = { result = $0 }

        experiment.use(control: { throw DescribedError(description: "boom") })
        experiment.tryNew(candidate: { throw OtherDescribedError(description: "boom") })
      }
    )

    let published = try XCTUnwrap(result, "publish should have been called.")
    XCTAssertEqual(
      published.mismatches.map { $0.name }, ["candidate"],
      "errors of different types are not equivalent, however they describe themselves.")
  }

  func testCompareErrorsCanRejectIdenticalErrors() throws {
    var result: Result<String>?

    XCTAssertThrowsError(
      try Scientist<String>().science { experiment in
        experiment.enabled = { true }
        experiment.publish = { result = $0 }

        experiment.use(control: { throw TestError.boom })
        experiment.tryNew(candidate: { throw TestError.boom })

        // The same error on both sides, rejected by the block.
        experiment.compareErrors { _, _ in false }
      }
    )

    let published = try XCTUnwrap(result, "publish should have been called.")
    XCTAssertEqual(
      published.mismatches.map { $0.name }, ["candidate"],
      "the registered block decides, not the default comparison.")
  }

  func testComparatorsReceiveTheControlThenTheCandidate() throws {
    var seenControlValue: String?
    var seenCandidateValue: String?
    var seenControlError: TestError?
    var seenCandidateError: TestError?

    _ = try Scientist<String>().science { experiment in
      experiment.enabled = { true }

      experiment.use(control: { "control value" })
      experiment.tryNew(candidate: { "candidate value" })

      experiment.compare { control, candidate in
        seenControlValue = control
        seenCandidateValue = candidate
        return true
      }
    }

    XCTAssertEqual(seenControlValue, "control value")
    XCTAssertEqual(seenCandidateValue, "candidate value")

    XCTAssertThrowsError(
      try Scientist<String>().science { experiment in
        experiment.enabled = { true }

        experiment.use(control: { throw TestError.boom })
        experiment.tryNew(candidate: { throw TestError.other })

        experiment.compareErrors { control, candidate in
          seenControlError = control as? TestError
          seenCandidateError = candidate as? TestError
          return true
        }
      }
    )

    XCTAssertEqual(seenControlError, .boom)
    XCTAssertEqual(seenCandidateError, .other)
  }

  func testThrowingIsNeverEquivalentToReturning() throws {
    var result: Result<String>?

    _ = try? Scientist<String>().science { experiment in
      experiment.enabled = { true }
      experiment.publish = { result = $0 }

      experiment.use(control: { "value" })
      experiment.tryNew(candidate: { throw TestError.boom })

      // Even a comparator that matches everything cannot equate the two.
      experiment.compare { _, _ in true }
      experiment.compareErrors { _, _ in true }
    }

    let published = try XCTUnwrap(result, "publish should have been called.")
    XCTAssertEqual(published.mismatches.map { $0.name }, ["candidate"])
  }

  func testCompareErrorsOverridesTheDefault() throws {
    var result: Result<String>?

    XCTAssertThrowsError(
      try Scientist<String>().science { experiment in
        experiment.enabled = { true }
        experiment.publish = { result = $0 }

        experiment.use(control: { throw TestError.boom })
        experiment.tryNew(candidate: { throw TestError.other })

        // Different errors, treated as equivalent.
        experiment.compareErrors { _, _ in true }
      }
    )

    let published = try XCTUnwrap(result, "publish should have been called.")
    XCTAssertEqual(published.mismatches.count, 0)
    XCTAssertTrue(published.matched())
  }

  func testDisabledExperimentPropagatesTheControlsError() {
    XCTAssertThrowsError(
      try Scientist<String>().science { experiment in
        // Left disabled: only the control runs, and its error is the caller's.
        experiment.use(control: { throw TestError.boom })
        experiment.tryNew(candidate: { "candidate value" })
      }
    ) { error in
      XCTAssertEqual(error as? TestError, .boom)
    }
  }

  // MARK: - Raising on mismatches

  func testRaiseOnMismatchesThrowsAfterPublishing() throws {
    var result: Result<String>?

    XCTAssertThrowsError(
      try Scientist<String>().science(name: "raising") { experiment in
        experiment.enabled = { true }
        experiment.raiseOnMismatches = true
        experiment.publish = { result = $0 }

        experiment.use(control: { "control value" })
        experiment.tryNew(candidate: { "candidate value" })
      }
    ) { error in
      let mismatch = error as? MismatchError
      XCTAssertEqual(mismatch?.experimentName, "raising")
      XCTAssertEqual(mismatch?.mismatches.map { $0.name }, ["candidate"])
      XCTAssertEqual(mismatch?.mismatches.first?.control, "control value")
      XCTAssertEqual(mismatch?.mismatches.first?.candidate, "candidate value")
    }

    XCTAssertNotNil(result, "the result is published before the error is thrown.")
  }

  func testRaiseOnMismatchesIsSilentWhenEverythingMatches() throws {
    let returnValue = try Scientist<String>().science { experiment in
      experiment.enabled = { true }
      experiment.raiseOnMismatches = true

      experiment.use(control: { "same" })
      experiment.tryNew(candidate: { "same" })
    }

    XCTAssertEqual(returnValue, "same")
  }

  func testRaiseOnMismatchesDoesNotThrowForIgnoredMismatches() throws {
    let returnValue = try Scientist<String>().science { experiment in
      experiment.enabled = { true }
      experiment.raiseOnMismatches = true

      experiment.use(control: { "control value" })
      experiment.tryNew(candidate: { "candidate value" })

      experiment.ignores { _, _ in true }
    }

    XCTAssertEqual(returnValue, "control value", "an ignored mismatch is not a failure.")
  }

  func testRaiseOnMismatchesIsOffByDefault() throws {
    let returnValue = try Scientist<String>().science { experiment in
      experiment.enabled = { true }

      experiment.use(control: { "control value" })
      experiment.tryNew(candidate: { "candidate value" })
    }

    XCTAssertEqual(returnValue, "control value", "a mismatch alone does not disturb the caller.")
  }

  func testRaiseWithChoosesTheError() {
    XCTAssertThrowsError(
      try Scientist<String>().science { experiment in
        experiment.enabled = { true }
        experiment.raiseOnMismatches = true

        experiment.use(control: { "control value" })
        experiment.tryNew(candidate: { "candidate value" })

        experiment.raiseWith { result in
          XCTAssertEqual(result.mismatches.map { $0.name }, ["candidate"])
          return TestError.other
        }
      }
    ) { error in
      XCTAssertEqual(error as? TestError, .other)
    }
  }

  func testRaisingOnMismatchesTakesPrecedenceOverTheControlsError() {
    XCTAssertThrowsError(
      try Scientist<String>().science { experiment in
        experiment.enabled = { true }
        experiment.raiseOnMismatches = true

        experiment.use(control: { throw TestError.boom })
        experiment.tryNew(candidate: { "candidate value" })
      }
    ) { error in
      XCTAssertTrue(
        error is MismatchError,
        "a mismatching run is the more specific failure; got \(error)")
    }
  }

  func testMismatchErrorDescribesThrownOutcomes() {
    XCTAssertThrowsError(
      try Scientist<String>().science(name: "described") { experiment in
        experiment.enabled = { true }
        experiment.raiseOnMismatches = true

        experiment.use(control: { "control value" })
        experiment.tryNew(candidate: { throw TestError.boom })
      }
    ) { error in
      let mismatch = error as? MismatchError
      XCTAssertEqual(mismatch?.mismatches.first?.candidate, "thrown boom")
      XCTAssertEqual(
        mismatch?.description,
        "experiment \"described\" mismatched — candidate: expected control value, got thrown boom")
    }
  }
}
