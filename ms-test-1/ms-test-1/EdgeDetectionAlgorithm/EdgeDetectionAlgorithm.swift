//
//  EdgeDetectionAlgorithm.swift
//  GraphPod
//
//  Created by Ilya Doroshkevitch on 22.06.2021.
//

import Foundation
import UIKit


final class EdgeDetectionAlgorithm {

    // 1 - convert colored image to grayscale - OK

    // 2 - Gaussian smooth image - OK

    // 3 - Convert image to pixels grayscale matrix - OK
    class func pixelValuesFromGrayScaleImage(imageRef: CGImage?) -> ([UInt8]?)
    {
        var width = 0
        var height = 0
        var pixelValues: [UInt8]?
        if let imageRef = imageRef {
            let totalBytes = imageRef.width * imageRef.height
            let colorSpace = CGColorSpaceCreateDeviceGray()

            pixelValues = [UInt8](repeating: 0, count: totalBytes)
            pixelValues?.withUnsafeMutableBytes({
                width = imageRef.width
                height = imageRef.height
                let contextRef = CGContext(data: $0.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width, space: colorSpace, bitmapInfo: 0)
                let drawRect = CGRect(x: 0.0, y:0.0, width: CGFloat(width), height: CGFloat(height))
                contextRef?.draw(imageRef, in: drawRect)
            })
        }
        return pixelValues
    }

    // 4 - Sobel X and Sobel Y
    class func operate(pixelValues: [UInt8], height: Int, width: Int ) -> [UInt8] {

        var edge: [UInt8] = []
        var edgeDirection: [Float] = []

//======================================Sobel operator====================================
// Uncomment below to try

        let kernelX = [[-1, 0, 1],
                       [-2, 0, 2],
                       [-1, 0, 1]]

        let kernelY = [[-1,  -2,  -1],
                       [0,  0,  0],
                       [1, 2, 1]]

//=========================================================================================



//======================================Laplacian operator=================================
// Uncomment below to try

//        let kernelX = [[0, 1, 0],
//                       [1, -4, 1],
//                       [0, 1, 0]]
//
//        let kernelY = [[0, -1, 0],
//                       [-1, 4, -1],
//                       [0, -1, 0]]

//=========================================================================================



//========================-Sobel or Laplacian operator applying============================
        for y in 1..<height - 1 {
            for x in 1..<width - 1 {
                let gx = (kernelX[0][0] * Int(pixelValues[(y - 1) * width + (x - 1)])) +
                    (kernelX[0][1] * Int(pixelValues[(y - 1) * width + x])) +
                    (kernelX[0][2] * Int(pixelValues[(y - 1) * width + (x + 1)])) +
                    (kernelX[1][0] * Int(pixelValues[y * width + (x - 1)])) +
                    (kernelX[1][1] * Int(pixelValues[y * width + x])) +
                    (kernelX[1][2] * Int(pixelValues[y * width + (x + 1)])) +
                    (kernelX[2][0] * Int(pixelValues[(y + 1) * width + (x - 1)])) +
                    (kernelX[2][1] * Int(pixelValues[(y + 1) * width + x])) +
                    (kernelX[2][2] * Int(pixelValues[(y + 1) * width + (x + 1)]))

                let gy = (kernelY[0][0] * Int(pixelValues[(y - 1) * width + (x - 1)])) +
                    (kernelY[0][1] * Int(pixelValues[(y - 1) * width + x])) +
                    (kernelY[0][2] * Int(pixelValues[(y - 1) * width + (x + 1)])) +
                    (kernelY[1][0] * Int(pixelValues[y * width + (x - 1)])) +
                    (kernelY[1][1] * Int(pixelValues[y * width + x])) +
                    (kernelY[1][2] * Int(pixelValues[y * width + (x + 1)])) +
                    (kernelY[2][0] * Int(pixelValues[(y + 1) * width + (x - 1)])) +
                    (kernelY[2][1] * Int(pixelValues[(y + 1) * width + x])) +
                    (kernelY[2][2] * Int(pixelValues[(y + 1) * width + (x + 1)]))
//==========================================================================================

//   Comment Sobel or Laplacian and applying above if you'd like to try Robert Cross below


//============================Robert Cross operator=========================================
// Uncomment below to try

/*
        let kernelX = [[1, 0],
                       [0, -1]]

        let kernelY = [[0,  1],
                       [-1,  0]]


        for y in 1..<height - 1 {
            for x in 1..<width - 1 {

                let gx = (kernelX[0][0] * Int(pixelValues[(y - 1) * width + (x - 1)])) +
                    (kernelX[0][1] * Int(pixelValues[(y - 1) * width + x])) +
                    (kernelX[1][0] * Int(pixelValues[y * width + (x - 1)])) +
                    (kernelX[1][1] * Int(pixelValues[y * width + x]))


                let gy = (kernelY[0][0] * Int(pixelValues[(y - 1) * width + (x - 1)])) +
                    (kernelY[0][1] * Int(pixelValues[(y - 1) * width + x])) +
                    (kernelY[1][0] * Int(pixelValues[y * width + (x - 1)])) +
                    (kernelY[1][1] * Int(pixelValues[y * width + x]))
 */
//=========================================================================================


//============================Detected edges creating======================================

                var g = sqrt(Double((gx * gx) + (gy * gy)))
                //let ng = (1 / (1 + exp(-g))) * 255

                //var g = abs(gx) + abs(gy)
                if g > 255 {
                    g = 255
                }
                edge.append(UInt8(g))

                let theta = atan(Float(gy) / Float(gx))
                edgeDirection.append(theta)
            }
        }
        return edge

//==========================================================================================
    }

    // 5 - Non-maximum suppression

    // 6 - Hysteresis with upper threshold and lower treshold

    // 7 - Edgemap

    // 8 - Convert edgemap to image OK
    class func imageEdgesDetected(pixelValues: [UInt8]?, width: Int, height: Int) ->  UIImage {
        var imageRef: CGImage?
        if let pixelValues = pixelValues {
            let bitsPerComponent = 8
            let bytesPerPixel = 1
            let bitsPerPixel = bytesPerPixel * bitsPerComponent
            let bytesPerRow = bytesPerPixel * width
            let totalBytes = height * bytesPerRow
            let unusedCallback: CGDataProviderReleaseDataCallback = { optionalPointer, pointer, valueInt in }
            let providerRef = CGDataProvider(dataInfo: nil, data: pixelValues, size: totalBytes, releaseData: unusedCallback)

            let bitmapInfo: CGBitmapInfo = [CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue), CGBitmapInfo(rawValue: CGImageByteOrderInfo.orderDefault.rawValue)]
            imageRef = CGImage(width: width,
                               height: height,
                               bitsPerComponent: bitsPerComponent,
                               bitsPerPixel: bitsPerPixel,
                               bytesPerRow: bytesPerRow,
                               space: CGColorSpaceCreateDeviceGray(),
                               bitmapInfo: bitmapInfo,
                               provider: providerRef!,
                               decode: nil,
                               shouldInterpolate: true,
                               intent: .perceptual)
        }

        let image = UIImage(cgImage: imageRef!)
        return image
    }
}

extension UIImage {
    // Convert colored image to grayscale
    func convertToGrayScale() -> UIImage? {
            let imageRect:CGRect = CGRect(x:0, y:0, width:self.size.width, height: self.size.height)
            let colorSpace = CGColorSpaceCreateDeviceGray()
            let width = self.size.width
            let height = self.size.height
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
            let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            if let cgImg = self.cgImage {
                context?.draw(cgImg, in: imageRect)
                if let makeImg = context?.makeImage() {
                    let imageRef = makeImg
                    let newImage = UIImage(cgImage: imageRef)
                    return newImage
                }
            }
            return UIImage()
        }
}

