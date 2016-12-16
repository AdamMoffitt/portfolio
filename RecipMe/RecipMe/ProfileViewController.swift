//
//  ProfileViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 10/29/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var userName: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    
    let imagePicker = UIImagePickerController()
    let sharedRecipMeModel = RecipMeModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        userName.text = sharedRecipMeModel.getMyUser().email
    }
    @IBAction func imageButtonTapped(_ sender: AnyObject) {
        print("CHOOSE PICTURE")
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        print("here")
        
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        
        print("now here")
        present(imagePicker, animated: true, completion: nil)
        
    }
    @IBAction func takePhotoTapped(_ sender: AnyObject) {
        takePicture()
    }
    
    //https://makeapppie.com/2016/06/28/how-to-use-uiimagepickercontroller-for-a-camera-and-photo-library-in-swift-3-0/
    func takePicture(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.cameraCaptureMode = .photo
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker,animated: true,completion: nil)
        }else {
            noCamera()
        }
    }
    
    //https://makeapppie.com/2016/06/28/how-to-use-uiimagepickercontroller-for-a-camera-and-photo-library-in-swift-3-0/
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }

    
    //MARK: UIPICKERCONTROLLER DELEGATE METHODS
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        profilePicture.contentMode = .scaleAspectFit
        profilePicture
            .image = pickedImage
        
        
        dismiss(animated: true, completion: nil)

    }


    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
