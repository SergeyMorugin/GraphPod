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
        let pixels: [UInt8] = [123,31,42,15,234,63,34,34,12,176,15,71,26,93,13,193]
        let bitmap = BitmapImage(width: 2, height: 2, pixels: pixels)
        var result = [Float](repeating: 0, count: 1_000_000)
        self.measure {
            (0..<1_000_000).forEach { i in
                result[i] = bitmap.diff(x1: 0, y1: 0, x2: 1, y2: 1)
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
        let pixels: [UInt8] = [123,31,42,15,234,63,34,34,12,176,15,71,26,93,13,193]
        let bitmap = BitmapImage(width: 2, height: 2, pixels: pixels)
        self.measure {
            let dispatchGroup = DispatchGroup()
            DispatchQueue.global(qos: .userInitiated).async(group: dispatchGroup) {
                DispatchQueue.concurrentPerform(iterations: 1_000_000) { idx in
                    let _ = bitmap.diff(x1: 0, y1: 0, x2: 1, y2: 1)
        
                }
            }
            dispatchGroup.wait()
        }
    }
    
    func testConcurrentDiffPerformance2() throws {
        let pixels: [UInt8] = [123,31,42,15,234,63,34,34,12,176,15,71,26,93,13,193]
        let bitmap = BitmapImage(width: 2, height: 2, pixels: pixels)
        
        
        self.measure {
            var result = [Float](repeating: 0, count: 1_000_000)
            let dispatchGroup = DispatchGroup()
            (0..<10).forEach { i in
                dispatchGroup.enter()
                DispatchQueue.global(qos: .userInteractive).async {
                    (0..<100_000).forEach { j in
                        let _ = bitmap.diff(x1: 0, y1: 0, x2: 1, y2: 1)
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.wait()
        }
    }
    
    
    

    
}
