//
//  Result.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/28.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation

/**
 `Result` is a container of the results of the experiment.
 */
public struct Result<T: Equatable> {

    /// The experiment you conducted.
    public let experiment: Experiment<T>

    /// Control observation contains experiment for the existing logicA.
    public let control: Observation<T>?

    /// All Observations
    public let observations: [Observation<T>]

    /// The Observations except Control observation.
    public let candidates: [Observation<T>]

    /// The observation that contains
    public var mismatches: [Observation<T>] = []
    public var ignores: [Observation<T>] = []

    public func mismatched() -> Bool {
        return mismatches.count > 0
    }

    public func ignored() -> Bool {
        return ignores.count > 0
    }

    public func matched() -> Bool {
        return mismatched() && !ignored()
    }

    init(experiment: Experiment<T>, observations: [Observation<T>], control: Observation<T>? = nil) {
        self.experiment = experiment
        self.observations = observations
        self.control = control
        self.candidates = observations - control
        evaluate_candidate()
    }

    private mutating func evaluate_candidate() {
        guard let control = control else {
            return
        }

        mismatches = candidates.filter { (candidate) -> Bool in
            return experiment.observationsAreEquivalent(control: control, candidate: candidate) == false
        }

        ignores = mismatches.filter({ (mismatch) -> Bool in
            experiment.ignoresMismatchedObservations(control: control, candidate: mismatch)
        })

        mismatches = mismatches - ignores
    }
}
