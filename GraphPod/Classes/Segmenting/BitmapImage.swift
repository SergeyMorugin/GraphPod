//
//  BitmapImage.swift
//  ms-test-1
//
//  Created by Matthew on 17.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

public struct PixelPoint {
    let x: Int
    let y: Int
}

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
    public let width: Int
    public let height: Int
    public var pixels: [UInt8]
    let bytesPerComponent = 4
    
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
    
    func createWGraph2() -> WGraph {
        let height = Int(self.height)
        let width = Int(self.width)
        let pixelsCount = height*width
        let edgesCount = calcResultEdgesAmount()
        var edges = [Edge](repeating: Edge(a: 0, b: 0, weight: 0), count: edgesCount)

        // Calculating pixels colors difference
        
        (0..<edgesCount).forEach { i in
            let points = twoPixelPoints(byWGrathIndex: i)
            let weight = diff(x1: points.0.x, y1: points.0.y, x2: points.1.x, y2: points.1.y)
            edges[i] = Edge(a: toIndex(byPoint: points.0), b: toIndex(byPoint: points.1), weight: weight)
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
    
    func calcResultEdgesAmount() -> Int {
        return (width-1)*height+(height-1)*width
    }
    
    func twoPixelPoints(byWGrathIndex index: Int) -> (PixelPoint, PixelPoint) {
        var x1 = 0
        var x2 = 0
        var y1 = 0
        var y2 = 0
        
        if (index < ((width-1)*height)){
            y1 = index / (width-1)
            y2 = y1
            x1 = index % (width-1)
            x2 = x1 + 1
        } else {
            let index2 = index - (width-1)*height
            x1 = index2 / (height-1)
            x2 = x1
            y1 = index % (height-1)
            y2 = y1 + 1
        }
        return (PixelPoint(x: x1, y: y1), PixelPoint(x: x2, y: y2))
    }
    
    func toIndex(byPoint: PixelPoint) -> Int {
        return byPoint.y * width + byPoint.x
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
