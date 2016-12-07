//
//  ProfileViewController.swift
//  litterclear
//
//  Created by Rachita Shetty on 12/3/16.
//  Copyright © 2016 SJSU. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase

class ProfileViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var userUID: String?
    var imageURL: URL?
    var userObject: User?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var litterNotificationSwitch: UISwitch!
    @IBOutlet weak var statusChangeNotificationSwitch: UISwitch!
    
    @IBOutlet weak var reportAnonymousSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profileImageView.isUserInteractionEnabled = true
        
        
        print("the user id is \(userUID!)")
        
        DataService.ds.REF_USER.child(userUID!).observe(.value, with: { (snapshot) in
            
            
                    if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                        print("coming inside found object")
                        let key = snapshot.key
                        self.userObject  =  User(userId: key, userData: userDict)
                        print("the user object address is \(self.userObject?.address)")
                        if let address = self.userObject?.address {
                            self.addressLabel.text = address
                        }
                        if let screenName = self.userObject?.screenName {
                            self.screenNameLabel.text = screenName
                        }
                        if let fullName = self.userObject?.fullName {
                            self.fullNameLabel.text = fullName
                        }
                        if let profileImageURL = self.userObject?.profileImageURL {
                            //self.fullNameLabel.text = fullName
                            //imageURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/litterclear.appspot.com/o/profile_images%2F98591031-2C37-4DEF-9A15-4AE9D709FC6B?alt=media&token=87918a63-3190-4cfb-afd6-6d19f23a1578")
                            
                            self.imageURL = URL(string: profileImageURL)
                            //URLSession.shared.
                            URLSession.shared.dataTask(with: self.imageURL!, completionHandler: { (data, response, error) in
                                if error != nil {
                                    print (error!)
                                    return
                                }
                                
                                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                                    //let image = imageURL
                                    // Bounce back to the main thread to update the UI
                                    
                                    DispatchQueue.main.async {
                                        self.profileImageView.image = UIImage(data: data!)
                                    }
                                }
                                
                                
                            }).resume()

                        }
                        if let notifyOnLitter = self.userObject?.notifyOnLitter {
                            self.litterNotificationSwitch.isOn = notifyOnLitter
                        }
                        if let notifyOnStatusChange = self.userObject?.notifyOnStatusChange {
                            self.statusChangeNotificationSwitch.isOn = notifyOnStatusChange
                        }
                        if let reportAnonymously = self.userObject?.reportAnonymously {
                            self.reportAnonymousSwitch.isOn = reportAnonymously
                        }

                    } else {
                        print("handling a new user scenario ?? ")
                        
                    }
            
        })

        //print("the user object address is \(userObject?.address)")
        //print("the user object full name is \(userObject?.fullName)")
    }

    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated:  true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
       
        var selectedImageFromPicker : UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }else if let origImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = origImage
        } else{
            print("Something went wrong")
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        let storageRef = FIRStorage.storage().reference().child("profile_images").child(NSUUID().uuidString+".png")
        
        if let uploadData = UIImagePNGRepresentation(profileImageView.image!){
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                }else {
                    print(metadata?.downloadURL()?.absoluteString)
                    let values = ["profileImageURL" : metadata?.downloadURL()?.absoluteString]
                    self.updateUserProfile(uid: self.userUID!, values: values as! [String : String])
                    self.userObject  =  User(userId: self.userUID!, userData: values as Dictionary<String, AnyObject>)
                }
            })
        }
        
        dismiss(animated: true, completion: nil)

    }
    
    private func updateUserProfile(uid: String, values: [String: String]){
        let ref = FIRDatabase.database().reference(fromURL: "https://litterclear.firebaseio.com/")
        let usersRef = ref.child("user_profile").child(uid)
        print("The value is \(values)")
        usersRef.updateChildValues(values , withCompletionBlock: {(err, ref) in
            if let error = err  {
                print ("There was an error while updating the database \(error)")
                return
            }
        })
    }

    private func updateUserProfile(uid: String, values: [String: NSNumber]){
        let ref = FIRDatabase.database().reference(fromURL: "https://litterclear.firebaseio.com/")
        let usersRef = ref.child("user_profile").child(uid)
        print("The value is \(values)")
        usersRef.updateChildValues(values , withCompletionBlock: {(err, ref) in
            if let error = err  {
                print ("There was an error while updating the database \(error)")
                return
            }
        })
    }

    @IBAction func screenNameEditAlert(_ sender: Any) {

        let screenNameAlert  = UIAlertController(title: "Screen Name", message: "Please enter your screen name", preferredStyle: UIAlertControllerStyle.alert)
        
        screenNameAlert.addTextField { (textField) in
        }
        
        screenNameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let textField = screenNameAlert.textFields![0] as UITextField
            self.screenNameLabel.text = textField.text!
            let values = ["screenName" : self.screenNameLabel.text]
            self.updateUserProfile(uid: self.userUID!, values: values as! [String : String])
            self.userObject  =  User(userId: self.userUID!, userData: values as Dictionary<String, AnyObject>)

        }))
        
        screenNameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
           // self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(screenNameAlert, animated: true, completion: nil)
    }
    
    @IBAction func fullNameEditAlert(_ sender: Any) {
 
        let fullNameAlert  = UIAlertController(title: "Name", message: "Please enter your first name followed by last name", preferredStyle: UIAlertControllerStyle.alert)
        
        fullNameAlert.addTextField { (textField) in
        }
        
        fullNameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let textField = fullNameAlert.textFields![0] as UITextField
            self.fullNameLabel.text = textField.text!
            let values = ["fullName" : self.fullNameLabel.text]
            self.updateUserProfile(uid: self.userUID!, values: values as! [String : String])
            self.userObject  =  User(userId: self.userUID!, userData: values as Dictionary<String, AnyObject>)
        }))
        
        fullNameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            //self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(fullNameAlert, animated: true, completion: nil)

    }
    
    @IBAction func toggleNotificationOnLitter(_ sender: Any) {
        let values = ["notifyOnLitter" : litterNotificationSwitch.isOn]
        self.updateUserProfile(uid: self.userUID!, values: values as [String : NSNumber])
        userObject  =  User(userId: self.userUID!, userData: values as Dictionary<String, AnyObject>)
    }
    
    @IBAction func toggleNotificationOnStatusChange(_ sender: Any) {
        let values = ["notifyOnStatusChange" : statusChangeNotificationSwitch.isOn]
        self.updateUserProfile(uid: self.userUID!, values: values as [String : NSNumber])
        userObject  =  User(userId: self.userUID!, userData: values as Dictionary<String, AnyObject>)
    }
    
    @IBAction func toggleReportAnonymously(_ sender: Any) {
        var values = ["reportAnonymously" : reportAnonymousSwitch.isOn]
        if reportAnonymousSwitch.isOn {
            litterNotificationSwitch.setOn(false, animated: true)
            statusChangeNotificationSwitch.setOn(false, animated: true)
            values = ["notifyOnLitter" : false, "notifyOnStatusChange": false, "reportAnonymously": reportAnonymousSwitch.isOn]
        }
        
        self.updateUserProfile(uid: self.userUID!, values: values as [String : NSNumber])
        userObject  =  User(userId: self.userUID!, userData: values as Dictionary<String, AnyObject>)
        print("printing user report anonymous \(userObject?.reportAnonymously)")
    }
    
    @IBAction func addressEditAlert(_ sender: Any) {

        let addressAlert  = UIAlertController(title: "Address", message: "Please enter your address", preferredStyle: UIAlertControllerStyle.alert)
        
        addressAlert.addTextField { (textField) in
        }
        
        addressAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let textField = addressAlert.textFields![0] as UITextField
            self.addressLabel.text = textField.text!
            let values = ["address" : self.addressLabel.text!]
            print("The new value of text is \(self.addressLabel.text!)")
            self.updateUserProfile(uid: self.userUID!, values: values )
            self.userObject  =  User(userId: self.userUID!, userData: values as Dictionary<String, AnyObject>)
        }))
        
        addressAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            //self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(addressAlert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled picker")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func myReportsAction(_ sender: Any) {
//        let reportVC = self.storyboard?.instantiateViewController(withIdentifier: "filedReports") as! ReportTableViewController
//        present(reportVC, animated: true, completion: nil)
        performSegue(withIdentifier: "showReportList", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showReportList" {
            let uiTabBarController = segue.destination as! UITabBarController
            let navVC = uiTabBarController.viewControllers?.first as! UINavigationController
            let reportTableViewController = navVC.viewControllers.first as! ReportTableViewController
            reportTableViewController.userObj = userObject
            
            let navVC2 = uiTabBarController.viewControllers?[1] as! UINavigationController
            let reportMapViewController = navVC2.viewControllers.first as! ReportMapViewController
            reportMapViewController.userObj = userObject
        }
    }

    @IBAction func backToLandingView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
