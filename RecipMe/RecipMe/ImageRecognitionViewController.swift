//
//  ImageRecognitionViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 2/2/17.
//  Copyright © 2017 Adam's Apps. All rights reserved.
//

import UIKit

//Project Leader: Hexi

/* The purpose of this view controller is to use image recognition software (currently exploring the Clarifai Food Recognition API) to allow the user to take a picture / video of his food items and have the app recognize the food and the quantity, and add that food to the user's kitchen. After "recognizing" the food, the app should show an alert asking the user to confirm that the food item has been correctly identified */
class ImageRecognitionViewController: UIViewController {

    @IBOutlet var hexisLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load the camera fragment
        
        //create the parsing list
        
        //  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
        //var app = ClarifaiApp(appID: "mmov8Ui6OylpvNC6ew45BLPJcKogEjuVoDzvfeMZ", appSecret: "NCi0SSp1YD3mYtRnWQTe7bizxgJPsZKbUoEKd5lH")
        //var image = ClarifaiImage(url: "https://samples.clarifai.com/food.jpg")
        /*
        app?.getModelByName("food-items-v1.0", completion: {(_ model: ClarifaiModel, _ error: Error) -> Void in
            model.predict(on: [image!], completion: {_ outputs: ClarifaiPredictionsCompletion, _ error: Error) -> Void in
                print("outputs: \(outputs)")
            })
        })*/
    }
    
    
    
    
    @IBAction func myAction(_ sender: Any) {
        
    }
//    
//    @IBAction func imageButtonTapped(_ sender: AnyObject) {
//        print("CHOOSE PICTURE")
//        chooseImageButton.titleLabel?.text = ""
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .photoLibrary
//        print("here")
//        
//        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
//        
//        print("now here")
//        present(imagePicker, animated: true, completion: nil)
//        
//    }
//    
//    @IBAction func takePhotoTapped(_ sender: AnyObject) {
//        takePicture()
//    }
//    
//    //https://makeapppie.com/2016/06/28/how-to-use-uiimagepickercontroller-for-a-camera-and-photo-library-in-swift-3-0/
//    func takePicture(){
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            imagePicker.allowsEditing = false
//            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
//            imagePicker.cameraCaptureMode = .photo
//            imagePicker.modalPresentationStyle = .fullScreen
//            present(imagePicker,animated: true,completion: nil)
//        }else {
//            noCamera()
//        }
//    }
//    
//    //https://makeapppie.com/2016/06/28/how-to-use-uiimagepickercontroller-for-a-camera-and-photo-library-in-swift-3-0/
//    func noCamera(){
//        let alertVC = UIAlertController(
//            title: "No Camera",
//            message: "Sorry, this device has no camera",
//            preferredStyle: .alert)
//        let okAction = UIAlertAction(
//            title: "OK",
//            style:.default,
//            handler: nil)
//        alertVC.addAction(okAction)
//        present(
//            alertVC,
//            animated: true,
//            completion: nil)
//    }
//
//    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
