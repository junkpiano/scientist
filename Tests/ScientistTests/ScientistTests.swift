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
        // Put setup code here. This method is called before the invocation of each test method in the class.T
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testScience() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        do {
            let returnValue = try Scientist<Bool>().science({ experiment in
                experiment.tryNew(candidate: { () -> Bool in
                    return false
                })

                experiment.use(control: { () -> Bool in
                    return true
                })

                experiment.compare({ (controlValue, candidateValue) -> Bool in
                    return controlValue == candidateValue
                })                
            })
            XCTAssertNotNil(returnValue, "returnValue should not be nil.")
            XCTAssertTrue(returnValue == true)
        } catch {
            print(error)
        }
    }

    func testCompareWithComparator() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        do {
            let returnValue = try Scientist<String>().science(name: "CompareWithNil") { (experiment) in

                experiment.enabled = {return true}
                experiment.publish = {
                    result in
                    XCTAssert(result.mismatches.count == 0)
//                    XCTAssert(result.mismatches[0].value == "")
                }

                XCTAssertTrue(experiment.name == "CompareWithNil")

                experiment.tryNew(candidate: { () -> String in
                    return ""
                })

                experiment.use(control: { () -> String in
                    return "test"
                })

                experiment.compare({ (controlValue, _) -> Bool in
                    return controlValue.starts(with: "te")
                })

            }

            XCTAssertNotNil(returnValue, "returnValue shoudl not be nil.")
            XCTAssertTrue(returnValue == "test")
        } catch {
            print(error)
        }
    }

    func testCustomExperiment() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        do {
            let returnValue = try Scientist<Bool>().science(name: "test") { (experiment) in
                overrideExpParams(experiment: experiment)

                XCTAssertTrue(experiment.name == "test")

                experiment.tryNew(candidate: { () -> Bool in
                    return false
                })

                experiment.use(control: { () -> Bool in
                    return true
                })

                experiment.compare({ (controlValue, candidateValue) -> Bool in
                    return controlValue == candidateValue
                })

            }

            XCTAssertNotNil(returnValue, "returnValue shoudl not be nil.")
            XCTAssertTrue(returnValue == true)
        } catch {
            print(error)
        }
    }

    func overrideExpParams(experiment: Experiment<Bool>) {
        experiment.enabled = {
            // you can randomize experiment.
            // if you return true, it will trigger experiment.
            return Int(arc4random_uniform(6) + 1) % 3 == 0
        }

        experiment.publish = {
            result in
            debugPrint(result.mismatches)
        }
    }
}
