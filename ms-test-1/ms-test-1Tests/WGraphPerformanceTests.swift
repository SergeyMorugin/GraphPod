//
//  WGraphPerformanceTests.swift
//  ms-test-1Tests
//
//  Created by Matthew on 30.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import XCTest
@testable import ms_test_1

class WGraphPerformanceTests: XCTestCase {
    func testPerformanceGraphSort() throws {
        let bitmap = BitmapImage(width: 1000, height: 1000, pixels: Array(repeating: UInt8.random(in: 1..<255), count: 1000*1000*4))
        var graph = bitmap.createWGraph()
        self.measure {
            graph.sortEdges()
        }
    }
    
    func testPerformanceGraphCreateSegmentSets() throws {
        let bitmap = BitmapImage(width: 1000, height: 1000, pixels: Array(repeating: UInt8.random(in: 1..<255), count: 1000*1000*4))
        var graph = bitmap.createWGraph()
        graph.sortEdges()
        self.measure {
            let _ = graph.createSegmentSets(threshold: Float.random(in: 0.1...200.0), minSize: Int.random(in: 0..<200))
        }
    }

}
