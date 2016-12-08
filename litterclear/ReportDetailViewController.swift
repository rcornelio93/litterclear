//
//  ReportDetailViewController.swift
//  litterclear
//
//  Created by Long Thai Nguyen on 12/6/16.
//  Copyright © 2016 SJSU. All rights reserved.
//

import UIKit
import Firebase

class ReportDetailViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource  {
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var reportImageView: UIImageView!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var severityTextField: UITextField!
    @IBOutlet weak var statusTextField: UITextField!

    var report: Report?
    var image: UIImage?
    var userObj: User?
    
    var statusArray = ["Still there", "Removal claimed", "Removal confirmed"]
    var statusPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let report = report {
            timeTextField.text = report.time
            if let image = image {
                reportImageView.image = image
            } else{
                let ref = FIRStorage.storage().reference(forURL: report.imageURL!)
                    print("Image URL \(report.imageURL!)")
                    ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                 if error != nil {
                    print("Unable to download image from Firebase storage")
                 } else {
                 print("Image downloaded from Firebase storage")
                 if let imgData = data {
                 if let img = UIImage(data: imgData) {
                 
                 //set the image here for forwarding
                 
                 self.reportImageView.image = img
                 
                 }
                 }
                 }
                 })
            }
            addressTextView.text = report.address
            descriptionTextField.text = report.description
            sizeTextField.text = report.size
            severityTextField.text = report.severity
            statusTextField.text = report.status
        }
        
        if let user = userObj {
            // get the userObj verify if it set, set the statusArray for official
            let userRole = user.role
            
            if userRole == "official"{
                statusArray = ["Still there", "Removal claimed"]
            }
            
        }
        
        statusPicker.delegate = self
        statusPicker.dataSource = self
        statusTextField.inputView = statusPicker
        
        self.tabBarController?.tabBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statusArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statusArray.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        statusTextField.text = statusArray[row]
        if statusTextField.text != nil {
            report!.status = statusTextField.text!
        }
        statusTextField.resignFirstResponder()
    }
    
    @IBAction func goBackToReportList(_ sender: UIBarButtonItem) {
        navigationController!.popViewController(animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
