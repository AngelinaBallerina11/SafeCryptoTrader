//
//  UserRepository.swift
//  SafeCryptoTrader
//
//  Created by Angelina Andronova on 04.11.2021.
//

import Foundation
import Firebase
import FirebaseFirestore
import UIKit

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
        completion: @escaping (Error?) -> Void
    ) {
        Auth.auth().createUser(withEmail: userName, password: password) { authResult, error in
            if let error = error {
                completion(error)
            } else {
                let db = Firestore.firestore()
                db.collection(FirestoreConstant.usersCollection).addDocument(data: [
                    FirestoreConstant.userFirstNameField: firstName,
                    FirestoreConstant.userLastNameField: lastName,
                    FirestoreConstant.userIdField: authResult!.user.uid
                ]) { err in
                    completion(err)
                }
            }
        }
    }
    
    class func signIn(
        email: String,
        password: String,
        completion: @escaping (Error?) -> Void
    ) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            completion(error)
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

    class func getUserInfo(completion: @escaping (User?, Error?) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            Firestore.firestore()
                .collection(FirestoreConstant.usersCollection)
                .whereField(FirestoreConstant.userIdField, isEqualTo: currentUser.uid)
                .addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        completion(nil, error)
                        return
                    }
                    let data = document.documents.map { querySnapshot -> User in
                        let data = querySnapshot.data()
                        let firstName = data[FirestoreConstant.userFirstNameField] as? String ?? "N/A"
                        let lastName = data[FirestoreConstant.userLastNameField] as? String ?? "N/A"
                        return User(firstName: firstName, lastName: lastName, email: currentUser.email!, memberSince: currentUser.metadata.creationDate!)
                    }
                    completion(data.first, nil)
                }
        }
    }
}
