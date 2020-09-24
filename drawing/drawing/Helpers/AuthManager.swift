//
//  AuthManager.swift
//  drawing
//
//  Created by Jiayi Wu on 9/24/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import Foundation
import FirebaseAuth
public class AuthManager{
    static let shared = AuthManager()
    public func logOut(completion: (Bool) -> Void){
        do {
            try Auth.auth().signOut()
            completion(true)
            
        }
        catch{
            print(error)
            completion(false)
            return
        }
    }
}
