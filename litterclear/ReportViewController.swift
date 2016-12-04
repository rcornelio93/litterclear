//
//  ViewController.swift
//  test-firebase
//
//  Created by Long Thai Nguyen on 12/1/16.
//  Copyright © 2016 Long Thai Nguyen. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class ReportViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var smallSizeButton: UIButton!
    @IBOutlet weak var mediumSizeButton: UIButton!
    @IBOutlet weak var largeSizeButton: UIButton!
    @IBOutlet weak var extraLargeSizeButton: UIButton!
    @IBOutlet weak var minorSecurityButton: UIButton!
    @IBOutlet weak var mediumSecurityButton: UIButton!
    @IBOutlet weak var urgentSecurityButton: UIButton!
    @IBOutlet weak var addressTextView: UITextView!
    
    let locationManager = CLLocationManager()
    
    var size: String = "Small"
    var security: String = "Minor"
    var latitude: Double = 0
    var longitude: Double = 0
    var address: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let userData = ["name": "Long", "dob": "07/08/1990"]
//        DataService.ds.createUser(uid: "123", userData: userData)
//        
//        DataService.ds.REF_USER.observe(.value, with: { (snapshot) in
//           // let user = snapshot.value as? [String : AnyObject] ?? [:]
//            //print(user)
//            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
//                for snap in snapshot {
//                    print("a: \(snap)")
//                }
//            }
//        })
        descriptionTextField.delegate = self
        
            // Ask for Authorisation from the User.
        //self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
      //  locationManager.requestLocation()

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
 
    @IBAction func reportLitter(_ sender: UIButton) {
        
        descriptionTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be taken.
        imagePickerController.sourceType = .camera
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    @IBAction func doReport(_ sender: UIButton) {
        if let img = photoImageView.image {
            if let imgData = UIImageJPEGRepresentation(img, 0.2) {
                let imgUID = NSUUID().uuidString
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                DataService.ds.REF_IMAGE.child(imgUID).put(imgData, metadata: metadata, completion:  { (metadata, error) in
                    if error != nil {
                        print("DataService: upload image to Firebase Storage failed.")
                    } else {
                        print("DataService: upload image to Firebase Storage successful.")
                        if let downloadURL = metadata!.downloadURL()?.absoluteString {
                            print(downloadURL)
                            self.sendReportToFirebase(imgURL: downloadURL)
                        }
                    }
                })
            }
        }
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            longitude = location.coordinate.longitude;
            latitude = location.coordinate.latitude;
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                
                if let error = error {
                    print("Reverse geocoder failed with error" + error.localizedDescription)
                    return
                }
                
                if let pm = placemarks?[0] {
                    if let street_num = pm.subThoroughfare {
                        self.address = street_num
                    }
                    if let street = pm.thoroughfare {
                        self.address += " " + street
                    }
                    if let city = pm.locality {
                        self.address += ", " + city
                    }
                    if let state = pm.administrativeArea {
                        self.address += ", " + state
                    }
                    if let zipcode = pm.postalCode {
                        self.address += " " + zipcode
                    }
                    if let country = pm.isoCountryCode {
                        self.address += ", " + country
                    }
                    
                    print("ADdRESS: \(self.address)")
                }
                
            })
        }
        print("locations = \(latitude) \(longitude)")
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //restaurantNameLabel.text = textField.text
      //  checkValidMealName()
        
    }
    
    func checkValidMealName() {
        // Disable the Save button if the text field is empty.
        //let text = nameTextField.text ?? ""
        //saveButton.isEnabled = !text.isEmpty
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
      //  saveButton.isEnabled = false
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        // Set address TextViee
        addressTextView.text = self.address
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }

    func sendReportToFirebase(imgURL: String) {
        let report = [
            "imageURL": imgURL,
            "description": descriptionTextField.text!,
            "size": size,
            "security": security,
            "time": String(describing: NSDate()),
            "latitude": String(latitude),
            "longitude": String(longitude), 
            "address" : self.address,
            "status": "removal_claimed"
        ]
        DataService.ds.REF_REPORTS.childByAutoId().setValue(report)
    }
    
    @IBAction func reportSmallSize(_ sender: UIButton) {
        size = "Small"
        smallSizeButton.setTitleColor(UIColor.brown, for: .normal)
        mediumSizeButton.setTitleColor(UIColor.blue, for: .normal)
        largeSizeButton.setTitleColor(UIColor.blue, for: .normal)
        extraLargeSizeButton.setTitleColor(UIColor.blue, for: .normal)
    }
    @IBAction func reportMediumSize(_ sender: UIButton) {
        size = "Medium"
        smallSizeButton.setTitleColor(UIColor.blue, for: .normal)
        mediumSizeButton.setTitleColor(UIColor.brown, for: .normal)
        largeSizeButton.setTitleColor(UIColor.blue, for: .normal)
        extraLargeSizeButton.setTitleColor(UIColor.blue, for: .normal)
        
    }
    @IBAction func reportLargeSize(_ sender: UIButton) {
        size = "Large"
        smallSizeButton.setTitleColor(UIColor.blue, for: .normal)
        mediumSizeButton.setTitleColor(UIColor.blue, for: .normal)
        largeSizeButton.setTitleColor(UIColor.brown, for: .normal)
        extraLargeSizeButton.setTitleColor(UIColor.blue, for: .normal)
        
    }
    @IBAction func reportExtraLargeSize(_ sender: UIButton) {
        size = "Extra Large"
        smallSizeButton.setTitleColor(UIColor.blue, for: .normal)
        mediumSizeButton.setTitleColor(UIColor.blue, for: .normal)
        largeSizeButton.setTitleColor(UIColor.blue, for: .normal)
        extraLargeSizeButton.setTitleColor(UIColor.brown, for: .normal)
    }
    @IBAction func reportMinorSecurity(_ sender: UIButton) {
        security = "Minor"
        minorSecurityButton.setTitleColor(UIColor.brown, for: .normal)
        mediumSecurityButton.setTitleColor(UIColor.blue, for: .normal)
        urgentSecurityButton.setTitleColor(UIColor.blue, for: .normal)
        
    }
    @IBAction func reportMediumSecurity(_ sender: UIButton) {
        security = "Medium"
        minorSecurityButton.setTitleColor(UIColor.blue, for: .normal)
        mediumSecurityButton.setTitleColor(UIColor.brown, for: .normal)
        urgentSecurityButton.setTitleColor(UIColor.blue, for: .normal)
        
    }
    @IBAction func reportUrgentSecurity(_ sender: UIButton) {
        security = "Urgent"
        minorSecurityButton.setTitleColor(UIColor.blue, for: .normal)
        mediumSecurityButton.setTitleColor(UIColor.blue, for: .normal)
        urgentSecurityButton.setTitleColor(UIColor.brown, for: .normal)
        
    }

}

