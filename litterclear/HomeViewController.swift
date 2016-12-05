//
//  HomeViewController.swift
//  litterclear
//
//  Created by Rachita Shetty on 12/4/16.
//  Copyright © 2016 SJSU. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController : UIViewController{
    
    var userUID: String?
    var imageURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "profileSegue" {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            if delegate.userUID != nil {
                print(delegate.userUID!)
                self.userUID = delegate.userUID
                //self.userEmail = delegate.userEmail
            }
            
            //print(GIDSignIn.sharedInstance().currentUser.userID)
            
            let profViewController : ProfileViewController = segue.destination as! ProfileViewController
            profViewController.userUID = self.userUID
        }
    }

    @IBAction func reportLitterAction(_ sender: Any) {

        let reportVC = self.storyboard?.instantiateViewController(withIdentifier: "reportView") as! ReportViewController
        present(reportVC, animated: true, completion: nil)

    }
}
