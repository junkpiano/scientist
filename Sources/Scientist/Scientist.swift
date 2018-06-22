//
//  Science.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

class Scientist<T: Equatable> {
    init() {}
    
    public func science(_ process:(Experiment<T>) -> Void) -> T? {
        return Scientist.process { (experiment) in
            process(experiment)
        }
    }
    
    public var experiment: Experiment<T> {
        return Experiment<T>()
    }
    
    private static func process(process:(Experiment<T>) -> Void) -> T? {
        let experiment = Experiment<T>()
        process(experiment)
        return experiment.final_result
    }
}
