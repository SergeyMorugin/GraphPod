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
    let a: UInt8
    
    static func random() -> BitmapColor{
        return BitmapColor(r: UInt8.random(in: 1..<255), g: UInt8.random(in: 1..<255), b: UInt8.random(in: 1..<255), a: 255)
    }
}

struct BitmapImage {
    let width: Int
    let height: Int
    var pixels: [UInt8]
    private let bitsPerComponent = 4
    
    func pixel(x: Int, y: Int)-> BitmapColor {
        let startPoint = (y*width + x)*bitsPerComponent
        //print("startPoint=\(startPoint)")
        return BitmapColor(r: pixels[startPoint],
                           g: pixels[startPoint+1],
                           b: pixels[startPoint+2],
                           a: pixels[startPoint+3]
        )
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
    
    //func fromBitmapImage(image: BitmapImage) {

    
    func fromBitmapImage1(bitmapImage: BitmapImage)-> UIImage?//(fromPixelValues pixelValues: [UInt8]?, width: Int, height: Int) -> UIImage?
    {
        var imageRef: CGImage?
        var pixelValues = bitmapImage.pixels
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * bitmapImage.width
        let totalBytes = bitmapImage.height * bytesPerRow

        imageRef = withUnsafePointer(to: &pixelValues, {
            ptr -> CGImage? in
            var imageRef: CGImage?
            let colorSpaceRef = CGColorSpaceCreateDeviceRGB() //CGColorSpaceCreateDeviceGray()
            
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).union(CGBitmapInfo())
            //print(CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).union(CGBitmapInfo()).rawValue)
            //let bitmapInfo = self.cgImage!.bitmapInfo//CGBitmapInfo(rawValue: 8194)
            let data = UnsafeRawPointer(ptr.pointee).assumingMemoryBound(to: UInt8.self)
            let releaseData: CGDataProviderReleaseDataCallback = {
                (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
            }

            if let providerRef = CGDataProvider(dataInfo: nil, data: data, size: totalBytes, releaseData: releaseData) {
                imageRef = CGImage(width: bitmapImage.width,
                                   height: bitmapImage.height,
                                   bitsPerComponent: bitsPerComponent,
                                   bitsPerPixel: bitsPerPixel,
                                   bytesPerRow: bytesPerRow,
                                   space: colorSpaceRef,
                                   bitmapInfo: bitmapInfo,
                                   provider: providerRef,
                                   decode: nil,
                                   shouldInterpolate: false,
                                   intent: CGColorRenderingIntent.defaultIntent)
            }

            return imageRef
        })
        
        if let rawImage = imageRef {
            return UIImage(cgImage: rawImage)
        }
        return nil
    }
    
    func fromBitmapImage(bitmapImage: BitmapImage)-> UIImage? {
        //var srgbArray = [UInt32](repeating: 0xFF204080, count: 8*8)
        var pixels = bitmapImage.pixels
        let cgImg = pixels.withUnsafeMutableBytes { (ptr) -> CGImage in
            let ctx = CGContext(
                data: ptr.baseAddress,
                width: bitmapImage.width,
                height: bitmapImage.height,
                bitsPerComponent: 8,
                bytesPerRow: bitmapImage.width*4,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue +
                    CGImageAlphaInfo.premultipliedFirst.rawValue
                )!
            return ctx.makeImage()!
        }
        return UIImage(cgImage: cgImg)
    }
    
}




