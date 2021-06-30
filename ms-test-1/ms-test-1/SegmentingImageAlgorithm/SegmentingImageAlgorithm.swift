//
//  SegmentingImageAlgorithm.swift
//  ms-test-1
//
//  Created by Matthew on 29.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import Foundation


final class SegmentingImageAlgorithm {
    static func execute(image: BitmapImage, threshold: Float, minSize: Int) -> (BitmapImage, RootsDictionary, DisjointSet)? {
        var startTime = CFAbsoluteTimeGetCurrent()

        // Get image size
        let height = Int(image.height)
        let width = Int(image.width)

        var wGraph = image.createWGraph()
        
        print("Building graph on \(wGraph.edges.count) nodes: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        startTime = CFAbsoluteTimeGetCurrent()

        // Sort edges by weight
        wGraph.sortEdges()

        print("Sort graph: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        startTime = CFAbsoluteTimeGetCurrent()

        //
        let pixelsCombinedInSegments = wGraph.createSegmentSets(threshold: threshold, minSize: minSize)
        

        print("Build segments: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        print("disjointSet.elements.count \(pixelsCombinedInSegments.elements.count)")
        startTime = CFAbsoluteTimeGetCurrent()
        

        let (bitmapImage, roots) = pixelsCombinedInSegments.colorizeBitmap(withWidth: width, andHeight: height)
        print("Build result bitmap: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        print("Sectors count: \(roots.roots.count)")

        return (bitmapImage, roots, pixelsCombinedInSegments)

    }
}
