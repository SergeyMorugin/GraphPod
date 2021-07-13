//
//  Extension BitmapImage.swift
//  GraphPod
//
//  Created by Ilya Doroshkevitch on 12.07.2021.
//

import Foundation

// MARK: - Create grayscale Bitmap
public extension BitmapImage {
    func toGrayScaleBitmap() -> BitmapImage? {

        var output:[UInt8] = []

        (0..<(width*height)).forEach { i in
            let position = i * bytesPerComponent

            let r = UInt16(pixels[position])
            let g = UInt16(pixels[position+1])
            let b = UInt16(pixels[position+2])
            //var pA = pixels[position+3]

            let grayScalePixel: UInt16 = UInt16((r + g + b) / 3)
            output.append(UInt8(grayScalePixel))
        }

        return BitmapImage(width: width, height: height, pixels: output)
    }
}
