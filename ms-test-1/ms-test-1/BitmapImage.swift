//
//  BitmapImage.swift
//  ms-test-1
//
//  Created by Matthew on 17.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import UIKit


struct BitmapColor {
    let r: UInt8
    let g: UInt8
    let b: UInt8
}

struct BitmapImage {
    let width: Int
    let height: Int
    let pixels: [UInt8]
    private let bitsPerComponent = 4
    
    func pixel(x: Int, y: Int)-> BitmapColor {
        let startPoint = (y*width + x)*bitsPerComponent
        //print("startPoint=\(startPoint)")
        return BitmapColor(r: pixels[startPoint],
                           g: pixels[startPoint+1],
                           b: pixels[startPoint+2])
    }
}


extension UIImage {
   func toBitmapImage() -> BitmapImage? {
       let size = self.size
       let dataSize = size.width * size.height * 4
       print("Image size \(size.width)x\(size.height) = \(size.width*size.height)")
       var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
       let colorSpace = CGColorSpaceCreateDeviceRGB()
       let context = CGContext(data: &pixelData,
                               width: Int(size.width),
                               height: Int(size.height),
                               bitsPerComponent: 8,
                               bytesPerRow: 4 * Int(size.width),
                               space: colorSpace,
                               bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
       guard let cgImage = self.cgImage else { return nil }
       context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
       return BitmapImage(width: Int(size.width), height: Int(size.height), pixels: pixelData)
   }
}




