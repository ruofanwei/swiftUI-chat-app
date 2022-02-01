//
//  FirebaseManager.swift
//  SwiftUIFirebaseChat
//
//  Created by ruofan on 2022/2/1.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage


class FirebaseManager: NSObject{
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    static let shared = FirebaseManager()
    
    override init(){
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
}
