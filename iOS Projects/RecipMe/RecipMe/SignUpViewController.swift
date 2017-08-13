//
//  SignUpViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 12/16/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var genderTextField: UITextField!
    @IBOutlet var cookingLevelTextField: UITextField!
    @IBOutlet var genderPickerView: UIPickerView!
    
    var fName : String?
    var lName : String?
    var email : String?
    var password : String?
    var username : String?
    var age : Int?
    var gender : String?
    var cookingLevel : String?
    
    let sharedRecipMeModel = RecipMeModel.shared
    
    var genders = ["Female", "Male"]
    var cookingLevels = ["What is cooking?", "Intermediate", "Cooking Master"]
    var ages = Array(1...120)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func signUpAction(_ sender: Any) {
        
        if checkSignUp() {
            
            fName = firstNameTextField.text
            lName = lastNameTextField.text
            email = emailTextField.text
            password = passwordTextField.text
            username = usernameTextField.text
            age = Int(ageTextField.text!)
            gender = genderTextField.text //?[(genderTextField.text?.startIndex)!]
            cookingLevel = cookingLevelTextField.text
            
            addAcount(username: username!, pass: password!, email: email!, fname: fName!,  lname: lName!, age: age!, gender: gender!, cookingLevel:cookingLevel!)
            
            //set user defaults so user auto logs in next time
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(email, forKey: "email")
            userDefaults.setValue(password, forKey: "password")
        }
        
    }
    
    
    func checkNext() -> Bool {
        if (firstNameTextField.text?.isEmpty)! {
            error(error: "Don't forget to enter your first name!")
        }
        else if (lastNameTextField.text?.isEmpty)!{
            error(error: "Don't forget to enter you last name!")
        }
        else if (emailTextField.text?.isEmpty)!{
            error(error: "Don't forget to enter your email!")
        }
        else if (passwordTextField.text?.isEmpty)!{
            error(error: "Don't forget to enter a password!")
        }
        else if (confirmPasswordTextField.text?.isEmpty)!{
            error(error: "Don't forget to confirm your password!")
        }
        else if passwordTextField.text != confirmPasswordTextField.text {
            error(error: "Hmm... Looks like your passwords don't match. Check to make sure that they are the same!")
        } else {
            
            fName = firstNameTextField.text
            lName = lastNameTextField.text
            email = emailTextField.text
            password = passwordTextField.text
            return true
        }
        return false
    }
    
    func checkSignUp() -> Bool {
        if (firstNameTextField.text?.isEmpty)! {
            error(error: "Don't forget to enter your first name!")
        }
        else if (lastNameTextField.text?.isEmpty)!{
            error(error: "Don't forget to enter you last name!")
        }
        else if (emailTextField.text?.isEmpty)!{
            error(error: "Don't forget to enter your email!")
        }
        else if (passwordTextField.text?.isEmpty)!{
            error(error: "Don't forget to enter a password!")
        }
        else if (usernameTextField.text?.isEmpty)!{
            error(error: "Don't forget to create a username!")
        }
        else{
            return true
        }
        return false
    }
    
    //Function to pass in an error message and pop up a simple error alert message
    func error(error: String){
        let alert = UIAlertController(title: "Error",
                                      message: error,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Okay",
                                         style: .default)
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func addAcount(username: String, pass: String, email: String, fname: String,
                   lname: String, age: Int, gender: String, cookingLevel: String){
        
        Auth.auth().createUser(withEmail: email, password: pass, completion: { (user, err) in
            if(err != nil){
                self.error(error: err!.localizedDescription)
                return
            }
            
            guard let uid = user?.uid else{
                return
            }
            
            //successfully authenticated user
            
            let ref = Database.database().reference(fromURL: "https://recipme-a9e2c.firebaseio.com/")
            
            let usersRef = ref.child("Users").child(uid)
            let values = ["fname": fname, "lname": lname, "email": email, "username": username,
                          "age": age, "gender": gender, "cookingLevel": cookingLevel] as [String : Any]
            
            usersRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if(err != nil){
                    self.error(error: err!.localizedDescription)
                }
                
                let newUser = User(username:username, pass:pass, email:email, fname:fname,
                                   lname:lname, age:age, gender:gender, cookingLevel: cookingLevel)
                
                self.sharedRecipMeModel.setMyUser(newUser: newUser)
                
                self.performSegue(withIdentifier: "SignUpSegue", sender: nil)
            })
        })
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        genderPickerView.isHidden = false
        return false
    }
    
}


