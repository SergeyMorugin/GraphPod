//
//  ImageProcessing.swift
//  FBSnapshotTestCase
//
//  Created by Ilya Doroshkevitch on 07.07.2021.
//

import Foundation

public final class ImageProcessing {

    // MARK: - Convert image to pixels grayscale matrix
    public static func pixelValuesFromGrayScaleImage(imageRef: CGImage?) -> ([UInt8]?) {
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

    // MARK: - Convert edgemap to image
    public static func createImageFromEdgesDetected(pixelValues: [UInt8]?, width: Int, height: Int) ->  UIImage {
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
