//
//  Extension UIImage.swift
//  FBSnapshotTestCase
//
//  Created by Ilya Doroshkevitch on 07.07.2021.
//

import Foundation

extension UIImage {

    // MARK: - Convert colored image to grayscale
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

