//
//  ReportTableViewCell.swift
//  test-firebase
//
//  Created by Long Thai Nguyen on 12/3/16.
//  Copyright © 2016 Long Thai Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ReportTableViewCell: UITableViewCell {
    @IBOutlet weak var reportImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(report: Report, img: UIImage? = nil) {
        
        
        self.statusLabel.text = report.status
        self.timeLabel.text = report.time
        
        if img != nil {
            self.reportImageView.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: report.imageURL)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("ReportTableViewCell: Unable to download image from Firebase storage")
                } else {
                    print("ReportTableViewCell: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.reportImageView.image = img
                            ReportTableViewController.imageCache.setObject(img, forKey: report.imageURL as NSString)
                        }
                    }
                }
            })
        }
        
    }

}
