//
//  ViewController.swift
//  ms-test-1
//
//  Created by Matthew on 17.06.2021.
//  Copyright © 2021 Ostagram Inc. All rights reserved.
//
import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var resultImage1: UIImageView!
    @IBOutlet weak var resultLabel1: UILabel!

    let coefficients:[String: Float] = ["sigma": 0.7, "threshold": 400, "minSize": 200 ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Default image
        let image = UIImage(named:"test3")

        resultImage1.image = image

        resultLabel1.text = "Info will be here..."
    }


    // MARK: - Segmenting image
    @IBAction func onRunClick1(_ sender: Any) {
        print("Run")

        let startTime = CFAbsoluteTimeGetCurrent()

        // Get inital image
        guard let processingImage = resultImage1.image else { return }

        // Smoothing image
        guard let smoothImage = processingImage.smoothing(sigma: Double(coefficients["sigma"]!)) else { return }

        print("Gauss smooth: \(CFAbsoluteTimeGetCurrent() - startTime) s.")

        // Convert smoothed image to bitmap
        guard let image = smoothImage.toBitmapImage() else { return }

        // Get segmented image
        let result = SegmentingImageAlgorithm().segmentImage(image, threshold: coefficients["threshold"]!, minSize: Int(coefficients["minSize"]!))

        let im = UIImage.fromBitmapImage(bitmapImage: result!.0)
        im?.cgImage?.copy(colorSpace: processingImage.cgImage!.colorSpace!)

        resultImage1.image = im

        // Get info
        let resultText = "Found \(result!.1.roots.count) sections in \(round((CFAbsoluteTimeGetCurrent() - startTime)*1000)/1000) s for image \(processingImage.size.width)x\(processingImage.size.height) \(coefficients)"
        print(resultText)
        resultLabel1.text = resultText

    }

    // MARK: - Edges detection
    @IBAction func getEdges(_ sender: Any) {
          detectEdges()
    }

    private func detectEdges() {
        print("Detect edges")

        let startTime = CFAbsoluteTimeGetCurrent()

        // Get input image and convert it to grayscale
        guard let image = resultImage1.image?.convertToGrayScale() else { return }

        // Smooth the image
        guard let smoothImage = image.smoothing(sigma: Double(coefficients["sigma"]!)) else { return }

        // Get grayscale image pixel data for edge detection
        guard let pixelValuesGrayScaleImage = EdgeDetectionAlgorithm.pixelValuesFromGrayScaleImage(imageRef: smoothImage.cgImage) else { return }

        //print(pixelValuesGrayScaleImage)

        // Get magnitudes feature normalized data matrix
        let featureMatrix = EdgeDetectionAlgorithm.operate(pixelValues: pixelValuesGrayScaleImage, height: Int(image.size.height), width: Int(image.size.width))
        
        //print(featureMatrix)

        // Create output image
        let edgesImage = EdgeDetectionAlgorithm.imageEdgesDetected(pixelValues: featureMatrix, width: Int(image.size.width), height: Int(image.size.height))

        resultImage1.image = edgesImage

        print("Edge detection done in: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
    }

// MARK: - Image picker
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


// MARK: - Extensions
extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let image = extractImage(from: info)
        resultImage1.image = image
        resultLabel1.text = ""
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
