//
//  SignupViewController.swift
//  firebase-app-tutorial
//
//  Created by Vishal Soni on 8/2/20.
//  Copyright © 2020 Vishal Soni. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignupViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setUpElements()
    }
    
    func setUpElements() {
        
        // hide error label
        errorLabel.alpha = 0
        // Style elements
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
        
    }
    
    func validateFields() -> String? {
        //check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
            
        }
        // Check if the password is secure
        let cleanedPasssword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPasssword) == false {
            //password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character, and a number"
        }
        return nil
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        //validate fields
        let error = validateFields()
        
        if error != nil{
            //There is something wrong, show the error message
            showError(error!)
        }
        else{
            
            // create cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            // create user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                // check for errors
                if err != nil {
                    // There was an error creating the user
                    //print(result!.user)
                    self.showError("Error creating user")
                }
                else {
                    // User was created successfully, now store first and last name
                    //                    let db = Firestore.firestore()
                    
                    //                    db.collection("users").addDocument(data: ["firstname":firstName, "lastname":lastName, "uid": result!.user.uid ]) { (error) in
                    //
                    //                        if error != nil {
                    //                            //show error
                    //                            self.showError("error saving user data,")
                    //                        }
                    //                    }
                    UserDefaults.standard.setValue(email, forKey: "email")
                    UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                    DatabaseManager.shared.userExists(with: email, completion: {exists in
                        guard !exists else{
                            self.alertUserLoginError(message: "email exist, try login")
                            return
                        }
                        let appuser = UserDescription(firstName: firstName, lastName: lastName, emailAddress: email)
                        DatabaseManager.shared.insertUser(with: appuser
                            , completion: { success in
                                if success {
                                    
                                }
                                
                        })
                        //transition to the home screen
                        
                        self.transitionToHome()
                    })
                    
                }
            }
        }
    }
    
    func showError(_ message: String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    func alertUserLoginError(message: String){
        let alert = UIAlertController(title:"Woops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func transitionToHome(){
        
        let listViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.listViewController ) as! ListViewController
        self.navigationController?.pushViewController(listViewController, animated: true)
        
    }
    
}
