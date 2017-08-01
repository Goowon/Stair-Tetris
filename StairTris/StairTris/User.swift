//
//  User.swift
//  EscapeTheFall
//
//  Created by Inho on 7/31/17.
//  Copyright © 2017 Inho Lee. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User: NSObject {
    let uid: String
    let adpass: Bool
    private static var _current: User?
    
    static var current: User? {
        return _current
    }
    
    static func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        if writeToUserDefaults {
            let data = NSKeyedArchiver.archivedData(withRootObject: user)
            UserDefaults.standard.set(data, forKey: "currentUser")
        }
        _current = user
    }
    
    init(uid: String, ads: Bool) {
        self.uid = uid
        self.adpass = ads
        super.init()
    }
    
    init?(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String : Any],
            let ads = dict["adpass"] as? Bool else {
                return nil
        }
        self.uid = snapshot.key
        self.adpass = ads
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let uid = aDecoder.decodeObject(forKey: "UID") as? String else {
                return nil
        }
        
        self.uid = uid
        self.adpass = aDecoder.decodeBool(forKey: "adpass")
        
    }
}

extension User : NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: "UID")
        aCoder.encode(adpass, forKey: "adpass")
    }
}
