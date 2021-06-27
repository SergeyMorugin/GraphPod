//
//  ViewController.swift
//  GraphPod
//
//  Created by Ilya Doroshkevitch on 10.06.2021.
//

import UIKit

struct Edge {

    var a: Int
    var b: Int
    var weight: Float

}

class ImageToGraph: UIViewController {

    var edges: [Edge] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        buildGraph()
    }

    
    // MARK:- Написать функцию превращающая изображение в граф расстояний между цветами пикселей
    func buildGraph() {

        // Get image
        guard let image = UIImage(named:"test2") else { return }

        // Get image size
        let height = Int(image.size.height)
        let width = Int(image.size.width)
        var num = 0

        // Run through image width and height with 4 neighbor pixels and get edges array
        for y in 1...height {
            for x in 1...width {
                if (x < width - 1) {
                    let a = y * width + x
                    let b = y * width + (x + 1)
                    let weight = diff(image: image, x1: x, y1: y, x2: x + 1, y2: y)
                    let edge = Edge(a: a, b: b, weight: weight)
                    edges.append(edge)
                    num+=1
                }
                if (y < height - 1) {
                    let a = y * width + x
                    let b = (y + 1) * width + x
                    let weight = diff(image: image, x1: x, y1: y, x2: x, y2: y + 1)
                    let edge = Edge(a: a, b: b, weight: weight)
                    edges.append(edge)
                    num+=1

                }
                if ((x < width - 1) && (y < height - 1)) {
                    let a = y * width + x
                    let b = (y + 1) * width + (x + 1)
                    let weight = diff(image: image, x1: x, y1: y, x2: x + 1, y2: y + 1)
                    let edge = Edge(a: a, b: b, weight: weight)
                    edges.append(edge)
                    num+=1
                }
                if ((x < width - 1) && (y > 0)) {
                    let a = y * width + x
                    let b = (y - 1) * width + (x + 1)
                    let weight = diff(image: image, x1: x, y1: y, x2: x + 1, y2: y - 1)
                    let edge = Edge(a: a, b: b, weight: weight)
                    edges.append(edge)
                    num+=1
                }
            }
        }
        print(edges)

    }

    // Dissimilarity measure between pixels
    func diff(image: UIImage, x1: Int, y1: Int, x2: Int, y2: Int) -> Float {

        let r1 = image.getPixelColor(rgb: "r", position: CGPoint(x: x1, y: y1))
        let r2 = image.getPixelColor(rgb: "r", position: CGPoint(x: x2, y: y2))

        let g1 = image.getPixelColor(rgb: "g", position: CGPoint(x: x1, y: y1))
        let g2 = image.getPixelColor(rgb: "g", position: CGPoint(x: x2, y: y2))

        let b1 = image.getPixelColor(rgb: "b", position: CGPoint(x: x1, y: y1))
        let b2 = image.getPixelColor(rgb: "b", position: CGPoint(x: x2, y: y2))

        return sqrtf(Float(  ((r1 - r2)*(r1 - r2)) + ((g1 - g2)*(g1 - g2)) + ((b1 - b2)*(b1 - b2))))
    }

}


extension UIImage {

    // Get one pixel colo
    func getPixelColor(rgb: String, position: CGPoint) -> CGFloat {
        var colorChannel = CGFloat()

        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pixelInfo: Int = ((Int(self.size.width) * Int(position.y)) + Int(position.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        //let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

        switch rgb {
        case "r":
            colorChannel = r
        case "g":
            colorChannel = g
        case "b":
            colorChannel = b
        default:
            break
        }

        return colorChannel
    }
}

