//
//  Result.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/28.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation

public struct Result<T: Equatable> {
    let experiment: Experiment<T>
    let control: Observation<T>?
    let observations: [Observation<T>]
    let candidates: [Observation<T>]
    var mismatches: [Observation<T>] = []
    var ignores: [Observation<T>] = []

    init(experiment: Experiment<T>, observations: [Observation<T>], control: Observation<T>? = nil) {
        self.experiment = experiment
        self.observations = observations
        self.control = control
        self.candidates = observations - control
        evaluate_candidate()
    }

    func mismatched() -> Bool {
        return mismatches.count > 0
    }

    func ignored() -> Bool {
        return ignores.count > 0
    }

    func matched() -> Bool {
        return mismatched() && !ignored()
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
