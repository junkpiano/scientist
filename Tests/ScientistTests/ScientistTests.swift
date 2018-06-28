//
//  ScientistTests.swift
//  ScientistTests
//
//  Created by Yusuke Ohashi on 2018/06/22.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import XCTest
@testable import Scientist

class MyExp<T: Equatable>: Experiment<T> {
    var name: String = "test"
    var enabled: Bool = true
    override func publish(result: Result<T>) {}
}

class ScientistTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.T
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testScience() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let returnValue = Scientist<Bool>().science({
            experiment in
            experiment.tryNew(candidate: { () -> Bool? in
                return false
            })
            
            experiment.use(control: { () -> Bool? in
                return true
            })
            
            experiment.compare({ (control, candidate) -> Bool in
                return control() == candidate()
            })
        })
        XCTAssertNotNil(returnValue, "returnValue shoudl not be nil.")
        XCTAssertTrue(returnValue == true)
    }
    
    func testExperiment() {
        let experiment = Scientist<Bool>().experiment
        experiment.use { () -> Bool? in
            return true
        }
        experiment.tryNew { () -> Bool? in
            return false
        }
        
        experiment.compare { (control, candidate) -> Bool in
            return control() == candidate()
        }
        
        XCTAssertTrue(experiment.run()!)
    }
}
