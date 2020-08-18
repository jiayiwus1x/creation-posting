//
//  LoginViewController.swift
//  firebase-app-tutorial
//
//  Created by Vishal Soni on 8/2/20.
//  Copyright © 2020 Vishal Soni. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        // Do any additional setup after loading the view.
        setUpElements()
    }
    
    func setUpElements() {
        
        //Hide error label
        errorLabel.alpha = 0
        
        // Style the elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
        
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
        
        // TODO: validate text fields
        
        // Create cleaned versions of text fields
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // signing in the user
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                //couldn't sign in
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }
            else{
                let user = result?.user
                
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                    switch result {
                    case .success(let data):
                        guard let userData = data as? [String: Any],
                            let firstName = userData["first_name"] as? String,
                            let lastName = userData["last_name"] as? String else {
                                return
                        }
                        UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                        
                    case .failure(let error):
                        print("Failed to read data with error \(error)")
                    }
                })
                
                UserDefaults.standard.set(email, forKey: "email")
                
                print("Logged In User: \(user!)")
                
                self.transitionToHome()
                
                
            }
        }
        
    }
    
    func transitionToHome(){
        let listViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.listViewController ) as! ListViewController
        self.navigationController?.pushViewController(listViewController, animated: true)
        
    }
}
