//
//  Result.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/28.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation

struct Result<T: Equatable> {
    var experiment: Experiment<T>
    var control: Observation<T>?
    var observations: [Observation<T>]

    init(experiment: Experiment<T>, observations: [Observation<T>], control: Observation<T>? = nil) {
        self.experiment = experiment
        self.observations = observations
        self.control = control
    }
}
