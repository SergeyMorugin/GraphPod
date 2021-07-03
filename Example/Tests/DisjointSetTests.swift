//
//  DisjointSetTests.swift
//  ms-test-1Tests
//
//  Created by Matthew on 30.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import XCTest
@testable import GraphPod

class DisjointSetTests: XCTestCase {

    func testInit() throws {
        let disjointSet = DisjointSet(count: 2)
        
        XCTAssertEqual(disjointSet.elements.count, 2)
        XCTAssertEqual(disjointSet[0].parent, 0)
        XCTAssertEqual(disjointSet[0].rank, 0)
        XCTAssertEqual(disjointSet[0].size, 1)
        XCTAssertEqual(disjointSet[1].parent, 1)
        XCTAssertEqual(disjointSet[1].rank, 0)
        XCTAssertEqual(disjointSet[1].size, 1)
    }
    
    func testJoinSetsBy() throws {
        let disjointSet = DisjointSet(count: 2)
        disjointSet[0].rank = 1
        disjointSet.joinSetsBy(index1: 0, index2: 1)
        
        XCTAssertEqual(disjointSet[0].parent, 0)
        XCTAssertEqual(disjointSet[0].rank, 1)
        XCTAssertEqual(disjointSet[0].size, 2)
        XCTAssertEqual(disjointSet[1].parent, 0)
        XCTAssertEqual(disjointSet[1].rank, 0)
        XCTAssertEqual(disjointSet[1].size, 1)
    }
    
    
    func testrRootForElementOn() throws {
        let disjointSet = DisjointSet(count: 3)
        disjointSet[0].rank = 2
        disjointSet[1].rank = 1
        disjointSet.joinSetsBy(index1: 1, index2: 2)
        disjointSet.joinSetsBy(index1: 0, index2: 1)
        
        XCTAssertEqual(disjointSet.rootForElementOn(index: 2), 0)
        XCTAssertEqual(disjointSet[0].rank, 2)
        XCTAssertEqual(disjointSet[0].size, 3)
    }
    
    func testColorizeBitmap() throws {
        let disjointSet = DisjointSet(count: 4)
        disjointSet.joinSetsBy(index1: 1, index2: 0)
        disjointSet.joinSetsBy(index1: 0, index2: 2)
        disjointSet.joinSetsBy(index1: 0, index2: 3)
        
        let (bitmap, root) = disjointSet.colorizeBitmap(withWidth: 2, andHeight: 2)
        
        XCTAssertEqual(root.roots.count, 1)
        XCTAssertNotNil(root.roots[0])
        XCTAssertEqual(bitmap.width, 2)
        XCTAssertEqual(bitmap.height, 2)
        XCTAssertEqual(bitmap.pixel(x: 0, y: 0), root.roots[0]?.color)
        XCTAssertEqual(bitmap.pixel(x: 1, y: 0), root.roots[0]?.color)
        XCTAssertEqual(bitmap.pixel(x: 0, y: 1), root.roots[0]?.color)
        XCTAssertEqual(bitmap.pixel(x: 1, y: 1), root.roots[0]?.color)
    }

}
