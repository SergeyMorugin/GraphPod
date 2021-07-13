//
//  UIImage converters.swift
//  GraphPod
//
//  Created by Ilya Doroshkevitch on 13.07.2021.
//

import Foundation

#if canImport(UIKit)

import UIKit

extension UIImage {

    // MARK: - Convert UIImage to bitmap
    public func toBitmapImage() -> BitmapImage? {
        let size = self.size
        let dataSize = size.width * size.height * 4
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

    // MARK: - Convert common bitmap to UIImage
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

    // MARK: - Convert Edge Detected bitmap to UIImage
    public static func createFromEdgesDetectedBitmap(bitmapImage: BitmapImage?) ->  UIImage {
        var imageRef: CGImage?
        let imageSizeConvertOffset = 2

        guard let imageSize = bitmapImage else { return UIImage(named: "defaultImage")!}
        let width = imageSize.width - imageSizeConvertOffset
        let height = imageSize.height - imageSizeConvertOffset

        if let pixelValues = bitmapImage?.pixels {
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
#endif
