//
//  RootsDictionaryTests.swift
//  ms-test-1Tests
//
//  Created by Matthew on 29.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import XCTest
@testable import GraphPod

class RootsDictionaryTests: XCTestCase {

    func testCreationNewObject() throws {
        let roots = RootsDictionary()
        XCTAssertEqual(roots.roots.count, 0)
    }
    
    func testAddingNewRoots() throws {
        var roots = RootsDictionary()
        roots.createIfNew(index: 1)
        XCTAssertEqual(roots.roots.count, 1)
        
        XCTAssertNotNil(roots.roots[1])
        XCTAssertNil(roots.roots[2])
        
        roots.createIfNew(index: 1)
        XCTAssertEqual(roots.roots.count, 1)
        
        roots.createIfNew(index: 2)
        XCTAssertEqual(roots.roots.count, 2)
    }
}
