//
//  SegmentedImageAlgorithm.swift
//  GraphPod
//
//  Created by Ilya Doroshkevitch on 08.06.2021.
//

import Foundation
import UIKit

struct Edge {
    var a: Int = 0
    var b: Int = 0
    var weight: Float = 0
}

final class SegmentingImageAlgorithm {

    // MARK:- Build Graph func
    func segmentImage(_ image: BitmapImage, threshold: Float, minSize: Int) -> (BitmapImage, RootsDictionary, DisjointSet)? {

        var startTime = CFAbsoluteTimeGetCurrent()

        // Get image size
        let height = Int(image.height)
        let width = Int(image.width)
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
                    let weight = diff(image: image, x1: x, y1: y, x2: x + 1, y2: y)
                    let edge = Edge(a: a, b: b, weight: weight)
                    edges.append(edge)
                    numEdges+=1
                }
                if (y < height - 1) {
                    let a = y * width + x
                    let b = (y + 1) * width + x
                    let weight = diff(image: image, x1: x, y1: y, x2: x, y2: y + 1)
                    let edge = Edge(a: a, b: b, weight: weight)
                    edges.append(edge)
                    numEdges+=1

                }
            }
         }
        print("Building graph on \(edges.count) nodes: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        startTime = CFAbsoluteTimeGetCurrent()

        // Sort edges by weight
        let sortedEdges = edges.sorted { $0.weight < $1.weight  }

        print("Sort graph: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        startTime = CFAbsoluteTimeGetCurrent()

        // Array for edges properties init
        let disjointSet = DisjointSet()
        disjointSet.elements = [DisjointSetElement](repeating: DisjointSetElement(rank: 0, parent: 0, size: 1), count: pixelsCount)
        for i in 0..<pixelsCount {
            disjointSet[i].rank = 0
            disjointSet[i].size = 1
            disjointSet[i].parent = i
        }

        // Set thresholds
        var thresholds = [Float](repeating: threshold, count: numEdges)

        // Core sorting over .map
        sortedEdges.forEach {
            var a = disjointSet.rootForElementOn(index: $0.a)
            let b = disjointSet.rootForElementOn(index: $0.b)
            if a != b && $0.weight <= thresholds[a] && $0.weight <= thresholds[b] {
                disjointSet.joinSetsBy(index1: a, index2: b)
                a = disjointSet.rootForElementOn(index: a)
                thresholds[a] = $0.weight + threshold / Float(disjointSet[a].size)
            }
        }
        print("Build sectors: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        startTime = CFAbsoluteTimeGetCurrent()

        // Post process small segments
        edges.forEach {
            let a = disjointSet.rootForElementOn(index: $0.a)
            let b = disjointSet.rootForElementOn(index: $0.b)
            if a != b && ((disjointSet[a].size < minSize) || (disjointSet[b].size < minSize))  {
                disjointSet.joinSetsBy(index1: a, index2: b)
            }
        }
        print("Sectors post processing: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        print("disjointSet.elements.count \(disjointSet.elements.count)")
        startTime = CFAbsoluteTimeGetCurrent()

        // Create colors array for segments according to parent
        var rootsDictionary = RootsDictionary()
        var resultPixels:[UInt8] = []
        for i in 0..<disjointSet.elements.count {
            let rootIndex = disjointSet.rootForElementOn(index: i)

            rootsDictionary.createIfNew(index: rootIndex)
            let root = rootsDictionary.roots[rootIndex]!
            resultPixels.append(root.color.r)
            resultPixels.append(root.color.g)
            resultPixels.append(root.color.b)
            resultPixels.append(root.color.a)
        }
        print("Build result bitmap: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        print("Sectors count: \(rootsDictionary.roots.count)")

        return (BitmapImage(width: width, height: height, pixels: resultPixels), rootsDictionary, disjointSet)

    }

   // MARK: - Dissimilarity measure between pixels
    func diff(image: BitmapImage, x1: Int, y1: Int, x2: Int, y2: Int) -> Float {
        let pixel1 = image.pixel(x: x1, y: y1)
        let pixel2 = image.pixel(x: x2, y: y2)

        let dis = Float(
            (Int(pixel1.r) - Int(pixel2.r))*(Int(pixel1.r) - Int(pixel2.r)) +
            (Int(pixel1.g) - Int(pixel2.g))*(Int(pixel1.g) - Int(pixel2.g)) +
            (Int(pixel1.b) - Int(pixel2.b))*(Int(pixel1.b) - Int(pixel2.b)))

        return sqrt(Float(dis))
    }
}

// MARK: - Extensions

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

// Create new segmented image
extension UIImage {
    convenience init?(pixels: [UIColor], width: Int, height: Int) {
        guard width > 0 && height > 0, pixels.count == width * height else { return nil }
        var data = pixels
        guard let providerRef = CGDataProvider(data: Data(bytes: &data, count: data.count * MemoryLayout<UIColor>.size) as CFData)
            else { return nil }
        guard let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * MemoryLayout<UIColor>.size,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent)
        else { return nil }
        self.init(cgImage: cgim)
    }
}



// Randomize color
extension UIColor {
   static func randomize() -> UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
