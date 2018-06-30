//
//  Observation.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/29.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import Foundation

public struct Observation<T: Equatable> {
    var now: Date
    var experiment: Experiment<T>
    var name: String
    var value: T
    var during: Int?

    init(name: String, experiment: Experiment<T>, block: Experiment<T>.ExperimentBlock) {
        self.name = name
        self.experiment = experiment
        now = Date()
        value = block()
        during = Calendar.current.dateComponents([.nanosecond], from: now, to: Date()).nanosecond
    }

    func equivalentTo(other: Observation<T>, comparator: Experiment<T>.ComparatorBlock?) -> Bool {
        if let comparator = comparator {
            return comparator(value, other.value)
        } else {
            return value == other.value
        }
    }

}

func -<T: Equatable> (left: [Observation<T>], right: Observation<T>?) -> [Observation<T>] {
    return left.filter {
        guard let right = right else {
            return true
        }

        return $0.name != right.name
    }
}

func -<T: Equatable> (left: [Observation<T>], right: [Observation<T>]) -> [Observation<T>] {
    var result = left
    right.forEach { (obv) in
        result = result - obv
    }
    return result
}
