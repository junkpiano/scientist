//
//  Observation.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/29.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation

struct Observation<T: Equatable> {
    var now: Date
    var experiment: Experiment<T>
    var name: String
    var value: T?
    var during: Int?

    init(name: String, experiment: Experiment<T>, block: Experiment<T>.ExperimentBlock) {
        self.name = name
        self.experiment = experiment
        now = Date()
        value = block()
        during = Calendar.current.dateComponents([.nanosecond], from: now, to: Date()).nanosecond
    }
}
