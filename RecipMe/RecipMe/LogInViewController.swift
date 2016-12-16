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

class LogInViewController: UIViewController {

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
     let sharedRecipMeModel = RecipMeModel.shared
    
    var validUser = false;
    
    var ref:FIRDatabaseReference?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextfield.isSecureTextEntry = true
        ref = FIRDatabase .database().reference()
        
//        FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
//            if user != nil {
//                self.sharedRecipMeModel.setMyUser(newUser: User(userID: (user?.uid)!, email: (user?.email!)!))
//                self.performSegue(withIdentifier: "LogInSegue", sender: nil)
//            }
//        }

    }
    
    
    @IBAction func signUpButton(_ sender: AnyObject) {

       //checkSignUp()
        
        
        let alert = UIAlertController(title: "Sign Up",
                                      message: "Let's make an account so you can get cooking!",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) { action in
                                        let emailField = alert.textFields![0]
                                        let passwordField = alert.textFields![1]
                                        
                                        FIRAuth.auth()!.createUser(withEmail: emailField.text!,
                                                                   password: passwordField.text!) { user, error in
                                                                    if error == nil {
                                                                        FIRAuth.auth()!.signIn(withEmail: self.emailTextfield.text!,
                                                                                               password: self.passwordTextfield.text!)
                                                                    }
                                                                    self.performSegue(withIdentifier: "LogInSegue", sender: nil)

                                                                    self.sharedRecipMeModel.addUser(email: emailField.text!)
                                        }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
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
        
        print("Sign Up")
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
            print("Lets add you to the database")
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
                    print("email exists")
                    
                } else {
                    print("email doesnt exist")
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
        if(checkLogIn()) {
        FIRAuth.auth()!.signIn(withEmail: emailTextfield.text!,
                               password: passwordTextfield.text!)
            
        self.performSegue(withIdentifier: "LogInSegue", sender: nil)
        }
    }
    
    func checkLogIn() -> Bool{
        print("Log In")
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
        else{ // check if user exists
            valid = true
            print("Lets see if you are in the database")
            let email = emailTextfield.text as String!
            let password = passwordTextfield.text as String!
        
            if(sharedRecipMeModel.getUsers().contains(email!)){
                self.sharedRecipMeModel.setMyUser(newUser: User(email: email!, pw: password!))
                return true
            }
            else {
                error(error: "Incorrect username or password")
                return false
            }
        }
        return valid

    }

//    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
//        if(identifier == "LogInSegue"){
//            print("Let's check if user is valid before segue!")
//                checkLogIn()
//                return self.validUser
//        }
//        else {
//            print("not log in segue")
//         return true
//        }
//    }
    
}


extension LogInViewController: UITextFieldDelegate {
    
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

