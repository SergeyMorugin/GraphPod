//
//  ViewController.swift
//  ms-test-1
//
//  Created by Matthew on 17.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//

import UIKit
import GraphPod


class ViewController: UIViewController {
    
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    let coefficients:[String: Float] = ["sigma": 0.6, "threshold": 10, "minSize": 10 ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        resultImage.image = UIImage(named:"test5")
    }

    @IBAction func onRunClick(_ sender: Any) {
        print("Run")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        // Get inital image
        guard let processingImage = resultImage.image else { return }
       
        
        //guard let smoothImage = processingImage.smoothing(sigma: Double(coefficients["sigma"]!)) else { return }
        //resultImage.image = smoothImage
        let smoothImage = processingImage
        print("Gauss smooth: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        guard let image = smoothImage.toBitmapImage() else { return }
        resultImage.image = smoothImage
 
        //print(image.pixels.count)
        let result = SegmentingImageAlgorithm.execute(image: image, threshold: coefficients["threshold"]!, minSize: Int(coefficients["minSize"]!))
        //print(result)
       
        
        let im = UIImage.fromBitmapImage(bitmapImage: result!.0)
        im?.cgImage?.copy(colorSpace: processingImage.cgImage!.colorSpace!)

        resultImage.image = im
        let resultText = "Found \(result!.1.roots.count) sections in \(round((CFAbsoluteTimeGetCurrent() - startTime)*1000)/1000) s for image \(processingImage.size.width)x\(processingImage.size.height) \(coefficients)"
        print(resultText)
        resultLabel.text = resultText
    }

    // MARK: - Edges detection
    @IBAction func getEdges(_ sender: Any) {
          detectEdges()
    }

    private func detectEdges() {
        print("Detect edges")

        let startTime = CFAbsoluteTimeGetCurrent()

        // Get input image and convert it to grayscale
        guard let image = resultImage.image?.convertToGrayScale() else { return }

        // Smooth the image
        guard let smoothImage = image.smoothing(sigma: Double(coefficients["sigma"]!)) else { return }

        // Get grayscale image pixel data for edge detection
        guard let pixelValuesGrayScaleImage = EdgeDetectionAlgorithm.pixelValuesFromGrayScaleImage(imageRef: smoothImage.cgImage) else { return }

        print(pixelValuesGrayScaleImage.count)

        // Get magnitudes feature normalized data matrix
        let featureMatrix = EdgeDetectionAlgorithm.operate(pixelValues: pixelValuesGrayScaleImage, height: Int(image.size.height), width: Int(image.size.width))


        // Create output image
        let readyImageWidth = Int(image.size.width) - 2
        let readyImageHeight = Int(image.size.height) - 2

        let edgesImage = EdgeDetectionAlgorithm.imageEdgesDetected(pixelValues: featureMatrix, width: readyImageWidth, height: readyImageHeight)

        resultImage.image = edgesImage

        print("Edge detection done in: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
    }



    @IBAction func onLoadPhotoClick(_ sender: Any) {
        takeAPhoto()
    }
    
    
    func takeAPhoto() {
        let imagePickerController = UIImagePickerController()
       if UIImagePickerController.isSourceTypeAvailable(.camera) {
           imagePickerController.sourceType = .camera
       } else {
           imagePickerController.sourceType = .savedPhotosAlbum
       }
       imagePickerController.allowsEditing = true
       imagePickerController.delegate = self
        UIApplication.shared.keyWindow?.rootViewController?.present(imagePickerController, animated: true)
    }
    
}

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
   
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let image = extractImage(from: info)
        resultImage.image = image
        resultLabel.text = ""
        picker.dismiss(animated: true)
    }
    
    private func extractImage(from info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        // Пытаемся извлечь отредактированное изображение
        if let image = info[.editedImage] as? UIImage {
            return image
            // Пытаемся извлечь оригинальное
        } else if let image = info[.originalImage] as? UIImage {
            return image
        } else {
            // Если изображение не получено, возвращаем nil
            return nil
        }
    }
}

