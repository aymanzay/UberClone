//
//  SignInVC.swift
//  oovoo_javer
//
//  Created by Ayman Zeine on 6/28/18.
//  Copyright © 2018 Ayman Zeine. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInVC: UIViewController {
    
    private let JAVER_SEGUE = "JaverVC"

    @IBOutlet weak var txtLbl: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    
    @IBAction func logIn(_ sender: Any) {
        if emailTxtField.text != "" && passwordTxtField.text != "" {
            
            AuthProvider.Instance.login(withEmail: emailTxtField.text!, password: passwordTxtField.text!, loginHandler: {(message) in
                
                if message != nil {
                    self.alertTheUser(title: "Problem with authentification", message: message!)
                } else {
                    
                    OovooHandler.Instance.javer = self.emailTxtField.text!
                    self.emailTxtField.text = ""
                    self.passwordTxtField.text = ""
                    
                    self.performSegue(withIdentifier: self.JAVER_SEGUE, sender: nil)
                }
            })
            
        } else {
            alertTheUser(title: "Email and password are required.", message: "Please enter email and password.")
        }
    } //login func
    
    private func alertTheUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signUp(_ sender: Any) {
        
        if emailTxtField.text != "" && passwordTxtField.text != "" {
            
            AuthProvider.Instance.signup(withEmail: emailTxtField.text!, password: passwordTxtField.text!, loginHandler: {(message) in
                
                if message != nil {
                    self.alertTheUser(title: "Problem with creating a new user.", message: message!)
                } else {
                    
                    //refreshing text fields at login
                    OovooHandler.Instance.javer = self.emailTxtField.text!
                    self.emailTxtField.text = ""
                    self.passwordTxtField.text = ""
                    
                    self.performSegue(withIdentifier: self.JAVER_SEGUE, sender: nil)
                }
            })
        } else {
            alertTheUser(title: "Email and password are required.", message: "Please enter email and password.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }

}
