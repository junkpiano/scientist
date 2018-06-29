//
//  Science.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

class Scientist<T: Equatable> {

    public func science(name: String = "", _ process:(Experiment<T>) -> Void) -> T? {
        return Scientist.run(name: name) { (experiment) in
            experiment.context = default_scientist_context
            process(experiment)
        }
    }
    
    public static func run(name: String = "", _ process:(Experiment<T>) -> Void) -> T? {
        let experiment = Experiment<T>(name: name)
        process(experiment)

        if let result = experiment.run() {
            return result
        } else {
            return nil
        }
    }
    
    public var default_scientist_context: [String: Any] = [:]
}
