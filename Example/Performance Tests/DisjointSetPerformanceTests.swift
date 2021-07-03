//
//  DisjointSetPerformanceTests.swift
//  ms-test-1Tests
//
//  Created by Matthew on 30.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import XCTest
@testable import GraphPod

class DisjointSetPerformanceTests: XCTestCase {

    func testInit() throws {
        self.measure {
            let _ = DisjointSet.init(count: 1000000)
        }
    }
    
    
    func testColorizeBitmap() throws {
        let disjointSet = DisjointSet.init(count: 10000)
        self.measure {
            let _ = disjointSet.colorizeBitmap(withWidth: 100, andHeight: 100)
        }
    }
}
