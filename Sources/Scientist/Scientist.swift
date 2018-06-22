//
//  Science.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

class Scientist<T: Equatable> {
    init() {}
    
    public func science(process:(Experiment<T>) -> Void) -> T? {
        return Scientist.experiment { (experiment) in
            process(experiment)
            assert(experiment.completed == true, "experiment.use must be called.")
        }
    }
    
    private static func experiment(process:(Experiment<T>) -> Void) -> T? {
        let experiment = Experiment<T>()
        process(experiment)
        return experiment.before_result
    }
}
