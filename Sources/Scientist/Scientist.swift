//
//  Science.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

/**
`Scientist` provides interface to run experiment.
You have to specify return type which is `Equatable`.
 */
public struct Scientist<T: Equatable> {
    var defaultScientistContext: [String: Any]

    public init() {
        self.init(with: nil)
    }

    public init(with context: [String: Any]? = nil) {
        defaultScientistContext = context ?? [:]
	}

    /**
     conduct science.

     - Parameters:
        - name: name of experiment
        - options: options for running experiment
        - process: your experiment process

     - Returns: Generic Type which conforms to Equatable
     */
    public func science(name: String = "", options: [String: Any] = [:], _ process: (Experiment<T>) -> Void) throws -> T {
        return try Scientist.run(name: name, options: options) { (experiment) in
            experiment.context = defaultScientistContext
            process(experiment)
        }
    }

    /**
     run experiment excplicitly.

     - Parameters:
        - name: name of experiment
        - options: options for running experiment
        - process: your experiment process

     - Returns: Generic Type which conforms to Equatable
     */
    public static func run(name: String = "", options: [String: Any] = [:], _ process: (Experiment<T>) -> Void) throws -> T {
        let exp = Experiment<T>(name: name)
        process(exp)

        let runName: String? = options[Constants.runParameter] as? String
        return try exp.run(name: runName)
    }
}
