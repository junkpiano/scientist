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
}
