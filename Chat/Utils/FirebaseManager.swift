//
//  FirebaseManager.swift
//  Chat
//
//  Created by Darrien Huntley on 12/9/21.
//


import SwiftUI
import Firebase
// i mport FirebaseFirestore

class FirebaseManager: NSObject {
    let auth: Auth
    let storage : Storage
    let firestore : Firestore
    
    static let shared = FirebaseManager()
    

    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
         self.firestore = Firestore.firestore()
        
        super.init()
    }
}


// When installing firebase select : Firebase auth + Firebase Storage
// Install firestore through cocopods

