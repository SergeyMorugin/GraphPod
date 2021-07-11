//
//  BitmapImageTests.swift
//  ms-test-1Tests
//
//  Created by Matthew on 29.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import XCTest
@testable import GraphPod

class BitmapImageTests: XCTestCase {


    func testGetPixels() throws {
        let bitmap = BitmapImage(width: 2, height: 2, pixels: Array(0...15))
        XCTAssertEqual(bitmap.pixel(x: 0, y: 0), BitmapColor(r: 0, g: 1, b: 2, a: 3))
        
        XCTAssertEqual(bitmap.pixel(x: 1, y: 1), BitmapColor(r: 12, g: 13, b: 14, a: 15))
        
        XCTAssertNotEqual(bitmap.pixel(x: 0, y: 1), BitmapColor(r: 4, g: 5, b: 6, a: 7))
    }
    
    
    func testDiffBetweenTwoPixelsInRGBSpace() throws {
        let bitmap = BitmapImage(width: 3, height: 1, pixels: [0,0,0,0,1,1,1,1,2,0,0,0])
        XCTAssertEqual(bitmap.diff(x1: 0, y1: 0, x2: 1, y2: 0), sqrt(Float(3)))
        
        XCTAssertEqual(bitmap.diff(x1: 0, y1: 0, x2: 2, y2: 0), 2.0)
    }
    
    func testCreateGraph() throws {
        let bitmap = BitmapImage(width: 4, height: 4, pixels: Array(0..<(16*4)))
        
        let wGraph = bitmap.createWGraph()
        
        XCTAssertEqual(wGraph.vertexCount, 16)
        
        XCTAssertEqual(wGraph.edges.count, 24)
        
        XCTAssertEqual(wGraph.edges[0].a, 0)
        XCTAssertEqual(wGraph.edges[0].b, 1)
        
        XCTAssertEqual(wGraph.edges[1].a, 0)
        XCTAssertEqual(wGraph.edges[1].b, 4)
    }


}
