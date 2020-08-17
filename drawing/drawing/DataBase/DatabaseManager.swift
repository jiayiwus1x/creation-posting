//
//  DatabaseManager.swift
//  drawing
//
//  Created by Jiayi Wu on 8/17/20.
//  Copyright © 2020 Jiayi Wu. All rights reserved.
//

import Foundation
import FirebaseDatabase


final class DatabaseManager{
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    static func safeEmail(emailAddress: String) -> String {
           var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
           safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
           return safeEmail
       }
    
}

// Mark: - Account Management

extension DatabaseManager{
    
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)){
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value, with: {snapshot in
            guard ((snapshot.value as? String) != nil) else{
                completion(false)
                return
            }
            
            
            completion(true)
        })
    }
    
    ///Insert new user to database
    public func insertUser(with user: UserDescription, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: { error, _ in
            guard error == nil else {print("failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]]{
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                        ]
                        usersCollection.append(newElement)
                        self.database.child("users").setValue(usersCollection, withCompletionBlock: {error, _ in
                        guard error == nil else{
                            return
                        }
                        completion(true)
                    })
                }
            else{
                let newCollection: [[String: String]] = [
                    [
                    "name": user.firstName + " " + user.lastName,
                    "email": user.safeEmail
                    ]]
                
                    self.database.child("users").setValue(newCollection, withCompletionBlock: {error, _ in
                    guard error == nil else{
                        return
                    }
                    completion(true)
                })
            }
                
            
        })
        
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch

        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "This means blah failed"
            }
        }
    }

}

// fetch data
extension DatabaseManager {

    /// Returns dictionary node at child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }

}


struct UserDescription{
    let firstName: String
    let lastName: String
    let emailAddress: String
    var safeEmail: String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    //let profilePictureUrl: String
}

