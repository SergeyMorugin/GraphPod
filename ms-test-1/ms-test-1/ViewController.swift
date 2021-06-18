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
        resultImage.image = UIImage(named:"test4")
    }

    @IBAction func onRunClick(_ sender: Any) {
        print("Run")
        
        let startTime = CFAbsoluteTimeGetCurrent()
        // Get inital image
        guard let processingImage = resultImage.image else { return }
       
        
        guard let smoothImage = processingImage.smoothing(sigma: 0.6) else { return }
        //resultImage.image = smoothImage
        print("Gauss smooth: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        guard let image = smoothImage.toBitmapImage() else { return }
 
        //print(image)
        let result = SegmentingImageAlgorithm().segmentImage(image, threshold: 0.2, minSize: 10)
        //print(resultImage)
       
        
        let im = UIImage.fromBitmapImage(bitmapImage: result!.0)
        im?.cgImage?.copy(colorSpace: processingImage.cgImage!.colorSpace!)

        resultImage.image = im
        let resultText = "Found \(result!.1.roots.count) sections in \(round((CFAbsoluteTimeGetCurrent() - startTime)*1000)/1000) s for image \(processingImage.size.width)x\(processingImage.size.height)"
        print(resultText)
        resultLabel.text = resultText
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

