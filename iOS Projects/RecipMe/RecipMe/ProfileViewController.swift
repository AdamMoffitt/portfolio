//
//  ProfileViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 10/29/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var firstNameTextField: UITextField!
    
    @IBOutlet var lastNameTextField: UITextField!
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var usernameTextField: UITextField!
    
    @IBOutlet var ageTextField: UITextField!
    
    @IBOutlet var genderTextField: UITextField!
    
    @IBOutlet var cookingLevelTextField: UITextField!
    
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var chooseImageButton: UIButton!
    
    var genders = ["Female", "Male"]
    var cookingLevels = ["What is cooking?", "Intermediate", "Cooking Master"]
    var ages = Array(1...120)
    
    
    let imagePicker = UIImagePickerController()
    let sharedRecipMeModel = RecipMeModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        firstNameTextField.text = sharedRecipMeModel.getMyUser().fname
        lastNameTextField.text = sharedRecipMeModel.getMyUser().lname
        usernameTextField.text = sharedRecipMeModel.getMyUser().username
        emailTextField.text = sharedRecipMeModel.getMyUser().email
        ageTextField.text = String(describing: sharedRecipMeModel.getMyUser().age)
        genderTextField.text = sharedRecipMeModel.getMyUser().gender
        cookingLevelTextField.text = sharedRecipMeModel.getMyUser().cookingLevel
        if let picture = sharedRecipMeModel.getMyUser().profilePicture {
            profilePicture.image = sharedRecipMeModel.getMyUser().profilePicture
        }
        
        let agePickerView = UIPickerView()
        agePickerView.tag = 1
        agePickerView.delegate = self
        ageTextField.inputView = agePickerView
        
        let genderPickerView = UIPickerView()
        genderPickerView.tag = 2
        genderPickerView.delegate = self
        genderTextField.inputView = genderPickerView
        
        let cookingLevelPickerView = UIPickerView()
        cookingLevelPickerView.tag = 3
        cookingLevelPickerView.delegate = self
        cookingLevelTextField.inputView = cookingLevelPickerView
    }
    
    @IBAction func changePasswordButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Change Password",
                                      message: "Enter new password: ",
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in
                                        let oldPassword = alert.textFields![0]
                                        let newPasswordField = alert.textFields![1]
                                        
                                        //TODO: Check if old password is correct password
                                        
                                        //Update password in firebase
                                        
        }
        alert.addTextField { textOldPassword in
            textOldPassword.isSecureTextEntry = true
            textOldPassword.placeholder = "Enter your old password"
        }
        
        alert.addTextField { textNewPassword in
            textNewPassword.isSecureTextEntry = true
            textNewPassword.placeholder = "Enter your new password"
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)

        
    }
    
    @IBAction func imageButtonTapped(_ sender: AnyObject) {
        chooseImageButton.titleLabel?.text = ""
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
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

    @IBAction func dismissKeyboard(_ sender: Any) {
        self.view.resignFirstResponder()
    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        //TODO: Sign Out
        sharedRecipMeModel.handleSignOut()
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        //TODO Settings
    }
    
    
    //MARK: UIPICKERCONTROLLER DELEGATE METHODS
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        profilePicture.contentMode = .scaleAspectFit
        profilePicture
            .image = pickedImage
        self.sharedRecipMeModel.saveUserProfilePic(image: pickedImage)
        
        dismiss(animated: true, completion: nil)

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView.tag == 1 ){
            return ages.count
        } else if(pickerView.tag == 2 ){
            return genders.count
        }else if(pickerView.tag == 3 ){
            return cookingLevels.count
        }
        return 0
    }
    
    // Delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if(pickerView.tag == 1 ){
            return String(describing: ages[row])
        } else if(pickerView.tag == 2 ){
            return genders[row]
        }else if(pickerView.tag == 3 ){
            return cookingLevels[row]
        }
        return "No Title Found"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if(pickerView.tag == 1 ){
            ageTextField.text = String(describing: ages[row])
        } else if(pickerView.tag == 2 ){
            genderTextField.text = genders[row]
            
        }else if(pickerView.tag == 3 ){
            cookingLevelTextField.text = cookingLevels[row]
        }
        pickerView.endEditing(true)
        self.view.resignFirstResponder()
    }
}
