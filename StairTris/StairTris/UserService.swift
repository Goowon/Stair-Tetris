//
//  UserService.swift
//  EscapeTheFall
//
//  Created by Inho on 7/31/17.
//  Copyright © 2017 Inho Lee. All rights reserved.
//

import FirebaseAuth.FIRUser
import FirebaseDatabase

typealias FIRUser = FirebaseAuth.User

struct UserService {
    static func show(forUID: String, completion: @escaping (User?) -> Void) {
        /* Load every user from the database */
        let ref = Database.database().reference().child("users").child(forUID)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            
            completion(user)
        })
    }
    
    static func create(_ firUser: FIRUser, completion: @escaping (User?) -> Void) {
        /* Create a new user with no adpass */
        let userAttrs = ["adpass" : false]
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            /* Try to load the created user */
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
        
    }
    
    static func removeAds(forUID: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(forUID)
        ref.setValue(["adpass" : true]) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            /* Load the same user, but with adpass changed to true */
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
        }
    }
}
