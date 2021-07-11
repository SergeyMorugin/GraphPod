//
//  ViewController.swift
//  GraphPod
//
//  Created by segiomars@gmail.com on 07/03/2021.
//  Copyright (c) 2021 segiomars@gmail.com. All rights reserved.
//

import UIKit
import GraphPod
import Metal

public class SomeClassFromMyShaderFramework {}

class ViewController: UIViewController {
    @IBOutlet weak var thresholdPicker: UIPickerView!
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    let thresholdValues: [Float] = [0.01,0.1,1,5,10,20,50,100,200,300]
    let minSizeValues = [1,5,10,20,50,100,200,300, 500, 1000,10000]

    
    func runMetal() {
        let count = 50_000_000
        let elementsPerSum = 10_000

        // Data type, has to be the same as in the shader
        typealias DataType = CInt

        let device = MTLCreateSystemDefaultDevice()!
        
        /*let frameworkBundle = Bundle(for: SomeClassFromMyShaderFramework.self)
        guard let library = try? device.makeDefaultLibrary(bundle: frameworkBundle) else {
            fatalError("Could not load default library from specified bundle")
        }*/
        let library = device.makeDefaultLibrary()
        //let library = self.library(device: device)
        let parsum = library!.makeFunction(name: "parsum")!
        let pipeline = try! device.makeComputePipelineState(function: parsum)

        // Our data, randomly generated:
        var data = (0..<count).map{ _ in DataType(arc4random_uniform(100)) }
        var dataCount = CUnsignedInt(count)
        var elementsPerSumC = CUnsignedInt(elementsPerSum)
        // Number of individual results = count / elementsPerSum (rounded up):
        let resultsCount = (count + elementsPerSum - 1) / elementsPerSum

        // Our data in a buffer (copied):
        let dataBuffer = device.makeBuffer(bytes: &data, length: MemoryLayout<DataType>.stride * count, options: [])!
        // A buffer for individual results (zero initialized)
        let resultsBuffer = device.makeBuffer(length: MemoryLayout<DataType>.stride * resultsCount, options: [])!
        // Our results in convenient form to compute the actual result later:
        let pointer = resultsBuffer.contents().bindMemory(to: DataType.self, capacity: resultsCount)
        let results = UnsafeBufferPointer<DataType>(start: pointer, count: resultsCount)

        let queue = device.makeCommandQueue()!
        let cmds = queue.makeCommandBuffer()!
        let encoder = cmds.makeComputeCommandEncoder()!

        encoder.setComputePipelineState(pipeline)

        encoder.setBuffer(dataBuffer, offset: 0, index: 0)

        encoder.setBytes(&dataCount, length: MemoryLayout<CUnsignedInt>.size, index: 1)
        encoder.setBuffer(resultsBuffer, offset: 0, index: 2)
        encoder.setBytes(&elementsPerSumC, length: MemoryLayout<CUnsignedInt>.size, index: 3)

        // We have to calculate the sum `resultCount` times => amount of threadgroups is `resultsCount` / `threadExecutionWidth` (rounded up) because each threadgroup will process `threadExecutionWidth` threads
        let threadgroupsPerGrid = MTLSize(width: (resultsCount + pipeline.threadExecutionWidth - 1) / pipeline.threadExecutionWidth, height: 1, depth: 1)

        // Here we set that each threadgroup should process `threadExecutionWidth` threads, the only important thing for performance is that this number is a multiple of `threadExecutionWidth` (here 1 times)
        let threadsPerThreadgroup = MTLSize(width: pipeline.threadExecutionWidth, height: 1, depth: 1)

        encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()

        var start, end : UInt64
        var result : DataType = 0

        start = mach_absolute_time()
        cmds.commit()
        cmds.waitUntilCompleted()
        for elem in results {
            //result += elem
        }

        end = mach_absolute_time()

        print("Metal result: \(result), time: \(Double(end - start) / Double(NSEC_PER_SEC))")
        result = 0

        start = mach_absolute_time()
        data.withUnsafeBufferPointer { buffer in
            for elem in buffer {
                //result += elem
            }
        }
        end = mach_absolute_time()

        print("CPU result: \(result), time: \(Double(end - start) / Double(NSEC_PER_SEC))")

    }
    
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
        runMetal()
        return
        
        let startTime = CFAbsoluteTimeGetCurrent()
        // Get inital image
        guard let processingImage = resultImage.image else { return }
       
        print("Gauss smooth: \(CFAbsoluteTimeGetCurrent() - startTime) s.")
        guard var image = processingImage.toBitmapImage() else { return }
        //print(image.pixels.count)
        
        /*let threshold = thresholdValues[thresholdPicker.selectedRow(inComponent: 0)]
        let minPixelsInSectro = minSizeValues[thresholdPicker.selectedRow(inComponent: 1)]
        let result = SegmentingImageAlgorithm.execute(image: image, threshold: threshold, minSize: minPixelsInSectro)*/
        //print(result)
        
        image = image.fastGaussBlur2(r: 3)

        
        let im = UIImage.fromBitmapImage(bitmapImage: image)
        im?.cgImage?.copy(colorSpace: processingImage.cgImage!.colorSpace!)

        resultImage.image = im
        print(CFAbsoluteTimeGetCurrent() - startTime)
        /*let resultText = "Found \(result!.1.roots.count) sections in \(round((CFAbsoluteTimeGetCurrent() - startTime)*1000)/1000) s for image \(processingImage.size.width)x\(processingImage.size.height)"
        print(resultText)
        resultLabel.text = resultText*/
    }
    
    
    @IBAction func onSaveImageClick(_ sender: Any) {
        guard let image = resultImage.image else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
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
