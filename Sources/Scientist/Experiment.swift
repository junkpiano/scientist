//
//  Experiment.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

final public class Experiment<T: Equatable> {
    public typealias ExperimentBlock = () -> T?
    public typealias ComparatorBlock = (_ control: T?, _ candidate: T?) -> Bool

    public var enabled: () -> Bool = { return false }
    public var context: [String: Any] = [:]
    public var publish: ((Result<T>) -> Void)?

    public private(set) var name: String

    private var behaviors: [String: ExperimentBlock] = [:]
    private var comparator: ComparatorBlock?

    init(name: String  = Constants.defaultExperimentName) {
        self.name = name
    }

    public func use(control: @escaping () -> T?) {
        tryNew(name: Constants.defaultControlName, candidate: control)
    }

    public func tryNew(name: String? = nil, candidate: @escaping () -> T?) {
        let blockName = name ?? Constants.defaultCandidateName
        behaviors[blockName] = candidate
    }

    public func compare(_ compare: @escaping ComparatorBlock) {
        comparator = compare
    }

    public func run(name: String? = nil) -> T? {
        let executedBehavior: String = name ?? Constants.defaultControlName

        guard let block = behaviors[executedBehavior] else {
            return nil
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

        return nil
    }

    func observationsAreEquivalent(control: Observation<T>, candidate: Observation<T>) -> Bool {
        return control.equivalentTo(other: candidate, comparator: comparator)
    }

    private func publish(result: Result<T>) {
        publish?(result)
    }

    private var shouldExperimentRun: Bool {
        return behaviors.count > 1 && enabled()
    }
}
