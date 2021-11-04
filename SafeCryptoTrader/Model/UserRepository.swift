//
//  UserRepository.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation
import Firebase
import FirebaseFirestore

class UserRepository {
    
    struct FirestoreConstant {
        static let usersCollection = "users"
        static let userFirstNameField = "firstname"
        static let userLastNameField = "lastname"
        static let userIdField = "uid"
    }
    
    class func createNewUser(
        firstName: String,
        lastName: String,
        userName: String,
        password: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        Auth.auth().createUser(withEmail: userName, password: password) { authResult, error in
            if let error = error {
                completion(false, error)
            } else {
                let db = Firestore.firestore()
                db.collection(FirestoreConstant.usersCollection).addDocument(data: [
                    FirestoreConstant.userFirstNameField: firstName,
                    FirestoreConstant.userLastNameField: lastName,
                    FirestoreConstant.userIdField: authResult!.user.uid
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                        completion(false, err)
                    } else {
                        completion(true, nil)
                    }
                }
            }
        }
    }
    
    class func signIn(
        email: String,
        password: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    class func logout(completion: @escaping (Error?) -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            completion(nil)
        } catch let signOutError as NSError {
            completion(signOutError)
            print("Error signing out: %@", signOutError)
        }
    }
}
