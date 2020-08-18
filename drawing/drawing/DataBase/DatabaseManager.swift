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
    
    public func insertPosting(with posting: Posting, completion: @escaping (Bool) -> Void){
        database.child("latest_posting").setValue([
            "email": posting.emailAddress,
            "userID": posting.userID,
            "ImageURL": posting.ImagURL,
            "Description": posting.discription,
            "Time": posting.time,
            "numberOfRecreate": posting.numberOfRecreate
            ], withCompletionBlock: { error, _ in
                guard error == nil else {print("failed to write to database")
                    completion(false)
                    return
                }
                
                self.database.child("posting").observeSingleEvent(of: .value, with: { snapshot in
                    if var usersCollection = snapshot.value as? [[String: Any]]{
                        let newElement = [
                           "email": posting.emailAddress,
                            "userID": posting.userID,
                            "ImageURL": posting.ImagURL,
                            "Description": posting.discription,
                            "Time": posting.time,
                            "numberOfRecreate": posting.numberOfRecreate
                            ] as [String : Any]
                        usersCollection.append(newElement)
                        self.database.child("posting").setValue(usersCollection, withCompletionBlock: {error, _ in
                            guard error == nil else{
                                return
                            }
                            completion(true)
                        })
                    }
                    else{
                        let newCollection: [[String: Any]] = [
                            [
                                "email": posting.emailAddress,
                                "userID": posting.userID,
                                "ImageURL": posting.ImagURL,
                                "Description": posting.discription,
                                "Time": posting.time,
                                "numberOfRecreate": posting.numberOfRecreate
                            ]] as [[String : Any]]
                        
                        self.database.child("postings").setValue(newCollection, withCompletionBlock: {error, _ in
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
    /// Gets all users from database
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
}

//data structure for individual post
struct UserDescription{
    let firstName: String
    let lastName: String
    let emailAddress: String
    var safeEmail: String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureUrl: String {
        return "/profileImg/\(safeEmail)_profile_pic"
    }
}


struct Posting{
    let emailAddress: String
    let userID: String
    let ImagURL: String
    let discription: String
    let time: String
    let numberOfRecreate: Int
    var safeEmail: String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    
}
