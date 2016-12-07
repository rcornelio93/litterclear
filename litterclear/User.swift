//
//  User.swift
//  litterclear
//
//  Created by Long Thai Nguyen on 12/6/16.
//  Copyright © 2016 SJSU. All rights reserved.
//

import Foundation

enum Role {
    case official
    case resident
}

class User {
    
    var id: String!
    var email: String!
    var fullName: String!
    var address: String!
    var notifyOnLitter: Bool!
    var notifyOnStatusChange: Bool!
    var reportAnonymously: Bool!
    var profileImageURL: String!
    var screenName: String!
    var role: Role!
    
    init(userId: String, userData: Dictionary<String, AnyObject>) {

        self.id = userId
        if let email = userData["email"] as? String {
            self.email = email
        }
        if let address = userData["address"] as? String {
            self.address = address
        }
        if let fullName = userData["fullName"] as? String {
            self.fullName = fullName
        }
        if let notifyOnLitter = userData["notifyOnLitter"] as? Bool {
            self.notifyOnLitter = notifyOnLitter
        }
        if let notifyOnStatusChange = userData["notifyOnStatusChange"] as? Bool {
            self.notifyOnStatusChange = notifyOnStatusChange
        }
        if let profileImageURL = userData["profileImageURL"] as? String {
            self.profileImageURL = profileImageURL
        }
        if let reportAnonymously = userData["reportAnonymously"] as? Bool {
            self.reportAnonymously = reportAnonymously
        }
        if let screenName = userData["screenName"] as? String {
            self.screenName = screenName
        }
        
    }
}
