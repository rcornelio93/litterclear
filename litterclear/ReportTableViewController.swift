//
//  ReportTableViewController.swift
//  test-firebase
//
//  Created by Long Thai Nguyen on 12/3/16.
//  Copyright © 2016 Long Thai Nguyen. All rights reserved.
//

import UIKit
import Firebase
import SendGrid

class ReportTableViewController: UITableViewController,UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    
    var reports = [Report]()
    var baseReports = [Report]()
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var userObj: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        searchBar.delegate = self
        
        if let userObj = userObj {
            print("id: \(userObj.id) email: \(userObj.email) role: \(userObj.role) reportAnonymously: \(userObj.reportAnonymously)")
            
            if userObj.role == "resident" {
                navigationItem.title = "My Reports"
                
                DataService.ds.REF_REPORTS.child(userObj.id).observe(.value, with: { (snapshot) in
                    
                    self.baseReports = [] // THIS IS THE NEW LINE
                    
                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        for snap in snapshot {
                            print("SNAP: \(snap)")
                            if let reportDict = snap.value as? Dictionary<String, AnyObject> {
                                let key = snap.key
                                let report = Report(reportKey: key, reportData: reportDict)
                                self.baseReports.append(report)
                            }
                        }
                    }
                    self.reports = []
                    
                    for report in self.baseReports {
                        self.reports.append(report)
                    }
                    print("reports size \(self.reports.count) baseReport size \(self.baseReports.count)")
                    
                    self.tableView.reloadData()
                })
            } else { //officer
                navigationItem.title = "All Resident Reports"
                
                DataService.ds.REF_REPORTS.observe(.value, with: { (snapshot) in
                    
                    self.baseReports = [] // THIS IS THE NEW LINE
                    
                    if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        for snap in snapshot {
                            print("SNAP: \(snap)")
                            if let subsnap = snap.children.allObjects as? [FIRDataSnapshot] {
                                for sub in subsnap {
                                    if let reportDict = sub.value as? Dictionary<String, AnyObject> {
                                        let key = sub.key
                                        let report = Report(reportKey: key, reportData: reportDict)
                                        self.baseReports.append(report)
                                    }
                                }
                            }
                        }
                    }
                    self.reports = []
                    
                    for report in self.baseReports {
                        self.reports.append(report)
                    }
                    print("reports size \(self.reports.count) baseReport size \(self.baseReports.count)")
                    
                    self.tableView.reloadData()
                    
                })
            }
        
        } else {
            print("ERROR: USER IS NIL")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("number of row: \(self.reports.count)")
        return self.reports.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ReportTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ReportTableViewCell

        // Configure the cell...
        let report = reports[indexPath.row]
        
        if let img = ReportTableViewController.imageCache.object(forKey: report.imageURL as NSString) {
            cell.configureCell(report: report, img: img)
        } else {
            cell.configureCell(report: report)
        }

        return cell
    }
    
    //MARK: search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("search: \(searchText)")
        var tempReport = [Report]()
        for report in baseReports {
            if let userObj = userObj {
                if userObj.role == "official" {
                    if report.email.lowercased().contains(searchText.lowercased()) || report.status.lowercased().contains(searchText.lowercased()) {
                        tempReport.append(report)
                    }
                } else {
                    if report.status.lowercased().contains(searchText.lowercased()) {
                        tempReport.append(report)
                    }
                }
            }
        }
        print("[searchBar] tempReport size: \(tempReport.count)")
        if tempReport.count > 0 {
            reports = tempReport
        } else if searchText == "" {
            reports = baseReports
        } else {
            reports = []
        }
        self.tableView.reloadData()
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowReportDetail" {
            let reportDetailViewController = segue.destination as! ReportDetailViewController
            
            // Get the cell that generated this segue.
            if let selectedCell = sender as? ReportTableViewCell {
                let indexPath = tableView.indexPath(for: selectedCell)!
                let selectedReport = reports[indexPath.row]
                reportDetailViewController.report = selectedReport
                reportDetailViewController.image = selectedCell.reportImageView.image
                reportDetailViewController.userObj = self.userObj
            }
        }
    }
    
    @IBAction func unwindToReportList(sender: UIStoryboardSegue) {
        print("in unwind method")
        if let sourceViewController = sender.source as? ReportDetailViewController, let report = sourceViewController.report {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                let initialReport = reports[selectedIndexPath.row]
                let origStatus = initialReport.status
                
                //Check for report status changed and anonymous user check
                print("Initial Status : \(origStatus) ... After change status \(report.status)")
                if let userRole = userObj?.role {
                    if(userRole == "official"){
                        if origStatus == report.status{
                            print("Nothing to do. Status is not changed")
                        } else {
                            if userObj?.reportAnonymously == false {
                                let email = userObj?.email
                                sendEmailToUser(report: report, email:email! )
                            }
                        }
                    }
                }
                
                reports[selectedIndexPath.row] = report
                
                for r in baseReports {
                    if r.reportKey == report.reportKey {
                        r.status = report.status
                    }
                }
                
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
                //update report status to firebase
                DataService.ds.REF_REPORTS.child(report.userId).child(report.reportKey).updateChildValues(["status": report.status])

            }
        }
    }
    
    func sendEmailToUser(report: Report, email:String){
        
        
        let session = Session()
        session.authentication = Authentication.apiKey("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")
        
        Session.shared.authentication = Authentication.apiKey("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")
        
        //session.authentication = Authentication.apiKey("9wJWd9yzQXi_XlC5HYPrHg")
        //Session.shared.authentication = Authentication.apiKey("9wJWd9yzQXi_XlC5HYPrHg")
        
        
        let personalization = Personalization(recipients: "neha.parmar@sjsu.edu")
        let plainText = Content(contentType: ContentType.plainText, value: "Hey Dere")
        let htmlText = Content(contentType: ContentType.htmlText, value: "<h1>Report Status Updated!</h1><br/><br/><b>Updated information:</b><br/><br/> Description: \(report.description)<br/> Severity: \(report.severity)<br/> Size: \(report.size)<br/> Time: \(report.time)<br/> Email: \(email)<br/> Address: \(report.address)<br/> Report Status: \(report.status)<br/><br/><br/><b>Support Team, LitterClear.com<b>")
        
        let email = Email(
            personalizations: [personalization],
            from: Address("support@litterclear.com"),
            content: [plainText, htmlText],
            subject: "Report Status Updated"
        )
        do {
            try Session.shared.send(request: email)
        } catch {
            
            print(error)
        }
        
    }
    
    @IBAction func backToProfile(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}
