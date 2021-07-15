//
//  CameraViewController.swift
//  GraphPod_Example
//
//  Created by Ilya Doroshkevitch on 14.07.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import AVFoundation
import UIKit
import GraphPod

@available(iOS 10.0, *)
public final class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?

    var photoOutput: AVCapturePhotoOutput?
    var orientation: AVCaptureVideoOrientation = .portrait

    let context = CIContext()

    @IBOutlet weak var filteredImage: UIImageView!

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupDevice()
        setupInputOutput()
    }

    public override func viewDidLayoutSubviews() {
        orientation = AVCaptureVideoOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != .authorized
        {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler:
            { (authorized) in
                DispatchQueue.main.async
                {
                    if authorized
                    {
                        self.setupInputOutput()
                    }
                }
            })
        }
    }

    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices

        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            }
            else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }

        currentCamera = backCamera
    }

    func setupInputOutput() {
        do {
            setupCorrectFramerate(currentCamera: currentCamera!)
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
            if captureSession.canAddInput(captureDeviceInput) {
                captureSession.addInput(captureDeviceInput)
            }
            let videoOutput = AVCaptureVideoDataOutput()

            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate", attributes: []))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            captureSession.startRunning()
        } catch {
            print(error)
        }
    }

    func setupCorrectFramerate(currentCamera: AVCaptureDevice) {
        for vFormat in currentCamera.formats {
            //see available types
            //print("\(vFormat) \n")

            let ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
            let frameRates = ranges[0]

            do {
                //set to 240fps - available types are: 30, 60, 120 and 240 and custom
                // lower framerates cause major stuttering
                if frameRates.maxFrameRate == 240 {
                    try currentCamera.lockForConfiguration()
                    currentCamera.activeFormat = vFormat as AVCaptureDevice.Format
                    //for custom framerate set min max activeVideoFrameDuration to whatever you like, e.g. 1 and 180
                    currentCamera.activeVideoMinFrameDuration = frameRates.minFrameDuration
                    currentCamera.activeVideoMaxFrameDuration = frameRates.maxFrameDuration
                }
            }
            catch {
                print("Could not set active format")
                print(error)
            }
        }
    }

    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = orientation


        // MARK: - Use CPU
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)

        let cameraImage = CIImage(cvImageBuffer: pixelBuffer!)

        let bitmap = cameraImage.toBitmapImage(context: context)

        let result = SegmentingImageAlgorithm.execute(input: bitmap, threshold: 100.0, minSize: 200)
        let processedImage = UIImage.fromBitmapImage(bitmapImage: result!.0)

//        let result = EdgeDetectionAlgorithm.execute(input: bitmap)
//        let processedImage = UIImage.createFromEdgesDetectedBitmap(bitmapImage: result!)


        DispatchQueue.main.async {
            self.filteredImage.image = processedImage
        }




// MARK: - Use CIFilter - TO DO
//        let comicEffect = CIFilter(name: "CIComicEffect")
//
//        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
//        let cameraImage = CIImage(cvImageBuffer: pixelBuffer!)
//
//        comicEffect!.setValue(cameraImage, forKey: kCIInputImageKey)
//
//        let cgImage = self.context.createCGImage(comicEffect!.outputImage!, from: cameraImage.extent)!
//
//        DispatchQueue.main.async {
//            let filteredImage = UIImage(cgImage: cgImage)
//            self.filteredImage.image = filteredImage
//        }


    }
}

