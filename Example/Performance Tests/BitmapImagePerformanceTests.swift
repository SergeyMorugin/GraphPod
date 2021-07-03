//
//  BitmapImagePerformanceTests.swift
//  ms-test-1Tests
//
//  Created by Matthew on 29.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import XCTest
@testable import GraphPod


class BitmapImagePerformanceTests: XCTestCase {

    func testCreateGraphPerformance() throws {
        let bitmap = BitmapImage(width: 1000, height: 1000, pixels: Array(repeating: UInt8.random(in: 1..<255), count: 1000*1000*4))
        self.measure {
            let _ = bitmap.createWGraph()
        }
    }
    
    func testDiffPerformance() throws {
        let bitmap = BitmapImage(width: 2, height: 2, pixels: Array(repeating: UInt8.random(in: 1..<255), count: 2*2*4))
        self.measure {
            (1..<1_000_000).forEach { i in
                let _ = bitmap.diff(x1: 0, y1: 0, x2: 1, y2: 1)
            }
        }
    }
}
