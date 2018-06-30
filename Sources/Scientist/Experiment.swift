//
//  Experiment.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

final public class Experiment<T: Equatable> {
    public typealias ExperimentBlock = () -> T
    public typealias ComparatorBlock = (_ control: T, _ candidate: T) -> Bool
    public typealias IgnoreObservationsBlock = (_ control: Observation<T>, _ candidate: Observation<T>) -> Bool

    public var enabled: () -> Bool = { return false }
    public var context: [String: Any] = [:]
    public var publish: ((Result<T>) -> Void)?

    public private(set) var name: String

    private var behaviors: [String: ExperimentBlock] = [:]
    private var comparator: ComparatorBlock?
    private var ignoreConditions: [IgnoreObservationsBlock] = []

    init(name: String  = Constants.defaultExperimentName) {
        self.name = name
    }

    public func use(control: @escaping () -> T) {
        tryNew(name: Constants.defaultControlName, candidate: control)
    }

    public func tryNew(name: String? = nil, candidate: @escaping () -> T) {
        let blockName = name ?? Constants.defaultCandidateName
        behaviors[blockName] = candidate
    }

    public func ignores(_ condition:@escaping IgnoreObservationsBlock) {
        ignoreConditions.append(condition)
    }

    public func compare(_ compare: @escaping ComparatorBlock) {
        comparator = compare
    }

    public func run(name: String? = nil) throws -> T {
        let executedBehavior: String = name ?? Constants.defaultControlName

        guard let block = behaviors[executedBehavior] else {
            throw ExperimentError.behaviorNotFound
        }

        if shouldExperimentRun == false {
            return block()
        }

        var observations: [Observation<T>] = []
        behaviors.keys.forEach { (key) in
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

    func observationsAreEquivalent(control: Observation<T>, candidate: Observation<T>) -> Bool {
        return control.equivalentTo(other: candidate, comparator: comparator)
    }

    func ignoresMismatchedObservations(control: Observation<T>, candidate: Observation<T>) -> Bool {
        var result: Bool = false
        ignoreConditions.forEach { (condition) in
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
