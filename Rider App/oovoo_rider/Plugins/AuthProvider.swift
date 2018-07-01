//
//  AuthProvider.swift
//  oovoo_javer
//
//  Created by Ayman Zeine on 6/28/18.
//  Copyright © 2018 Ayman Zeine. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ message: String?) -> Void

struct LoginErrorCode {
    static let INVALID_EMAIL = "Invalid email address, try again."
    static let WRONG_PASSWORD = "Incorrect password, try again."
    static let PROBLEM_CONNECTING = "Problem connecting to database."
    static let USER_NOT_FOUND = "User not found, register."
    static let EMAIL_ALREADY_IN_USE = "Email already in use, try a different email."
    static let WEAK_PASSWORD = "Password is too weak, your password must fit the criteria."
}

//singleton class
class AuthProvider {
    private static let _instance = AuthProvider()
    
    static var Instance: AuthProvider {
        return _instance
    }
    
    func login(withEmail: String, password: String, loginHandler: LoginHandler?) {
        
        Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
            
            if error != nil { //error logging in
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler)
            } else {
                loginHandler?(nil)
            }
        })
    } //login func
    
    func signup(withEmail: String, password: String, loginHandler: LoginHandler?) {
        
        Auth.auth().createUser(withEmail: withEmail, password: password, completion: { (user, error) in
            
            if error != nil { //error creating user
                self.handleErrors(err: error! as NSError, loginHandler: loginHandler);
            } else {
                
                let userID = Auth.auth().currentUser!.uid
                
                if userID != nil {
                    
                    //store the user in database
                    DBProvider.Instance.saveUser(withID: userID, email: withEmail, password: password)
                    
                    //sign in the user
                    self.login(withEmail: withEmail, password: password, loginHandler: loginHandler)
                }
            }
        })
    } //signup func
    
    func logOut() -> Bool {
        
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut();
                    return true
                } catch {
                    return false
                }
            }
        
        return true
    }
    
    private func handleErrors(err: NSError, loginHandler: LoginHandler?) {
        
        if let errCode = AuthErrorCode(rawValue: err.code) {
            switch errCode {
            case .wrongPassword:
                loginHandler?(LoginErrorCode.WRONG_PASSWORD)
            case .invalidEmail:
                loginHandler?(LoginErrorCode.INVALID_EMAIL)
            case .userNotFound:
                loginHandler?(LoginErrorCode.USER_NOT_FOUND)
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorCode.EMAIL_ALREADY_IN_USE)
            case .weakPassword:
                loginHandler?(LoginErrorCode.WEAK_PASSWORD)
            default:
                loginHandler?(LoginErrorCode.PROBLEM_CONNECTING)
            }
        }
        
    } //handler func
    
}
