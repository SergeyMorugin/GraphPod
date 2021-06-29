//
//  WGraph.swift
//  ms-test-1
//
//  Created by Matthew on 29.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import Foundation

struct Edge {
    var a: Int = 0
    var b: Int = 0
    var weight: Float = 0
}

struct WGraph {
    var edges: [Edge]
    let vertexCount: Int
    private var edgesIsSorted = false
    init(edges: [Edge], vertexCount: Int) {
        self.edges = edges
        self.vertexCount = vertexCount
    }
    
    mutating func sortEdges()  {
        edges = edges.sorted { $0.weight < $1.weight  }
        edgesIsSorted = true
    }
}


extension WGraph {
    mutating func createSegmentSets(threshold: Float, minSize: Int) -> DisjointSet {
        let disjointSet = DisjointSet(count: vertexCount)
        // Set thresholds
        var thresholds = [Float](repeating: threshold, count: vertexCount)
        if !edgesIsSorted {
            sortEdges()
        }
        // Core sorting over .map
        edges.forEach {
            var a = disjointSet.rootForElementOn(index: $0.a)
            let b = disjointSet.rootForElementOn(index: $0.b)
            if a != b && $0.weight <= thresholds[a] && $0.weight <= thresholds[b] {
                disjointSet.joinSetsBy(index1: a, index2: b)
                a = disjointSet.rootForElementOn(index: a)
                thresholds[a] = $0.weight + threshold / Float(disjointSet[a].size)
            }
        }
        
        // Post process small segments
        edges.forEach {
            let a = disjointSet.rootForElementOn(index: $0.a)
            let b = disjointSet.rootForElementOn(index: $0.b)
            if a != b && ((disjointSet[a].size < minSize) || (disjointSet[b].size < minSize))  {
                disjointSet.joinSetsBy(index1: a, index2: b)
            }
        }
        return disjointSet
    }
}
