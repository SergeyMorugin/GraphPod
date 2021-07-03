//
//  BitmapColorTest.swift
//  ms-test-1Tests
//
//  Created by Matthew on 29.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import XCTest
@testable import ms_test_1

class BitmapColorTest: XCTestCase {

    func testCreatingRandomColor() throws {
        let color1 = BitmapColor.random()
        XCTAssertNotNil(color1)
        
        let color2 = BitmapColor.random()
        XCTAssertNotEqual([color1.r, color1.g, color1.b, color1.a], [color2.r, color2.g, color2.b, color2.a])
    }

}
