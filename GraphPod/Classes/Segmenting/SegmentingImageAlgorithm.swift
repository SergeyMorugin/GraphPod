//
//  SegmentingImageAlgorithm.swift
//  ms-test-1
//
//  Created by Matthew on 29.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import Foundation

protocol Segmentationable {
    static func execute(image: BitmapImage, threshold: Float, minSize: Int) -> (BitmapImage, RootsDictionary, DisjointSet)?
}

public final class SegmentingImageAlgorithm: Segmentationable {
    
    // MARK: - Main method
    public static func execute(image: BitmapImage, threshold: Float, minSize: Int) -> (BitmapImage, RootsDictionary, DisjointSet)? {
        var wGraph = image.createWGraph()
        wGraph.sortEdges()
        let pixelsCombinedInSegments = wGraph.createSegmentSets(threshold: threshold, minSize: minSize)
        let (bitmapImage, roots) = pixelsCombinedInSegments.colorizeBitmap(withWidth: image.width, andHeight: image.height)
        return (bitmapImage, roots, pixelsCombinedInSegments)
    }
}
