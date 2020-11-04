//
//  ViewController.swift
//  DetectObjects
//
//  Created by Yuvraj Vijay Agarkar on 04/11/20.
//

import UIKit
import Vision
import CoreML
class ViewController: UIViewController {
    @IBOutlet weak var label:UILabel!
    @IBOutlet weak var imageView:UIImageView!
    var imagePicker:UIImagePickerController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = "Click Or Select Image"
        // Do any additional setup after loading the view.
    }
    
    func action(){
        let alertController = UIAlertController(title: "make a choice ", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            //            present camera
            self.imagePicker = UIImagePickerController()
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = true
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            //            photo library
            self.imagePicker = UIImagePickerController()
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            //            Cancel pressed
        }
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    @IBAction func cameraTapped(_ sender:UIBarButtonItem){
        action()
    }
    func detect(image:CIImage){
        //    VNCoreMLModel is an container for for coreML model
        do{
            let model = try VNCoreMLModel(for: Inceptionv3().model)
            let request = VNCoreMLRequest(model: model) { (requests, error) in
                guard let results = requests.results as? [VNClassificationObservation] else {
                    return
                }
//                print(results[0])
                self.label.text = results[0].identifier
            }
            let handler = VNImageRequestHandler(ciImage:image)
            try! handler.perform([request])
            
        }catch {
            print("error in VNCoreMLModel:\(error)")
        }
    }
}
extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            print("cannot convert image to UIImage")
            return
        }
        
        self.imageView.image = image
        //        Now create an CIImage so that vision and coreMl can understand our image
        guard  let ciimage = CIImage(image: image) else {
            print("cannot convert to ciimage")
            return
        }
        detect(image: ciimage)
        dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
