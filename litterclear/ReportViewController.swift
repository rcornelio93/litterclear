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
import SendGrid


class ReportViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var severityTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    var size: String = "Small"
    var severity: String = "Minor"
    var latitude: Double = 0
    var longitude: Double = 0
    var address: String = "Fetching address...."
    var sizeArray = ["Small (< 12 inches)", "Median (between 1-3 feet)", "Large (between 3-6 feet)", "Extra-Large (6 or more feet)"]
    var sizePicker = UIPickerView()
    var severityArray = ["Minor", "Medium (please remove soon)", "Urgent (please remove asap)"]
    var severityPicker = UIPickerView()
    
    var imagePickerController = UIImagePickerController()
    
    var image: UIImage?
    var userObj: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        descriptionTextField.delegate = self
        sizePicker.delegate = self
        sizePicker.dataSource = self
        sizePicker.tag = 1
        sizeTextField.inputView = sizePicker
        severityPicker.delegate = self
        severityPicker.dataSource = self
        severityPicker.tag = 2
        severityTextField.inputView = severityPicker
       
            // Ask for Authorisation from the User.
        //self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
      //  locationManager.requestLocation()

        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        //Only allow photos to be taken.
        imagePickerController.sourceType = .camera

        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        if let image = image {
            photoImageView.image = image
            //self.addressLabel.text = self.address
        }
        
        if let userObj = userObj {
            print("id: \(userObj.id) email: \(userObj.email) role: \(userObj.role) reportAnonymously: \(userObj.reportAnonymously)")
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
 
    @IBAction func reportLitter(_ sender: UIButton) {
        
        descriptionTextField.resignFirstResponder()
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func doReport(_ sender: UIButton) {
        let desc = descriptionTextField.text ?? ""
        let size = sizeTextField.text ?? ""
        let severity = severityTextField.text ?? ""
        if (photoImageView.image == nil || desc.isEmpty || size.isEmpty || severity.isEmpty) {
            let screenNameAlert  = UIAlertController(title: "Alert", message: "Please provide valid information for your litter report.", preferredStyle: UIAlertControllerStyle.alert)
            screenNameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
//                self.dismiss(animated: true, completion: nil)
            }))
            self.present(screenNameAlert, animated: true, completion: nil)
        } else {
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
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
                    self.addressLabel.text = self.address
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
        addressLabel.text = self.address
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func sendEmailToUser(report: Report, email:String){
    
    let session = Session()
        session.authentication = Authentication.apiKey("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")
    print("Start sending emails")
    Session.shared.authentication = Authentication.apiKey("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")
    
    //session.authentication = Authentication.apiKey("9wJWd9yzQXi_XlC5HYPrHg")
    //Session.shared.authentication = Authentication.apiKey("9wJWd9yzQXi_XlC5HYPrHg")
    
    
    let personalization = Personalization(recipients: report.email!)
    let plainText = Content(contentType: ContentType.plainText, value: "Hey Dere")
    let htmlText = Content(contentType: ContentType.htmlText, value: "<h3>Report Submitted</h3><br/><br/><b> Report Information:</b><br/><br/> Description: \(report.description!)<br/> Severity: \(report.severity!)<br/> Size: \(report.size!)<br/> Time: \(report.time!)<br/> Email: \(email)<br/> Address: \(report.address!)<br/> Report Status: \(report.status!)<br/><br/><br/><b>Support Team, LitterClear.com<b>")
    let email = Email(
    personalizations: [personalization],
    from: Address("support@litterclear.com"),
    content: [plainText, htmlText],
    subject: "Report Submitted"
    )
    do {
    try Session.shared.send(request: email)
    } catch {
    
    print(error)
    }
    
    }
    func sendReportToFirebase(imgURL: String) {

        let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: DateFormatter.Style.long, timeStyle: DateFormatter.Style.short)
        
        var email = "Anonymous"

        if let userObj = userObj {
            if userObj.reportAnonymously == false {
                email = userObj.email
           
            }
            
            let report = [
                "email": email,
                "imageURL": imgURL,
                "description": descriptionTextField.text!,
                "size": size,
                "severity": severity,
                "time": timestamp,
                "latitude": String(latitude),
                "longitude": String(longitude),
                "address" : self.address,
                "status": "Still there",
                "userId": userObj.id!
            ]
            
            if userObj.reportAnonymously == false {
                email = userObj.email
                
                
                let emailReport = Report(reportKey: userObj.id, reportData: report as Dictionary<String, AnyObject>)
                
                sendEmailToUser(report: emailReport, email:email )
            }
            
            DataService.ds.REF_REPORTS.child(userObj.id).childByAutoId().setValue(report) { (error, ref) in
                if error != nil{
                    print("error is \(error)")
                }else{
                    print("Save successful")
                    let screenNameAlert  = UIAlertController(title: "Report Filed", message: "Your litter report has been successfully filed", preferredStyle: UIAlertControllerStyle.alert)
                    screenNameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(screenNameAlert, animated: true, completion: nil)
                }
            }
        } else {
            print("ERROR: USER IS NIL")
        }
        
        
        //dismiss(animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return sizeArray[row]
        } else {
            return severityArray[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return sizeArray.count
        } else {
            return severityArray.count
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 1 {
            sizeTextField.text = sizeArray[row]
            if sizeTextField.text != nil {
                size = sizeTextField.text!
            }
            sizeTextField.resignFirstResponder()
        } else {
            severityTextField.text = severityArray[row]
            if severityTextField.text != nil {
                severity = severityTextField.text!
            }
            severityTextField.resignFirstResponder()
        }
        
    }

}

