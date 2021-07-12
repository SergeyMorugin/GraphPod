//
//  BitmapImage.swift
//  ms-test-1
//
//  Created by Matthew on 17.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//


public struct BitmapColor: Equatable {
    public let r: UInt8
    public let g: UInt8
    public let b: UInt8
    public let a: UInt8
    
    public static func random() -> BitmapColor{
        return BitmapColor(r: UInt8.random(in: 1..<255), g: UInt8.random(in: 1..<255), b: UInt8.random(in: 1..<255), a: 255)
    }
}



public struct BitmapImage: Equatable {
    let width: Int
    let height: Int
    var pixels: [UInt8]
    private let bytesPerComponent = 4
    
    public init(width: Int, height: Int, pixels: [UInt8]) {
        self.width = width
        self.height = height
        self.pixels = pixels
    }
    
    public func pixel(x: Int, y: Int)-> BitmapColor {
        let startPoint = (y*width + x)*bytesPerComponent
        return BitmapColor(r: pixels[startPoint],
                           g: pixels[startPoint+1],
                           b: pixels[startPoint+2],
                           a: pixels[startPoint+3]
        )
    }
}

// MARK: - Extension
public extension BitmapImage {
    func createWGraph() -> WGraph {
        let height = Int(self.height)
        let width = Int(self.width)
        let pixelsCount = height*width

        var edges: [Edge] = []

        // Calculating pixels colors difference
        (0..<height).forEach { y in
            (0..<width).forEach { x in
                if (x < width - 1) {
                    let a = y * width + x
                    let b = y * width + (x + 1)
                    let weight = diff(x1: x, y1: y, x2: x + 1, y2: y)
                    let edge = Edge(a: a, b: b, weight: weight)
                    edges.append(edge)
                }
                if (y < height - 1) {
                    let a = y * width + x
                    let b = (y + 1) * width + x
                    let weight = diff(x1: x, y1: y, x2: x, y2: y + 1)
                    let edge = Edge(a: a, b: b, weight: weight)
                    edges.append(edge)
                }
            }
        }
        return WGraph(edges: edges, vertexCount: pixelsCount)
    }
    
    func diff(x1: Int, y1: Int, x2: Int, y2: Int) -> Float {
        let pixel1 = self.pixel(x: x1, y: y1)
        let pixel2 = self.pixel(x: x2, y: y2)
        let dis = Float(
            squared(divMod(pixel1.r, pixel2.r)) +
            squared(divMod(pixel1.g, pixel2.g)) +
            squared(divMod(pixel1.b, pixel2.b)) )
        
        return sqrt(Float(dis))
    }
    
    private func squared(_ val: Int) -> Int {return val * val}

    private func divMod(_ val1: UInt8, _ val2: UInt8) -> Int {
        if val1 > val2 {
            return Int(val1 - val2)
        } else {
            return Int(val2 - val1)
        }
    }
}

extension BitmapImage {
    
    public func fastGaussBlur(radius: Int) -> BitmapImage {
        var startTime = CFAbsoluteTimeGetCurrent()
        let bxs = boxesForGauss(Float(radius), 3);
        print("boxesForGauss nodes: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        startTime = CFAbsoluteTimeGetCurrent()

        var pR: [UInt8] = [UInt8].init(repeating: 0, count: width*height)
        var pG: [UInt8] = [UInt8].init(repeating: 0, count: width*height)
        var pB: [UInt8] = [UInt8].init(repeating: 0, count: width*height)
        var pA: [UInt8] = [UInt8].init(repeating: 0, count: width*height)
        for i in (0..<(width*height)) {
            let pos = i * bytesPerComponent
            pR[i] = pixels[pos]
            pG[i] = pixels[pos+1]
            pB[i] = pixels[pos+2]
            pA[i] = pixels[pos+3]
        }
        print("copy colors: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        startTime = CFAbsoluteTimeGetCurrent()

        pR = fastGaussBlurByColor(radius, pR, bxs)
        print("fastGaussBlurByColor for R: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        

        pG = fastGaussBlurByColor(radius, pG, bxs)
        pB = fastGaussBlurByColor(radius, pB, bxs)
        print("fastGaussBlurByColor: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        startTime = CFAbsoluteTimeGetCurrent()
        

        var output:[UInt8] = [UInt8].init(repeating: 0, count: width*height*bytesPerComponent)
        for i in (0..<(width*height)) {
            let pos = i * bytesPerComponent
            output[pos] = pR[i]
            output[pos+1] = pG[i]
            output[pos+2] = pB[i]
            output[pos+3] = pA[i]
        }
        
        print("copy outpus \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        startTime = CFAbsoluteTimeGetCurrent()
        
        return BitmapImage(width: width, height: height, pixels: output)
    }
    
    func fastGaussBlurByColor(_ r: Int, _ colorPixels: [UInt8],_ bxs: [Int]) -> [UInt8] {
        var output1 = colorPixels
        var output2 = [UInt8].init(repeating: 0, count: width*height)
        
        boxBlur(&output1, &output2, (bxs[0]-1)/2);
        boxBlur(&output2, &output1, (bxs[1]-1)/2);
        boxBlur(&output1, &output2, (bxs[2]-1)/2);
        return output2
    }

    func boxesForGauss(_ sigma:Float, _ n: Int) -> [Int] {// standard deviation, number of boxes
       let wIdeal = sqrt((12*sigma*sigma/Float(n))+1);  // Ideal averaging filter width
        var wl = Int(floor(wIdeal));
        if (wl%2==0) {
            wl -= 1
        }
        let wu = wl + 2;
                    
        let mIdeal = Float(12*sigma*sigma - Float(n*wl*wl) - 4*Float(n*wl) - 3*Float(n)) / (-4*Float(wl) - 4)
        let m = Int(round(mIdeal))
        // var sigmaActual = Math.sqrt( (m*wl*wl + (n-m)*wu*wu - n)/12 );
                    
        var sizes:[Int] = []
        for i in (0..<n) {//=0; i<n; i++) {
            sizes.append(i<m ? wl : wu)
        }
        print(sizes)
        return sizes;
    }
    

    func boxBlurH(_ scl: [UInt8], _ tcl: inout [UInt8], _ r: Int) {
        let iarr:Float = 1 / (2*Float(r)+1)
        for i in (0..<height) {
            var ti = i * width
            var li = ti
            var ri = ti + r
            let fv = Int(scl[ti])
            let lv = Int(scl[ti+width-1])
            var val: Int = ( r + 1) * fv;
            for j in (0..<r) { val += Int(scl[ti+j]) }
            for _ in (0...r) {
                val += Int(scl[ri]) - fv
                ri += 1
                tcl[ti] = UInt8(round(Float(val)*iarr))
                ti += 1
            }
            for _ in ((r+1)..<(width-r)) {
                val += Int(scl[ri]) - Int(scl[li])
                ri += 1
                li += 1
                tcl[ti] = UInt8(round(Float(val)*iarr))
                ti += 1
            }
            for _ in ((width-r)..<width) {
                val += lv - Int(scl[li])
                li += 1
                tcl[ti] = UInt8(round(Float(val)*iarr))
                ti += 1
            }
        }
    }
    
    func boxBlurT(_ scl: [UInt8], _ tcl: inout [UInt8], _ r: Int) {
        let iarr: Float = 1 / (2*Float(r)+1)
        for i in (0..<width) {
            var ti = i
            var li = ti
            var ri = ti + r*width;
            let fv = Int(scl[ti])
            let lv = Int(scl[ti+width*(height-1)])
            var val = (r+1)*fv;
            for j in (0..<r) {
                val += Int(scl[ti+j*width])
            }
            for _ in (0...r) {
                val += Int(scl[ri]) - fv
                tcl[ti] = UInt8(round(Float(val)*iarr))
                ri += width
                ti += width
            }
            for _ in ((r+1)..<(height-r)) {
                val += Int(scl[ri]) - Int(scl[li])
                tcl[ti] = UInt8(round(Float(val)*iarr))
                li += width
                ri += width
                ti += width
            }
            for _ in ((height-r)..<(height)) {
                val += lv - Int(scl[li])
                tcl[ti] = UInt8(round(Float(val)*iarr))
                li += width
                ti += width
            }
        }
    }
    
    
    func boxBlur(_ scl: inout [UInt8], _ tcl: inout [UInt8], _ r: Int) {
        tcl = scl
        boxBlurH(tcl, &scl, r);
        boxBlurT(scl, &tcl, r);
    }
    
}

#if canImport(UIKit)

import UIKit

extension UIImage {
    public func toBitmapImage() -> BitmapImage? {
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

    public func convertToGrayScaleBitmap(image: UIImage) -> BitmapImage? {

        // Create image rectangle with current image width/height
        let imageRect:CGRect = CGRect(x:0, y:0, width:image.size.width, height: image.size.height)

        let size = self.size
        let dataSize = size.width * size.height

        // Grayscale color space
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = image.size.width
        let height = image.size.height

        // Create bitmap content with current image size and grayscale colorspace
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))

        // Draw image into current context, with specified rectangle
        // using previously defined context (with grayscale colorspace)
        let context = CGContext(data: &pixelData, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(image.cgImage!, in: imageRect)

        return BitmapImage(width: Int(size.width), height: Int(size.height), pixels: pixelData)
    }
    
    public static func fromBitmapImage(bitmapImage: BitmapImage)-> UIImage? {
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
#endif




