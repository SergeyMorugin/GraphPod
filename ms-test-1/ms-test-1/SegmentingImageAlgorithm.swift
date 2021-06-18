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




class SegmentingImageAlgorithm {

            // edges array
    var threshold: [Float] = []   // thresholds array
    let c = Float(0.5)            // threshold
    let minSize = 20              // min segment size


    /*// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentImage()
    }*/

    // MARK:- Build Graph func
    func segmentImage(_ image: BitmapImage) -> BitmapImage? {
        //print(image.pixels.count)
        //print(image)
        // Gaussian smoothed image
        //
        var startTime = CFAbsoluteTimeGetCurrent()
        
        
        // Get image size
        let height = Int(image.height)
        let width = Int(image.width)
        let pixelsCount = height*width

        // Number of edges
        var numEdges = 0
        var edges:[Edge] = [] //(repeating: Edge(), count: Int(height*width*4))
        //print("Graph memory alloc: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        // Run through image width and height with 4 neighbor pixels and get edges array - OPTIMIZE NEEDED

        for y in 0..<height {
            for x in 0..<width {
                if (x < width - 1) {
                    let a = y * width + x
                    let b = y * width + (x + 1)
                    let weight = diff(image: image, x1: x, y1: y, x2: x + 1, y2: y)
                    let edge = Edge(a: a, b: b, weight: weight)
                    edges.append(edge)
                    /*edges[numEdges].a = a
                    edges[numEdges].b = b
                    edges[numEdges].weight = weight*/
                    numEdges+=1
                }
                if (y < height - 1) {
                    let a = y * width + x
                    let b = (y + 1) * width + x
                    let weight = diff(image: image, x1: x, y1: y, x2: x, y2: y + 1)
                    let edge = Edge(a: a, b: b, weight: weight)
                    edges.append(edge)
                    /*edges[numEdges].a = a
                    edges[numEdges].b = b
                    edges[numEdges].weight = weight*/
                    numEdges+=1
                    //print(numEdges)
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
        var disjointSet = DisjointSet()
        disjointSet.elements = [DisjointSetElement](repeating: DisjointSetElement(rank: 0, parent: 0, size: 1), count: pixelsCount)
        for i in 0..<pixelsCount {
            disjointSet[i].rank = 0
            disjointSet[i].size = 1
            disjointSet[i].parent = i
        }

        // Set thresholds
         var threshold = [Float](repeating: c, count: numEdges)
         /*for i in 0..<numEdges {
            threshold[i] = c
         }*/

        // Core sorting
        for i in 0..<numEdges {
            let pedge = sortedEdges[i]  // get rebro
            
            var a = disjointSet.rootForElementOn(index: pedge.a)//
            let b = disjointSet.rootForElementOn(index: pedge.b)//
            if ( a != b ) {
                if pedge.weight <= threshold[a] {
                    disjointSet.joinSetsBy(index1: a, index2: b)
                    a = disjointSet.rootForElementOn(index: a)
                    threshold[a] = pedge.weight + c / Float(disjointSet[a].size)
                    //print(elements)
                }
            }
        }
        
        print("Build sectors: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        startTime = CFAbsoluteTimeGetCurrent()
        
        // Post process small segments
        for i in 0..<numEdges {
            let a = disjointSet.rootForElementOn(index: edges[i].a)
            let b = disjointSet.rootForElementOn(index: edges[i].b)
            if a != b && disjointSet[a].size < minSize || disjointSet[b].size < minSize {
                disjointSet.joinSetsBy(index1: a, index2: b)
            }
        }
        
        print("Sectors post processing: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        startTime = CFAbsoluteTimeGetCurrent()


        //var pixels = [UIColor]()
        // Fill pixels array with random colors according to segment parent
        
        print("disjointSet.elements.count \(disjointSet.elements.count)")
        var rootsDictionary = RootsDictionary()
        var resultPixels:[UInt8] = []
        for i in 0..<disjointSet.elements.count {
            let rootIndex = disjointSet.rootForElementOn(index: i)
            
            rootsDictionary.createIfNew(index: rootIndex)
            //pixels.append(rootsDictionary.roots[rootIndex]!.color)
            let root = rootsDictionary.roots[rootIndex]!
            resultPixels.append(root.color.r)
            resultPixels.append(root.color.g)
            resultPixels.append(root.color.b)
            resultPixels.append(root.color.a)
        }
        

        print("Build result bitmap: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        print("Sectors count: \(rootsDictionary.roots.count)")
        // Create segmented image
        /*let segmentedImage = UIImage(pixels: pixels, width: width, height: height)
        
        //print(segmentedImage)
        return segmentedImage*/
        return BitmapImage(width: width, height: height, pixels: resultPixels)

    }



   // MARK: - Dissimilarity measure between pixels
    func diff(image: BitmapImage, x1: Int, y1: Int, x2: Int, y2: Int) -> Float {
        //print("\(x1)-\(y1) \(x2)-\(y2)")
        let pixel1 = image.pixel(x: x1, y: y1)
        let pixel2 = image.pixel(x: x2, y: y2)

        let dis = Float(
            (Int(pixel1.r) - Int(pixel2.r))*(Int(pixel1.r) - Int(pixel2.r)) +
            (Int(pixel1.g) - Int(pixel2.g))*(Int(pixel1.g) - Int(pixel2.g)) +
            (Int(pixel1.b) - Int(pixel2.b))*(Int(pixel1.b) - Int(pixel2.b)))
        //print("dis = \(dis)")
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

