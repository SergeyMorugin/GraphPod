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
    public static func execute(for image: UIImage, with threshold: Float, with minSize: Int) -> (UIImage, RootsDictionary) {
        var processedImage: UIImage

        // Get image size
        let height = Int(image.size.height)
        let width = Int(image.size.width)

        // Get inital image bitmap
        let imageBitmap = image.toBitmapImage()

        // Create weighted graph
        var wGraph = imageBitmap!.createWGraph()

        // Sort edges by weight
        wGraph.sortEdges()

       // Create segments
        let pixelsCombinedInSegments = wGraph.createSegmentSets(threshold: threshold, minSize: minSize)

        // Create segments colored bitmap
        let (bitmapImage, roots) = pixelsCombinedInSegments.colorizeBitmap(withWidth: width, andHeight: height)

        // Get image from bitmap
        processedImage = UIImage.fromBitmapImage(bitmapImage: bitmapImage)!
        processedImage.cgImage?.copy(colorSpace: image.cgImage!.colorSpace!)

        return (processedImage, roots)
    }
}
