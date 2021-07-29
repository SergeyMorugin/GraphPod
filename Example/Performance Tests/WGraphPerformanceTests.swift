//
//  WGraphPerformanceTests.swift
//  ms-test-1Tests
//
//  Created by Matthew on 30.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import XCTest
import GraphPod

class WGraphPerformanceTests: XCTestCase {
    func testPerformanceGraphSort() throws {
        let bitmap = BitmapImage(width: 10000, height: 1000, pixels: (0..<10000*1000*4).map({_ in UInt8.random(in: 0..<255) }))
        var graph = bitmap.createWGraph()
        self.measure {
            graph.sortEdges()
        }
    }
    
    func testPerformanceGraphCreateSegmentSets() throws {
        let bitmap = BitmapImage(width: 10000, height: 1000, pixels: (0..<10000*1000*4).map({_ in UInt8.random(in: 0..<255) }))
        var graph = bitmap.createWGraph()
        graph.sortEdges()
        self.measure {
            let _ = graph.createSegmentSets(threshold: 300, minSize: 300)
        }
    }

}
