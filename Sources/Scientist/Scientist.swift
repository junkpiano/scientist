//
//  Science.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

public struct Scientist<T: Equatable> {

    public func science(name: String = "", options: [String: Any] = [:], _ process: (Experiment<T>) -> Void) -> T? {
        return Scientist.run(name: name) { (experiment) in
            experiment.context = defaultScientistContext
            process(experiment)
        }
    }

    public static func run(name: String = "", options: [String: Any] = [:], _ process: (Experiment<T>) -> Void) -> T? {
        let exp = Experiment<T>(name: name)
        process(exp)

        let runName: String? = options[Constants.runParameter] as? String
        if let result = exp.run(name: runName) {
            return result
        } else {
            return nil
        }
    }

    public var defaultScientistContext: [String: Any] = [:]
}
