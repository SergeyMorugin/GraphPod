//
//  WGraph.swift
//  ms-test-1
//
//  Created by Matthew on 29.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import Foundation

public struct Edge: Equatable {
    var a: Int = 0
    var b: Int = 0
    var weight: Float = 0
    
    public init(a: Int, b: Int, weight: Float){
        self.a = a
        self.b = b
        self.weight = weight
    }
}

public struct WGraph {
    //var edges: [Edge]
    var edges: ContiguousArray<Edge>
    let vertexCount: Int
    private var edgesIsSorted = false
    public init(edges: ContiguousArray<Edge>, vertexCount: Int) {
        self.edges = edges
        self.vertexCount = vertexCount
    }
    
    public mutating func sortEdges()  {
        edges.sort { $0.weight < $1.weight  }
        edgesIsSorted = true
    }
}

public extension WGraph {
    mutating func createSegmentSets(threshold: Float, minSize: Int) -> DisjointSet {

        // Set Disjoint-set array
    
        let startTime = CFAbsoluteTimeGetCurrent()
        let disjointSet = DisjointSet(count: vertexCount)
        //print("DisjointSet init in \(round((CFAbsoluteTimeGetCurrent() - startTime)*1000)/1000)s")

        // Set thresholds array
        var thresholds = ContiguousArray<Float>(repeating: threshold, count: vertexCount)

        // Sort edges by weight
        if !edgesIsSorted {
            sortEdges()
        }

        // Core sorting
        //startTime = CFAbsoluteTimeGetCurrent()
        edges.forEach {
            var a = disjointSet.rootForElementOn(index: $0.a)
            let b = disjointSet.rootForElementOn(index: $0.b)
            if a != b && $0.weight <= thresholds[a] && $0.weight <= thresholds[b] {
                disjointSet.joinSetsBy(index1: a, index2: b)
                a = disjointSet.rootForElementOn(index: a)
                thresholds[a] = $0.weight + threshold / Float(disjointSet[a].size)
            }
        }
        //print("DisjointSet Core sorting in \(round((CFAbsoluteTimeGetCurrent() - startTime)*1000)/1000)s")
        
        // Post process small segments
        //startTime = CFAbsoluteTimeGetCurrent()
        edges.forEach {
            let a = disjointSet.rootForElementOn(index: $0.a)
            let b = disjointSet.rootForElementOn(index: $0.b)
            if a != b && ((disjointSet[a].size < minSize) || (disjointSet[b].size < minSize))  {
                disjointSet.joinSetsBy(index1: a, index2: b)
            }
        }
        //print("DisjointSet Post process in \(round((CFAbsoluteTimeGetCurrent() - startTime)*1000)/1000)s")
        print("DisjointSet.createSegmentSets in \(round((CFAbsoluteTimeGetCurrent() - startTime)*1000)/1000)s for \(threshold)-\(minSize)")
        return disjointSet
    }
}
