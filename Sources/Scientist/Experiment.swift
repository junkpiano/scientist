//
//  Experiment.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

open class Experiment<T: Equatable>: Experimentable {

    var name: String
    var enabled: Bool
    var context: [String : Any]
    
    typealias resultType = T
    public typealias ExperimentBlock = () -> T?
    private var behaviors: [String: ExperimentBlock] = [:]
    private var comparator: ((_ control: ExperimentBlock, _ candidate: ExperimentBlock) -> Bool)? = nil
    
    init(name: String = "", enabled: Bool = false) {
        self.name = name
        self.enabled = enabled
        self.context = [:]
    }

    final public func use(control: @escaping () -> T?) {
        tryNew(name: "control", candidate: control)
    }

    final public func tryNew(name: String? = nil, candidate: @escaping () -> T?){
        let blockName = name ?? "candidate"
        behaviors[blockName] = candidate
    }
    
    final public func compare(_ compare: @escaping (_ control: ExperimentBlock, _ candidate: ExperimentBlock) -> Bool) {
        comparator = compare
    }

    final public func run(name: String? = nil) -> T? {
        let executedBehavior: String = name ?? "control"
        
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
        
        if let block = behaviors[executedBehavior] {
            return block()
        }
        
        return nil
    }
    
    func publish(result: Result<T>) {}
}
