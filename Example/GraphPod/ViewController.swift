//
//  ViewController.swift
//  GraphPod
//
//  Created by segiomars@gmail.com on 07/03/2021.
//  Copyright (c) 2021 segiomars@gmail.com. All rights reserved.
//

import UIKit
import GraphPod

class ViewController: UIViewController {
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    let coefficients:[String: Float] = ["sigma": 0.6, "threshold": 10, "minSize": 10 ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        resultImage.image = UIImage(named:"test2")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLoadPhotoClick(_ sender: Any) {
        takeAPhoto()
    }
    
    @IBAction func onRunClick(_ sender: Any) {
        print("Run")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        // Get inital image
        guard let processingImage = resultImage.image else { return }
       
        
        //guard let smoothImage = processingImage.smoothing(sigma: Double(coefficients["sigma"]!)) else { return }
        //resultImage.image = smoothImage
        print("Gauss smooth: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        guard let image = processingImage.toBitmapImage() else { return }
        //resultImage.image = smoothImage
 
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
