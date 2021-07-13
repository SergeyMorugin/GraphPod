//
//  EdgeDetectionAlgorithm.swift
//  FBSnapshotTestCase
//
//  Created by Ilya Doroshkevitch on 07.07.2021.
//

import Foundation

protocol EdgeDetectionable {
    static func execute(input: BitmapImage) -> BitmapImage?
    static func operate(pixelValues: [UInt8], height: Int, width: Int) -> [UInt8]
}

public final class EdgeDetectionAlgorithm: EdgeDetectionable {

    // MARK: - Main method
    public static func execute(input: BitmapImage) -> BitmapImage? {

        // 1 - Create grayscale bitmap
        let grayScaleBitmap = input.toGrayScaleBitmap()

        // 2 - Operate and get gradient matrix
        let gradientMatrix = operate(pixelValues: grayScaleBitmap!.pixels, height: Int(input.height), width: Int(input.width))

        return BitmapImage(width: input.width, height: input.height, pixels: gradientMatrix)
    }
}


// MARK: - Extensions
extension EdgeDetectionable {
    static func operate(pixelValues: [UInt8], height: Int, width: Int) -> [UInt8] {
        var edge: [UInt8] = []
        let oper = Sobel()

        // Applying operator
        (1..<height - 1).forEach { y in
            (1..<width - 1).forEach { x in

                let gx1 = (oper.kernelX[0][0] * Int(pixelValues[(y - 1) * width + (x - 1)])) +
                    (oper.kernelX[0][1] * Int(pixelValues[(y - 1) * width + x]))

                let gx2 = (oper.kernelX[0][2] * Int(pixelValues[(y - 1) * width + (x + 1)])) +
                    (oper.kernelX[1][0] * Int(pixelValues[y * width + (x - 1)])) +
                    (oper.kernelX[1][1] * Int(pixelValues[y * width + x]))

                let gx3 = (oper.kernelX[1][2] * Int(pixelValues[y * width + (x + 1)])) +
                    (oper.kernelX[2][0] * Int(pixelValues[(y + 1) * width + (x - 1)]))

                let gx4 = (oper.kernelX[2][1] * Int(pixelValues[(y + 1) * width + x])) +
                    (oper.kernelX[2][2] * Int(pixelValues[(y + 1) * width + (x + 1)]))

                let gy1 = (oper.kernelY[0][0] * Int(pixelValues[(y - 1) * width + (x - 1)])) +
                    (oper.kernelY[0][1] * Int(pixelValues[(y - 1) * width + x]))

                let gy2 = (oper.kernelY[0][2] * Int(pixelValues[(y - 1) * width + (x + 1)])) +
                    (oper.kernelY[1][0] * Int(pixelValues[y * width + (x - 1)])) +
                    (oper.kernelY[1][1] * Int(pixelValues[y * width + x]))

                let gy3 = (oper.kernelY[1][2] * Int(pixelValues[y * width + (x + 1)])) +
                    (oper.kernelY[2][0] * Int(pixelValues[(y + 1) * width + (x - 1)]))

                let gy4 = (oper.kernelY[2][1] * Int(pixelValues[(y + 1) * width + x])) +
                    (oper.kernelY[2][2] * Int(pixelValues[(y + 1) * width + (x + 1)]))

                let gx = gx1 + gx2 + gx3 + gx4
                let gy = gy1 + gy2 + gy3 + gy4

                // Calculating gradient magnitude
                var g = sqrt(Double((gx * gx) + (gy * gy)))

                // Normalization
                if g > 255 {
                    g = 255
                }

                edge.append(UInt8(g))
            }
        }
        return edge
    }
}

