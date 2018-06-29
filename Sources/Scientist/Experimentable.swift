//
//  Experimentable.swift
//  Scientist
//
//  Created by Yusuke Ohashi on 2018/06/28.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

protocol Experimentable {
    associatedtype resultType: Equatable
    var name: String { get set }
    var enabled: Bool { get set }
    var context: [String: Any] { get set }
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
