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
    @IBOutlet weak var thresholdPicker: UIPickerView!
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    let thresholdValues: [Float] = [0.01,0.1,1,5,10,20,50,100,200,300]
    let minSizeValues = [1,5,10,20,50,100,200,300, 500, 1000,10000]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        resultImage.image = UIImage(named:"test2")
        self.thresholdPicker.delegate = self
        self.thresholdPicker.dataSource = self
        thresholdPicker.selectRow(4, inComponent: 0, animated: false)
        thresholdPicker.selectRow(2, inComponent: 1, animated: false)
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
       
        print("Gauss smooth: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        guard let image = processingImage.toBitmapImage() else { return }
        //print(image.pixels.count)
        
        let threshold = thresholdValues[thresholdPicker.selectedRow(inComponent: 0)]
        let minPixelsInSectro = minSizeValues[thresholdPicker.selectedRow(inComponent: 1)]
        let result = SegmentingImageAlgorithm.execute(image: image, threshold: threshold, minSize: minPixelsInSectro)
        //print(result)
       
        
        let im = UIImage.fromBitmapImage(bitmapImage: result!.0)
        im?.cgImage?.copy(colorSpace: processingImage.cgImage!.colorSpace!)

        resultImage.image = im
        let resultText = "Found \(result!.1.roots.count) sections in \(round((CFAbsoluteTimeGetCurrent() - startTime)*1000)/1000) s for image \(processingImage.size.width)x\(processingImage.size.height)"
        print(resultText)
        resultLabel.text = resultText
    }
    
    func takeAPhoto() {
        let imagePickerController = UIImagePickerController()
       /*if UIImagePickerController.isSourceTypeAvailable(.camera) {
           imagePickerController.sourceType = .camera
       } else {
           imagePickerController.sourceType = .savedPhotosAlbum
       }*/
       imagePickerController.sourceType = .savedPhotosAlbum
       imagePickerController.allowsEditing = true
       imagePickerController.delegate = self
        UIApplication.shared.keyWindow?.rootViewController?.present(imagePickerController, animated: true)
    }
}


extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return thresholdValues.count
        } else {
            return minSizeValues.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return  String(thresholdValues[row])
        } else {
            return String(minSizeValues[row])
        }
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
