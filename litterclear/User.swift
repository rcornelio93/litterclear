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
    var isRecvEmailNotiReport: Bool!
    var isRecvEmailNotiStatus: Bool!
    var isReportAnonymously: Bool!
    var role: Role!
    
    init(id: String, email: String, role: Role, recvEmailNotiReport: Bool, recvEmailNotiStatus: Bool, reportAnonymously: Bool) {
        self.id = id
        self.email = email
        self.role = role
        isRecvEmailNotiReport = recvEmailNotiReport
        isRecvEmailNotiStatus = recvEmailNotiStatus
        isReportAnonymously = reportAnonymously
    }
    
    func setReportAnonymously(anonymous: Bool) {
        if anonymous == true {
            isReportAnonymously = true
            isRecvEmailNotiStatus = false
            isRecvEmailNotiReport = false
        }
    }
}
