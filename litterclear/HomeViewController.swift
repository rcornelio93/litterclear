//
//  HomeViewController.swift
//  litterclear
//
//  Created by Rachita Shetty on 12/4/16.
//  Copyright © 2016 SJSU. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController : UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    var userUID: String?
    var imageURL: URL?
    var userObject: User?

    override func viewDidLoad() {
        super.viewDidLoad()
 
        DataService.ds.REF_USER.child(userUID!).observe(.value, with: { (snapshot) in
            
            
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                self.userObject  =  User(userId: key, userData: userDict)
            }
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare: \(segue.identifier)")
        if segue.identifier == "profileSegue" {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            if delegate.userUID != nil {
                print(delegate.userUID!)
                self.userUID = delegate.userUID
                //self.userEmail = delegate.userEmail
            }
            
            //print(GIDSignIn.sharedInstance().currentUser.userID)
            print("The user id in home view controller is\(userUID)")
            
            let profViewController : ProfileViewController = segue.destination as! ProfileViewController
            profViewController.userUID = self.userUID
        }
    }

    @IBAction func reportLitterAction(_ sender: Any) {

//        let reportVC = self.storyboard?.instantiateViewController(withIdentifier: "reportView") as! ReportViewController
//        present(reportVC, animated: true, completion: nil)
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
        //performSegue(withIdentifier: "showNewReport", sender: self)

    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
       
      //  performSegue(withIdentifier: "showNewReport", sender: self)
        
        let reportVC = self.storyboard?.instantiateViewController(withIdentifier: "reportView") as! ReportViewController
        reportVC.userObj = userObject
        reportVC.image = selectedImage
        present(reportVC, animated: true, completion: nil)

    }

}
