//
//  ViewController.swift
//  GraphPod Example App
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

    // Values for UIPicker
    let thresholdValues: [Float] = [0.01,0.1,1,5,10,20,50,100,200,300]
    let minSizeValues = [1,5,10,20,50,100,200,300, 500, 1000,10000]

    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set default image
        resultImage.image = UIImage(named:"defaultImage")

        setPicker()
    }

    // MARK: - Load photo from library
    @IBAction func onLoadPhotoClick(_ sender: Any) {
        takeAPhoto()
    }

    func takeAPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        UIApplication.shared.keyWindow?.rootViewController?.present(imagePickerController, animated: true)
    }

    // MARK: - Run the Segmentation algorithm processing
    @IBAction func onSegmentationRunClick(_ sender: Any) {
        let startTime = CFAbsoluteTimeGetCurrent()

        // Get inital UIImage
        guard let processingImage = resultImage.image else { return }

  //=======================Execute the algorithm=================================

        // Convert processing image to bitmap
        guard let bitmap = processingImage.toBitmapImage() else { return }

        // Get threshold and minSegmentSize
        let threshold = thresholdValues[thresholdPicker.selectedRow(inComponent: 0)]
        let minPixelsInSegment = minSizeValues[thresholdPicker.selectedRow(inComponent: 1)]

        // Get processed bitmap result
        let result = SegmentingImageAlgorithm.execute(image: bitmap, threshold: threshold, minSize: minPixelsInSegment)

 //======================Convert result to UIImage===============================

        // Convert processed bitmap to UIImage
        let processedImage = UIImage.fromBitmapImage(bitmapImage: result!.0)
        processedImage?.cgImage?.copy(colorSpace: processingImage.cgImage!.colorSpace!)

        resultImage.image = processedImage

 //======================Show result info text===================================

        resultLabel.text =  "Found \(result!.1.roots.count) sections in \(round((CFAbsoluteTimeGetCurrent() - startTime)*1000)/1000)s for image \(processingImage.size.width)x\(processingImage.size.height)"
    }

    // MARK: - Run the Detect Edges algorithm processing
    @IBAction func onDetectEdgesClick(_ sender: Any) {
        let startTime = CFAbsoluteTimeGetCurrent()

        // Get inital UImage
        guard let processingImage = resultImage.image else { return }

   //=======================Execute the algorithm==================================

        // Convert processing UImage to bitmap
        guard let bitmap = processingImage.toBitmapImage() else { return }

        // Get processed bitmap result
        let result = EdgeDetectionAlgorithm.execute(input: bitmap)

   //======================Convert result to UIImage===============================
        
        let processedImage = UIImage.createFromEdgesDetectedBitmap(bitmapImage: result)

        resultImage.image = processedImage

    //======================Show result info text================================

        resultLabel.text =  "Detect edges in \(round((CFAbsoluteTimeGetCurrent() - startTime)*1000)/1000)s" +
            " for image \(processingImage.size.width)x\(processingImage.size.height)"
    }

    // MARK: - Run the Gauss Blur Algorithm
    @IBAction func onGaussBlurClick(_ sender: Any) {
        let startTime = CFAbsoluteTimeGetCurrent()

        // Get inital image
        guard let processingImage = resultImage.image else { return }

    //=======================Execute the algorithm==============================

        // Convert processing UImage to bitmap
        guard let bitmap = processingImage.toBitmapImage() else { return }

        // Get processed bitmap result
        let blurredResult = bitmap.fastGaussBlur(radius: 3)

    //======================Convert result to UIImage============================
        
        let processedImage = UIImage.fromBitmapImage(bitmapImage: blurredResult)

        resultImage.image = processedImage

    //======================Show result info text================================

        resultLabel.text =  "Gauss blur in \(round((CFAbsoluteTimeGetCurrent() - startTime)*1000)/1000)s" +
            " for image \(processingImage.size.width)x\(processingImage.size.height)"
    }
    
    // MARK: - Save the processed image to library
    @IBAction func onSaveImageClick(_ sender: Any) {
        guard let image = resultImage.image else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    // MARK: - UIPicker setup
    func setPicker() {
        self.thresholdPicker.delegate = self
        self.thresholdPicker.dataSource = self
        thresholdPicker.selectRow(9, inComponent: 0, animated: false)
        thresholdPicker.selectRow(7, inComponent: 1, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let threshold = thresholdValues[thresholdPicker.selectedRow(inComponent: 0)]
        let minPixelsInSegment = minSizeValues[thresholdPicker.selectedRow(inComponent: 1)]
        if let cameraController = segue.destination as? CameraViewController {
            cameraController.minSizeValue = minPixelsInSegment
            cameraController.thresholdValue = threshold
        }
    }
}


// MARK: - Extensions
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource{

    // MARK: - UIPicker Delegate
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

    // MARK: - ImagePicker Delegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let image = extractImage(from: info)
        resultImage.image = image
        resultLabel.text = ""
        picker.dismiss(animated: true)
    }

    // MARK: - Extract image
    private func extractImage(from info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        if let image = info[.editedImage] as? UIImage {
            return image
        } else if let image = info[.originalImage] as? UIImage {
            return image
        } else {
            return nil
        }
    }
}
