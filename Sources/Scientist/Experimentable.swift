//
//  Experimentable.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/28.
//

protocol Experimentable {
    associatedtype resultType: Equatable
    var name: String { get }
    var enabled: Bool { get }
    func publish(result: Result<resultType>)
}

extension Experimentable {
    var name: String {
        return ""
    }
    
    var enabled: Bool {
        return false
    }    
}
