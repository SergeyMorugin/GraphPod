//
//  GaussBlurAlgorithm.swift
//  GraphPod
//
//  Created by Ilya Doroshkevitch on 13.07.2021.
//

extension BitmapImage {
    public func fastGaussBlur(radius: Int) -> BitmapImage {

        let bxs = boxesForGauss(Float(radius), 3)

        var pR: [UInt8] = [UInt8].init(repeating: 0, count: width*height)
        var pG: [UInt8] = [UInt8].init(repeating: 0, count: width*height)
        var pB: [UInt8] = [UInt8].init(repeating: 0, count: width*height)
        var pA: [UInt8] = [UInt8].init(repeating: 0, count: width*height)

        (0..<(width*height)).forEach { i in
            let pos = i * bytesPerComponent
            pR[i] = pixels[pos]
            pG[i] = pixels[pos+1]
            pB[i] = pixels[pos+2]
            pA[i] = pixels[pos+3]
        }

        pR = fastGaussBlurByColor(radius, pR, bxs)
        pG = fastGaussBlurByColor(radius, pG, bxs)
        pB = fastGaussBlurByColor(radius, pB, bxs)

        var output:[UInt8] = [UInt8].init(repeating: 0, count: width*height*bytesPerComponent)

        (0..<(width*height)).forEach { i in
            let pos = i * bytesPerComponent
            output[pos] = pR[i]
            output[pos+1] = pG[i]
            output[pos+2] = pB[i]
            output[pos+3] = pA[i]
        }
        return BitmapImage(width: width, height: height, pixels: output)
    }

    func fastGaussBlurByColor(_ r: Int, _ colorPixels: [UInt8],_ bxs: [Int]) -> [UInt8] {
        var output1 = colorPixels
        var output2 = [UInt8].init(repeating: 0, count: width*height)

        boxBlur(&output1, &output2, (bxs[0]-1)/2)
        boxBlur(&output2, &output1, (bxs[1]-1)/2)
        boxBlur(&output1, &output2, (bxs[2]-1)/2)
        return output2
    }

    func boxesForGauss(_ sigma:Float, _ n: Int) -> [Int] {
        let wIdeal = sqrt((12*sigma*sigma/Float(n))+1)
        var wl = Int(floor(wIdeal))
        if (wl%2==0) {
            wl -= 1
        }
        let wu = wl + 2

        let mIdeal = Float(12*sigma*sigma - Float(n*wl*wl) - 4*Float(n*wl) - 3*Float(n)) / (-4*Float(wl) - 4)
        let m = Int(round(mIdeal))

        var sizes:[Int] = []
        for i in (0..<n) {
            sizes.append(i<m ? wl : wu)
        }
        return sizes
    }

    func boxBlurH(_ scl: [UInt8], _ tcl: inout [UInt8], _ r: Int) {
        let iarr:Float = 1 / (2*Float(r)+1)
        for i in (0..<height) {
            var ti = i * width
            var li = ti
            var ri = ti + r
            let fv = Int(scl[ti])
            let lv = Int(scl[ti+width-1])
            var val: Int = ( r + 1) * fv;
            for j in (0..<r) { val += Int(scl[ti+j]) }
            for _ in (0...r) {
                val += Int(scl[ri]) - fv
                ri += 1
                tcl[ti] = UInt8(round(Float(val)*iarr))
                ti += 1
            }
            for _ in ((r+1)..<(width-r)) {
                val += Int(scl[ri]) - Int(scl[li])
                ri += 1
                li += 1
                tcl[ti] = UInt8(round(Float(val)*iarr))
                ti += 1
            }
            for _ in ((width-r)..<width) {
                val += lv - Int(scl[li])
                li += 1
                tcl[ti] = UInt8(round(Float(val)*iarr))
                ti += 1
            }
        }
    }

    func boxBlurT(_ scl: [UInt8], _ tcl: inout [UInt8], _ r: Int) {
        let iarr: Float = 1 / (2*Float(r)+1)
        for i in (0..<width) {
            var ti = i
            var li = ti
            var ri = ti + r*width;
            let fv = Int(scl[ti])
            let lv = Int(scl[ti+width*(height-1)])
            var val = (r+1)*fv;
            for j in (0..<r) {
                val += Int(scl[ti+j*width])
            }
            for _ in (0...r) {
                val += Int(scl[ri]) - fv
                tcl[ti] = UInt8(round(Float(val)*iarr))
                ri += width
                ti += width
            }
            for _ in ((r+1)..<(height-r)) {
                val += Int(scl[ri]) - Int(scl[li])
                tcl[ti] = UInt8(round(Float(val)*iarr))
                li += width
                ri += width
                ti += width
            }
            for _ in ((height-r)..<(height)) {
                val += lv - Int(scl[li])
                tcl[ti] = UInt8(round(Float(val)*iarr))
                li += width
                ti += width
            }
        }
    }


    func boxBlur(_ scl: inout [UInt8], _ tcl: inout [UInt8], _ r: Int) {
        tcl = scl
        boxBlurH(tcl, &scl, r)
        boxBlurT(scl, &tcl, r)
    }
}
