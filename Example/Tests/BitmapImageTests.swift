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
    
    func testCalcResultEdgesAmount() throws {
        var bitmap = BitmapImage(width: 3, height: 3, pixels: [])
        XCTAssertEqual(bitmap.calcResultEdgesAmount(),12)
        
        bitmap = BitmapImage(width: 4, height: 4, pixels: [])
        XCTAssertEqual(bitmap.calcResultEdgesAmount(), 24)
    }
    
    func testTwoPixelPoints() throws {
        let bitmap = BitmapImage(width: 3, height: 3, pixels: [])
        let result1 = bitmap.twoPixelPoints(byWGrathIndex: 0)
        XCTAssertEqual(result1.0.x, 0)
        XCTAssertEqual(result1.0.y, 0)
        XCTAssertEqual(result1.1.x, 1)
        XCTAssertEqual(result1.1.y, 0)
        
        let result2 = bitmap.twoPixelPoints(byWGrathIndex: 5)
        XCTAssertEqual(result2.0.x, 1)
        XCTAssertEqual(result2.0.y, 2)
        XCTAssertEqual(result2.1.x, 2)
        XCTAssertEqual(result2.1.y, 2)
        
        let result3 = bitmap.twoPixelPoints(byWGrathIndex: 6)
        XCTAssertEqual(result3.0.x, 0)
        XCTAssertEqual(result3.0.y, 0)
        XCTAssertEqual(result3.1.x, 0)
        XCTAssertEqual(result3.1.y, 1)
        
        let result4 = bitmap.twoPixelPoints(byWGrathIndex: 11)
        XCTAssertEqual(result4.0.x, 2)
        XCTAssertEqual(result4.0.y, 1)
        XCTAssertEqual(result4.1.x, 2)
        XCTAssertEqual(result4.1.y, 2)
        
    }


}
