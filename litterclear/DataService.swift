//
//  DataService.swift
//  test-firebase
//
//  Created by Long Thai Nguyen on 12/1/16.
//  Copyright © 2016 Long Thai Nguyen. All rights reserved.
//

import UIKit
import Firebase

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    static let ds = DataService()
    var REF_USER = DB_BASE.child("user_profile")
    var REF_IMAGE = STORAGE_BASE.child("images")
    var REF_REPORTS = DB_BASE.child("reports")
    
    func createUser(uid: String, userData: Dictionary<String, String>) {
        REF_USER.child(uid).updateChildValues(userData)
    }
    
}
