//
//  TimeIntervalExtTests.swift
//  TimeIntervalExtTests
//
//  Created by Pascal Braband on 23.03.20.
//  Copyright © 2020 Pascal Braband. All rights reserved.
//

import XCTest
@testable import Slidejar

class TimeIntervalExtTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFormat() {
        let minute: TimeInterval = 60.0
        let hour: TimeInterval = 3600.0
        let some: TimeInterval = 3984.0
        
        XCTAssertEqual(minute.format(), "00:01:00")
        XCTAssertEqual(hour.format(), "01:00:00")
        XCTAssertEqual(some.format(), "01:06:24")
        
        let minuteNeg = -minute
        let hourNeg = -hour
        let someNeg = -some
        
        XCTAssertEqual(minuteNeg.format(), "- 00:01:00")
        XCTAssertEqual(hourNeg.format(), "- 01:00:00")
        XCTAssertEqual(someNeg.format(), "- 01:06:24")
    }

}
