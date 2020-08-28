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
    static func GetImgPath(email: String) -> String{
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let path = "images/profileImg/" + safeEmail + "_profile_pic"
        return path
    }
    static func get_Date()-> (Date, String){
           let now = Date()
           let formatter = DateFormatter()
           formatter.dateStyle = .short
           formatter.timeStyle = .short
        return (now, formatter.string(from: now))
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
            "last_name": user.lastName,
            "follower": user.follower,
            "following": user.following,
            "creato": user.creato
            ], withCompletionBlock: { error, _ in
                guard error == nil else {print("failed to write to database")
                    completion(false)
                    return
                }
                
                self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                    if var usersCollection = snapshot.value as? [[String: String]]{
                        let formatter = DateFormatter()
                        formatter.dateStyle = .short
                        formatter.timeStyle = .short
                        let newElement = [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail,
                            "creation date": formatter.string(from: Date())
                            
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
    /// Gets all users from database
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else {
                
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value as! [[String : String]]))
        })
    }
    
    public func getAProject(postingModel: CreationPost, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        
        let postingSafeEmail = DatabaseManager.safeEmail(emailAddress: postingModel.email)
        
        database.child("SharedProjects").queryOrdered(byChild: "ID").queryEqual(toValue: postingModel.Id).observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? NSArray else{
                
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            guard let obj = value.lastObject as? [String: Any] else{
          
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(obj))
        })
        
    }
    public func addCollection(obj: [String: Any], collectionName: String){
        database.child(collectionName).observeSingleEvent(of: .value, with: { snapshot in
            if var usersCollection = snapshot.value as? [[String: Any]]{
                
                usersCollection.append(obj)
                
                self.database.child(collectionName).setValue(usersCollection, withCompletionBlock: {error, _ in
                    guard error == nil else{
                        return
                    }
                })
            }
            else{
                print("database not exists!")
                let newCollection: [[String: Any]] = [
                    obj] as [[String : Any]]
                
                self.database.child(collectionName).setValue(newCollection, withCompletionBlock: {error, _ in
                    guard error == nil else{
                        return
                    }
                })
            }
        })
    }
    public func ImgToCloud(path: String, imageData: Data, completion: @escaping (Result<Any, Error>) -> Void){
        
    }
   
}




//data objects for profile/postings/projects/
struct UserDescription{
    let firstName: String
    let lastName: String
    let emailAddress: String
    let follower: [String]
    let following: [String]
    let creato: Int
    var safeEmail: String{
        let safeEmail = DatabaseManager.safeEmail(emailAddress: emailAddress)
        return safeEmail
    }
    
    var profilePictureUrl: String {
        return "images/profileImg/\(safeEmail)_profile_pic"
    }
    
}

struct Project{
    let Id: String
    let Image: Data
    let linecolor: [String]
    let lineop: [Float]
    let linewidth: [Float]
    let pos: [String]
    let ind: [Int]
    let imageurl: String
    //let IdList: [String]
    
}

struct CreationPost {
    let Id: String
    let numberOfRecreate: Int
    let username: String
    let email: String
    let postImage: UIImage
    let descriptiontext: String
    let timestamp: String
    var profilePictureUrl: String {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return "images/profileImg/\(safeEmail)_profile_pic"
    }
}

struct SearchResult {
    let name: String
    let email: String
}

//class SavedItem: Object {
//    @objc dynamic var title: String = ""
//    @objc dynamic var project: Data = Data()
//
//    let linecolor = List<String>()
//    let linewidth = List<Float>()
//    let lineop = List<Float>()
//    let pos = List<String>()
//    let ind = List<Int>()
//
//    //@objc dynamic var lines: Data = Data()
//    //@objc dynamic var lines: AnyClass = [TouchPointsAndColor]()
//}
