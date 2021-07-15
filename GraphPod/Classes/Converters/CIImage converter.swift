//
//  CIImage converter.swift
//  GraphPod
//
//  Created by Ilya Doroshkevitch on 15.07.2021.
//

#if canImport(CoreImage)

import CoreImage

extension CIImage {

    // MARK: - Convert CIImage to bitmap
    public func toBitmapImage(context: CIContext) -> BitmapImage {
        let rowBytes = 4 * Int(self.extent.width) // 4 channels (RGBA) of 8-bit data
        let dataSize = rowBytes * Int(self.extent.height)
        var data = Data(count: dataSize)
        var bitmap = [UInt8](repeating: 0, count: Int(self.extent.width*self.extent.height)*4)
        data.withUnsafeMutableBytes { data in
             context.render(self, toBitmap: &bitmap, rowBytes: rowBytes, bounds: self.extent, format: .RGBA8, colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!)
        }
        return BitmapImage(width: Int(self.extent.width), height: Int(self.extent.height), pixels: bitmap)
    }
}
#endif
