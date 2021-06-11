//
//  ViewController.swift
//  GraphPod
//
//  Created by d.s.vandyshev@gmail.com on 06/09/2021.
//  Copyright (c) 2021 d.s.vandyshev@gmail.com. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loadImageFromLibraryBtnTapped(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary

            present(imagePicker, animated: true, completion: nil)
        }
    }

    private func imagePickerController(
        picker: UIImagePickerController!,
        didFinishPickingImage image: UIImage!,
        editingInfo: NSDictionary!) {
           self.dismiss(animated: true, completion: { () -> Void in

           })
       }
}
