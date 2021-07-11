//
//  SegmentingImageAlgorithm.swift
//  ms-test-1
//
//  Created by Matthew on 29.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import Foundation

public final class SegmentingImageAlgorithm {
    
    // MARK: - Main method
    public static func execute(image: BitmapImage, threshold: Float, minSize: Int) -> (BitmapImage, RootsDictionary, DisjointSet)? {
        var wGrath = image.createWGraph()
        wGrath.sortEdges()
        let pixelsCombinedInSegments = wGrath.createSegmentSets(threshold: threshold, minSize: minSize)
        let (bitmapImage, roots) = pixelsCombinedInSegments.colorizeBitmap(withWidth: image.width, andHeight: image.height)
        return (bitmapImage, roots, pixelsCombinedInSegments)
    }
}
