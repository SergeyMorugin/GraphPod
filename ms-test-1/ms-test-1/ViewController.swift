//
//  ViewController.swift
//  ms-test-1
//
//  Created by Matthew on 17.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onRunClick(_ sender: Any) {
        print("Run")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        // Get inital image
        guard let processingImage = UIImage(named:"test3") else { return }
       
        
        guard let smoothImage = processingImage.smoothing(sigma: 0.1) else { return }
        resultImage.image = smoothImage
        print("Gauss smooth: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        guard let image = smoothImage.toBitmapImage() else { return }
 
        //print(image)
        let result = SegmentingImageAlgorithm().segmentImage(image)
        //print(resultImage)
        let resultText = "Finish in \(CFAbsoluteTimeGetCurrent() - startTime) s."
        print(resultText)
        resultLabel.text = resultText
        print(image.pixels[100...120])
        print(result!.pixels[0...100])
        
        let im = processingImage.fromBitmapImage(bitmapImage: result!)
        im?.cgImage?.copy(colorSpace: processingImage.cgImage!.colorSpace!)
        //print(processingImage.cgImage.debugDescription)
        //print(im!.cgImage.debugDescription)
        //print(im!.toBitmapImage()!.pixels[100...120])
        resultImage.image = im
    }
    
}

