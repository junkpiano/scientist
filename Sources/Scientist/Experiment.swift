//
//  Experiment.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

class Experiment<T: Equatable> {
    var before_result: T?
    var after_result: T?
    var completed: Bool = false
    
    public func use(control: () -> T?) {
        let result = control()
        before_result = result
        completed = true
    }

    public func tryNew(candidate: () -> T?){
        let result = candidate()
        after_result = result
    }
    
    public func compare() -> Bool {
        return before_result == after_result
    }
}
