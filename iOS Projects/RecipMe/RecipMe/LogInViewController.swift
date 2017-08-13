//
//  LogInViewController.swift
//  RecipMe
//
//  Created by Adam Moffitt on 12/3/16.
//  Copyright © 2016 Adam's Apps. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FBSDKLoginKit

class LogInViewController: UIViewController {

    @IBOutlet var fbLoginButtonView: UIView!
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    let sharedRecipMeModel = RecipMeModel.shared
    let userDefaults = UserDefaults.standard
    
    var validUser = false;
    
    var ref:DatabaseReference?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sharedRecipMeModel.setFireBase(ref: Database.database().reference(fromURL: "https://recipme-a9e2c.firebaseio.com/"))
        
        passwordTextfield.isSecureTextEntry = true
        
        //let fbLoginButton = FBSDKLoginButton()
        //fbLoginButton.center = fbLoginButtonView.center
        //self.view.addSubview(fbLoginButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if( userDefaults.string(forKey: "email") !=  nil ){
            let email = userDefaults.string(forKey: "email")
            let password = userDefaults.string(forKey: "password")
            signIn(email: email!, pass: password!)
        }
    }
    
    func signIn(email: String, pass: String) {
        Auth.auth().signIn(withEmail: email, password: pass, completion: { (user, err) in
            
            if(err != nil ){
                self.error(error: err!.localizedDescription)
            }
            else{
                let newUser = User(email:email)
                let uid = Auth.auth().currentUser?.uid
                newUser.uid = uid!
                Database.database().reference().child("Users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dict = snapshot.value as? [String: AnyObject] {
                        newUser.setUsername((dict["username"] as? String)!)
                        newUser.setEmail((dict["email"] as? String)!)
                        newUser.setFirstName((dict["fname"] as? String)!)
                        newUser.setLastName((dict["lname"] as? String)!)
                        newUser.setCookingLevel((dict["cookingLevel"] as? String)!)
                        newUser.setGender((dict["gender"] as? String)!)
                        newUser.setAge((dict["age"] as? Int)!)
                        if let profilePic = dict["profilePictureImageURL"] as? String {
                            newUser.setProfilePictureImageURL(profilePic)
                        }
                        self.sharedRecipMeModel.setMyUser(newUser:newUser)
                        self.sharedRecipMeModel.loadFromFirebase()
                        self.sharedRecipMeModel.loadFavorites()
                        //How to prevent empty kitchen error being shown because loadFromFirebase loads asynchronously and KitchenTableView is shown before kitchen is loaded. How to add loading screen while kitchen is loaded?
                        
                        self.performSegue(withIdentifier: "LogInSegue", sender: nil)
                    }
                    else {
                        //login failed
                    }
                    
                }, withCancel: nil)
            }
        })
    }

    func error(error: String){
        let alert = UIAlertController(title: "Error",
                                      message: error,
                                      preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Okay",
                                         style: .default)
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)

    }
    
    func checkSignUp(){
        
        //no email or password
        if (emailTextfield.text?.isEmpty)! && (passwordTextfield.text?.isEmpty)! {
            //prompt for both email and password
            error(error: "Enter an email or password!")
            return
        }
            //no email entered
        else if (emailTextfield.text?.isEmpty)! {
            //prompt for email
            error(error:"Enter an email!")
            return
        }
            //no password entered
        else if (passwordTextfield.text?.isEmpty)! {
            //prompt for email
            error(error:"Enter a password!")
            return
        }
        else{
            let email = emailTextfield.text as String!
            let password = passwordTextfield.text as String!
            
            var newUser : Dictionary <String, String>
            
            newUser = [
            "email" : (email)!,
            "password" : (password)!
            ]
            
            //check if email is already taken
            self.ref?.child("Users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists(){
                    
                } else {
                    self.ref?.child("Users").child(email!).setValue(newUser)
                    let nUser = User(email: email!, pw: password!)
                    self.sharedRecipMeModel.setMyUser(newUser: nUser)
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            
        }
        
    }
    
    @IBAction func logInButton(_ sender: AnyObject) {
        if checkLogIn() {
            //set user defaults so user auto logs in next time
            userDefaults.setValue(emailTextfield.text!, forKey: "email")
            userDefaults.setValue(passwordTextfield.text!, forKey: "password")
            self.signIn(email: emailTextfield.text!, pass: passwordTextfield.text!)
        }
    }
    
    func checkLogIn() -> Bool{
        var valid = false
        //no email or password
        if (emailTextfield.text?.isEmpty)! && (passwordTextfield.text?.isEmpty)! {
            //prompt for both email and password
            error(error: "Enter an email or password!")
            return valid
        }
            //no email entered
        else if (emailTextfield.text?.isEmpty)! {
            //prompt for email
            error(error:"Enter an email!")
            return valid
        }
            //no password entered
        else if (passwordTextfield.text?.isEmpty)! {
            //prompt for email
            error(error:"Enter a password!")
            return valid
        }
        else{
            valid = true
            return valid
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextfield {
            passwordTextfield.becomeFirstResponder()
        }
        if textField == passwordTextfield {
            textField.resignFirstResponder()
        }
        return true
    }
}

