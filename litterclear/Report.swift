//
//  Report.swift
//  test-firebase
//
//  Created by Long Thai Nguyen on 12/2/16.
//  Copyright © 2016 Long Thai Nguyen. All rights reserved.
//

import Foundation

public class Report {
    var address: String!
    var description: String!
    var imageURL: String!
    var latitude: String!
    var longitude: String!
    var severity: String!
    var size: String!
    var time: String!
    var status: String!
    var reportKey: String!
    
    init(reportKey: String, reportData: Dictionary<String, AnyObject>) {
        self.reportKey = reportKey
        //print("init Report: \(self.reportKey)")
        if let address = reportData["address"] as? String {
            self.address = address
        }
        
        if let description = reportData["description"] as? String {
            self.description = description
        }
        
        if let imageURL = reportData["imageURL"] as? String {
            self.imageURL = imageURL
        }
        
        if let latitude = reportData["latitude"] as? String {
            self.latitude = latitude
        }
        
        if let longitude = reportData["longitude"] as? String {
            self.longitude = longitude
        }
        
        if let severity = reportData["severity"] as? String {
            self.severity = severity
        }
        
        if let size = reportData["size"] as? String {
            self.size = size
        }
        
        if let time = reportData["time"] as? String {
            self.time = time
        }
        
        if let status = reportData["status"] as? String {
            self.status = status
        }
        
    }
}
