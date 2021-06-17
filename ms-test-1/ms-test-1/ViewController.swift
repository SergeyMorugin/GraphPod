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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onRunClick(_ sender: Any) {
        print("Run")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        // Get inital image
        guard let processing_image = UIImage(named:"test3") else { return }
        
        let algorithm = SegmentingImageAlgorithm()
        guard let image = processing_image.toBitmapImage() else { return }
        print("Uncompres image: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        let result_image = algorithm.segmentImage(image)
        print(result_image)
        print("Finish in \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        resultImage.image = result_image
    }
    
}

