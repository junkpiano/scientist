//
//  Experiment.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

open class Experiment<T: Equatable>: Experimentable {

    typealias resultType = T
    public typealias ExperimentBlock = () -> T?
    private var behaviors: [String: ExperimentBlock] = [:]
    private var comparator: ((_ control: ExperimentBlock, _ candidate: ExperimentBlock) -> Bool)? = nil
    
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
        
        if let block = behaviors[executedBehavior] {
            return block()
        }
        
        return nil
    }
    
    func publish(result: Result<T>) {}
}
