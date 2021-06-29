//
//  BitmapImage.swift
//  ms-test-1
//
//  Created by Matthew on 17.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//


struct BitmapColor {
    let r: UInt8
    let g: UInt8
    let b: UInt8
    let a: UInt8
    
    static func random() -> BitmapColor{
        return BitmapColor(r: UInt8.random(in: 1..<255), g: UInt8.random(in: 1..<255), b: UInt8.random(in: 1..<255), a: 255)
    }
}

struct BitmapImage: Equatable {
    let width: Int
    let height: Int
    var pixels: [UInt8]
    private let bytesPerComponent = 4
    
    func pixel(x: Int, y: Int)-> BitmapColor {
        let startPoint = (y*width + x)*bytesPerComponent
        return BitmapColor(r: pixels[startPoint],
                           g: pixels[startPoint+1],
                           b: pixels[startPoint+2],
                           a: pixels[startPoint+3]
        )
    }
}


extension BitmapImage {
    func createWGraph() -> WGraph {
        let height = Int(self.height)
        let width = Int(self.width)
        let pixelsCount = height*width
        // Number of edges
        var numEdges = 0
        var edges:[Edge] = []
        
        // Run through image width and height with 4 neighbor pixels and get edges array - OPTIMIZE NEEDED
        //
        (0..<height).forEach { y in
            (0..<width).forEach { x in
                if (x < width - 1) {
                    let a = y * width + x
                    let b = y * width + (x + 1)
                    let weight = diff(x1: x, y1: y, x2: x + 1, y2: y)
                    let edge = Edge(a: a, b: b, weight: weight)
                    edges.append(edge)
                    numEdges+=1
                }
                if (y < height - 1) {
                    let a = y * width + x
                    let b = (y + 1) * width + x
                    let weight = diff(x1: x, y1: y, x2: x, y2: y + 1)
                    let edge = Edge(a: a, b: b, weight: weight)
                    edges.append(edge)
                    numEdges+=1
                    
                }
            }
        }
        return WGraph(edges: edges, vertexCount: pixelsCount)
    }
    
    func diff(x1: Int, y1: Int, x2: Int, y2: Int) -> Float {
        let pixel1 = self.pixel(x: x1, y: y1)
        let pixel2 = self.pixel(x: x2, y: y2)
        
        let dis = Float(
            (Int(pixel1.r) - Int(pixel2.r))*(Int(pixel1.r) - Int(pixel2.r)) +
                (Int(pixel1.g) - Int(pixel2.g))*(Int(pixel1.g) - Int(pixel2.g)) +
                (Int(pixel1.b) - Int(pixel2.b))*(Int(pixel1.b) - Int(pixel2.b)))
        
        return sqrt(Float(dis))
    }
}


import UIKit

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
    
    static func fromBitmapImage(bitmapImage: BitmapImage)-> UIImage? {
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

extension UIImage {
    
    // MARK: - Gaussian blur
    func gaussian(image: UIImage, sigma: Double) -> UIImage? {
        if let img = CIImage(image: image) {
            if #available(iOS 10.0, *) {
                return UIImage(ciImage: img.applyingGaussianBlur(sigma: sigma))
            } else {
                // Fallback on earlier versions
            }
        }
        return nil
    }
    
    // MARK: - Smooth the image
    func smoothing( sigma: Double) -> UIImage? {
        guard let imageGaussianed = gaussian(image: self, sigma: sigma) else { return nil}
        
        // Convert gaussianed image to png for resize and further processing
        guard let imageToCrop = UIImage(data: imageGaussianed.pngData()!) else { return nil}
        
        // Resize gaussianed image png to initial image size
        let initialSize = CGSize(width: self.size.width, height: self.size.height)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        UIGraphicsBeginImageContextWithOptions(initialSize, false, 1.0)
        imageToCrop.draw(in: rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil}
        UIGraphicsEndImageContext()
        
        return image
    }
}




