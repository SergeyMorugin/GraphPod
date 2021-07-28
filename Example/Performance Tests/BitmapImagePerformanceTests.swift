//
//  BitmapImagePerformanceTests.swift
//  ms-test-1Tests
//
//  Created by Matthew on 29.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import XCTest
import GraphPod


class BitmapImagePerformanceTests: XCTestCase {
    
    func testCreateGraphPerformance() throws {
        let bitmap = BitmapImage(width: 1000, height: 1000, pixels: (0..<1000*1000*4).map({_ in UInt8.random(in: 0..<255) }))
        self.measure {
            let _ = bitmap.createWGraph()
        }
    }
    
    func testDiffPerformance() throws {
        let iterCount = 100_000_000
        let bitmap = BitmapImage(width: iterCount, height: 1, pixels: (0..<iterCount*4).map({_ in UInt8.random(in: 0..<255) }))
        var result = [Float](repeating: 0, count: iterCount)
        self.measure {
            for i in (0..<iterCount) {
                result[i] = bitmap.diff(x1: 0, y1: 0, x2: i, y2: 0)
            }
        }
    }
    
    
    func testCreateEdgeArrayPerformance1() throws {
        let items = 4_000_000
        let bitmap = BitmapImage(width: items, height: 1, pixels: (0..<items*4).map({_ in UInt8.random(in: 0..<255) }))
        var edges: [Edge] = []
        // Calculating pixels colors difference
        self.measure {
            edges = []
            (0..<items-1).forEach { x in
                let a = x
                let b = x + 1
                let weight = bitmap.diff(x1: x, y1: 0, x2: x + 1, y2: 0)
                let edge = Edge(a: a, b: b, weight: weight)
                edges.append(edge)
            }
            
        }
    }
    func testCreateEdgeArrayPerformance2() throws {
        let items = 4_000_000
        let bitmap = BitmapImage(width: items, height: 1, pixels: (0..<items*4).map({_ in UInt8.random(in: 0..<255) }))
        var edges = [Edge](repeating: Edge(a: 0, b: 0, weight: 0), count: items-1)
        // Calculating pixels colors difference
        self.measure {
            (0..<items-1).forEach { x in
                let a = x
                let b = x + 1
                let weight = bitmap.diff(x1: x, y1: 0, x2: x + 1, y2: 0)
                edges[x] = Edge(a: a, b: b, weight: weight)
            }
            
        }
    }
    
    func testCreateEdgeArrayPerformance3() throws {
        let items = 4_000_000
        let bitmap = BitmapImage(width: items, height: 1, pixels: (0..<items*4).map({_ in UInt8.random(in: 0..<255) }))
        var edges = [Edge](repeating: Edge(a: 0, b: 0, weight: 0), count: items-1)
        // Calculating pixels colors difference
        self.measure {
            for x in (0..<items-1){
                let a = x
                let b = x + 1
                let weight = bitmap.diff(x1: x, y1: 0, x2: x + 1, y2: 0)
                edges[x] = Edge(a: a, b: b, weight: weight)
            }
            
        }
    }
    
    
    func testDiffPerformance2() throws {
        let pixels: [UInt8] = [123,31,42,15,234,63,34,34,12,176,15,71,26,93,13,193]
        let bitmap = BitmapImage(width: 2, height: 2, pixels: pixels)
        var result = [Float](repeating: 0, count: 1_000_000)
        self.measure {
            for i in (0..<1_000_000) {
                result[i] = bitmap.diff(x1: 0, y1: 0, x2: 1, y2: 1)
            }
        }
    }
    
    func testConcurrentDiffPerformance1() throws {
        let iterCount = 100_000_000
        let bitmap = BitmapImage(width: iterCount, height: 1, pixels: (0..<iterCount*4).map({_ in UInt8.random(in: 0..<255) }))
        var result = [Float](repeating: 0, count: iterCount)
        self.measure {
            let dispatchGroup = DispatchGroup()
            DispatchQueue.global(qos: .userInitiated).async(group: dispatchGroup) {
                DispatchQueue.concurrentPerform(iterations: iterCount) { i in
                    result[i] = bitmap.diff(x1: 0, y1: 0, x2: i, y2: 0)
                }
            }
            dispatchGroup.wait()
        }
    }
    
    func testConcurrentDiffPerformance2() throws {
        let iterCount = 100_000_000
        let bitmap = BitmapImage(width: iterCount, height: 1, pixels: (0..<iterCount*4).map({_ in UInt8.random(in: 0..<255) }))
        var result = [Float](repeating: 0, count: iterCount)

        self.measure {
            let dispatchGroup = DispatchGroup()
            for i in (0..<2){
                dispatchGroup.enter()
                DispatchQueue.global(qos: .userInteractive).async {
                    for j in (0..<50_000_000) {
                        let pos = i*50_000_000+j
                        result[pos] = bitmap.diff(x1: 0, y1: 0, x2: pos, y2: 0)
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.wait()
        }
    }
}
