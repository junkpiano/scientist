//
//  Science.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

class Scientist<T: Equatable> {

    public var experiment: Experiment<T> = Experiment<T>()

    init(experiment: Experiment<T>? = nil) {
        if let _exp = experiment {
            self.experiment = _exp
        }
    }
    
    public func science(_ process:(Experiment<T>) -> Void) -> T? {
        return Scientist.process { (experiment) in
            process(experiment)
        }
    }
    
    private static func process(process:(Experiment<T>) -> Void) -> T? {
        let experiment = Experiment<T>()
        process(experiment)

        if let result = experiment.run() {
            return result
        } else {
            return nil
        }
    }
}
