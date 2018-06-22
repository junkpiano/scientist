//
//  ScientistTests.swift
//  ScientistTests
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import XCTest
@testable import Scientist

class ScientistTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var result: Bool = false
        let scientist = Scientist<Bool>()
        if let returnValue = scientist.science({
            exp in
            exp.tryNew(candidate: { () -> Bool? in
                return false
            })
            
            exp.use(control: { () -> Bool? in
                return true
            })
            
            print("comparison: \(exp.compare())")
        }) {
            result = returnValue
        }
        
        print(result)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
