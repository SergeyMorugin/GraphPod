//
//  EdgeDetectionAlgorithm.swift
//  FBSnapshotTestCase
//
//  Created by Ilya Doroshkevitch on 07.07.2021.
//

import Foundation

public final class EdgeDetectionAlgorithm {

    // MARK: - Main method
    public static func execute(for image: UIImage) -> UIImage {

        let defaultImage = UIImage(named: "defaultImage")!

        // 0 - Convert to grayscale bitmap
        //let grayScaleBitmap = image.convertToGrayScaleBitmap(image: image)

        // 1 - convert colored input image to grayscale
        guard let grayScaledImage = image.convertToGrayScale() else { return defaultImage}

        // 2 - Gaussian smoothing image
        let smoothedImage = grayScaledImage.smoothing(sigma: 0.6)

        // 3 - Convert image to pixels grayscale matrix
        guard let pixelValuesFromGrayScaleImage = ImageProcessing.pixelValuesFromGrayScaleImage(imageRef: smoothedImage?.cgImage) else { return defaultImage }

        // 4 - Operate and get gradient matrix
        let gradientMatrix = operate(pixelValues: pixelValuesFromGrayScaleImage, height: Int(image.size.height), width: Int(image.size.width))

        // 5 - Convert gradient matrix to an image
        let processedImageWidth = Int(image.size.width) - 2
        let processedImageHeight = Int(image.size.height) - 2

        let processedImage = ImageProcessing.createImageFromEdgesDetected(pixelValues: gradientMatrix, width: processedImageWidth, height: processedImageHeight)

        //let processedImage = UIImage.fromBitmapImage(bitmapImage: grayScaleBitmap)!

        return processedImage
    }
}


// MARK: - Extensions
public extension EdgeDetectionAlgorithm {
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

