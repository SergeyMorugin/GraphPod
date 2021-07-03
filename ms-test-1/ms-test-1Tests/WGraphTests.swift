//
//  WGraphTests.swift
//  ms-test-1Tests
//
//  Created by Matthew on 29.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import XCTest
@testable import ms_test_1

class WGraphTests: XCTestCase {

    func testSorting() throws {
        let edges = [
            Edge(a: 0, b: 1, weight: 2),
            Edge(a: 0, b: 1, weight: 3),
            Edge(a: 0, b: 1, weight: 1),
        ]
        var graph = WGraph(edges: edges, vertexCount: 1)
        graph.sortEdges()
        
        XCTAssertEqual(graph.edges[0].weight, 1)
        XCTAssertEqual(graph.edges[1].weight, 2)
        XCTAssertEqual(graph.edges[2].weight, 3)
    }
    
    func testCreateSegmentSetsForThreshold1() throws {
        let edges = [
            Edge(a: 0, b: 1, weight: 1),
            Edge(a: 0, b: 2, weight: 1),
            Edge(a: 1, b: 3, weight: 3),
            Edge(a: 2, b: 3, weight: 3),
        ]
        var graph = WGraph(edges: edges, vertexCount: 4)
        graph.sortEdges()
        let tree1 = graph.createSegmentSets(threshold: 2, minSize: 0)
        XCTAssertEqual(tree1[0].parent, 1)
        XCTAssertEqual(tree1[1].parent, 1)
        XCTAssertEqual(tree1[2].parent, 1)
        XCTAssertEqual(tree1[3].parent, 3)
        XCTAssertEqual(tree1[0].rank, 0)
        XCTAssertEqual(tree1[1].rank, 1)
        XCTAssertEqual(tree1[2].rank, 0)
        XCTAssertEqual(tree1[3].rank, 0)
        XCTAssertEqual(tree1[0].size, 1)
        XCTAssertEqual(tree1[1].size, 3)
        XCTAssertEqual(tree1[2].size, 1)
        XCTAssertEqual(tree1[3].size, 1)
    }
    
    func testCreateSegmentSetsForThreshold2() throws {
        let edges = [
            Edge(a: 0, b: 1, weight: 1),
            Edge(a: 0, b: 2, weight: 1),
            Edge(a: 1, b: 3, weight: 3),
            Edge(a: 2, b: 3, weight: 3),
        ]
        var graph = WGraph(edges: edges, vertexCount: 4)
        graph.sortEdges()
        
        let tree2 = graph.createSegmentSets(threshold: 0.1, minSize: 0)
        XCTAssertEqual(tree2[0].parent, 0)
        XCTAssertEqual(tree2[1].parent, 1)
        XCTAssertEqual(tree2[2].parent, 2)
        XCTAssertEqual(tree2[3].parent, 3)
        XCTAssertEqual(tree2[0].rank, 0)
        XCTAssertEqual(tree2[1].rank, 0)
        XCTAssertEqual(tree2[2].rank, 0)
        XCTAssertEqual(tree2[3].rank, 0)
        XCTAssertEqual(tree2[0].size, 1)
        XCTAssertEqual(tree2[1].size, 1)
        XCTAssertEqual(tree2[2].size, 1)
        XCTAssertEqual(tree2[3].size, 1)
    }
    
    func testCreateSegmentSetsForThreshold3() throws {
        let edges = [
            Edge(a: 0, b: 1, weight: 1),
            Edge(a: 0, b: 2, weight: 1),
            Edge(a: 1, b: 3, weight: 3),
            Edge(a: 2, b: 3, weight: 3),
        ]
        var graph = WGraph(edges: edges, vertexCount: 4)
        graph.sortEdges()
        
        let tree3 = graph.createSegmentSets(threshold: 4, minSize: 0)
        XCTAssertEqual(tree3[0].parent, 1)
        XCTAssertEqual(tree3[1].parent, 1)
        XCTAssertEqual(tree3[2].parent, 1)
        XCTAssertEqual(tree3[3].parent, 3)
        XCTAssertEqual(tree3[0].rank, 0)
        XCTAssertEqual(tree3[1].rank, 1)
        XCTAssertEqual(tree3[2].rank, 0)
        XCTAssertEqual(tree3[3].rank, 0)
        XCTAssertEqual(tree3[0].size, 1)
        XCTAssertEqual(tree3[1].size, 3)
        XCTAssertEqual(tree3[2].size, 1)
        XCTAssertEqual(tree3[3].size, 1)
    }
    
    func testCreateSegmentSetsForMinSize1() throws {
        let edges = [
            Edge(a: 0, b: 1, weight: 1),
            Edge(a: 0, b: 2, weight: 1),
            Edge(a: 1, b: 3, weight: 3),
            Edge(a: 2, b: 3, weight: 3),
        ]
        var graph = WGraph(edges: edges, vertexCount: 4)
        graph.sortEdges()
        
        let tree4 = graph.createSegmentSets(threshold: 0, minSize: 4)
        XCTAssertEqual(tree4[0].parent, 1)
        XCTAssertEqual(tree4[1].parent, 1)
        XCTAssertEqual(tree4[2].parent, 1)
        XCTAssertEqual(tree4[3].parent, 1)
        XCTAssertEqual(tree4[0].rank, 0)
        XCTAssertEqual(tree4[1].rank, 1)
        XCTAssertEqual(tree4[2].rank, 0)
        XCTAssertEqual(tree4[3].rank, 0)
        XCTAssertEqual(tree4[0].size, 1)
        XCTAssertEqual(tree4[1].size, 4)
        XCTAssertEqual(tree4[2].size, 1)
        XCTAssertEqual(tree4[3].size, 1)
    }

}
