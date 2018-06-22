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
    var final_result: T?
    
    public func run() -> T? {
        final_result = before_result
        return final_result
    }

    public func use(control: () -> T?) {
        let result = control()
        before_result = result
        final_result = result
    }

    public func tryNew(candidate: () -> T?){
        let result = candidate()
        after_result = result
    }
    
    public func compare() -> Bool {
        return before_result == after_result
    }
}
