//
//  ReportDetailViewController.swift
//  litterclear
//
//  Created by Long Thai Nguyen on 12/6/16.
//  Copyright © 2016 SJSU. All rights reserved.
//

import UIKit

class ReportDetailViewController: UIViewController {
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var reportImageView: UIImageView!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var severityTextField: UITextField!
    @IBOutlet weak var statusTextField: UITextField!

    var report: Report?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let report = report {
            timeTextField.text = report.time
            if let image = image {
                reportImageView.image = image
            }
            addressTextView.text = report.address
            descriptionTextField.text = report.description
            sizeTextField.text = report.size
            severityTextField.text = report.severity
            statusTextField.text = report.status
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
