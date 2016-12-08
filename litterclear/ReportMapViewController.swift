//
//  ReportMapViewController.swift
//  litterclear
//
//  Created by Neha Parmar on 12/5/16.
//  Copyright © 2016 SJSU. All rights reserved.
//

import Foundation
import Firebase
import MapKit
import FirebaseDatabase

class ReportMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    //var reports = [Report]()
    //var geoFire: GeoFire!
    //var geoFireRef: FIRDatabaseReference!
    var reports = [Report]()
    var userAnnos = [UserAnnotation]()
    
    var firstTime = false
    var initialLocation = CLLocation(latitude: 37.322993, longitude: -121.883200)
    
    var userObj: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userObj = userObj {
            print("id: \(userObj.id) email: \(userObj.email) role: \(userObj.role) reportAnonymously: \(userObj.reportAnonymously)")
        }
        
        mapView.delegate = self
       
        //Will move as the user moves
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        
        //geoFireRef = FIRDatabase.database().reference()
        //geoFire = GeoFire(firebaseRef: geoFireRef)
        
        /*DataService.ds.REF_REPORTS.observe(.value, with: { (snapshot) in
            
            self.reports = [] // THIS IS THE NEW LINE
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let reportDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let report = Report(reportKey: key, reportData: reportDict)
                        self.reports.append(report)
                    }
                }
            }
            
            //self.tableView.reloadData()
        })*/
        centerMapOnLocation(location: initialLocation)
        
        loadFromDB()
        if (userAnnos != nil){
            print("Calling to map annotation on the Map.\n")
        }
        print("UserAnnotations on the Map before. \(userAnnos) + report \(reports)")
        mapView.addAnnotations(userAnnos)
        print("UserAnnotations on the Map. \(userAnnos)")
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 10000, 10000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func loadFromDB(){
        DataService.ds.REF_REPORTS.observe(.value, with: { (snapshot) in
            
            self.reports = [] // THIS IS THE NEW LINE
            self.userAnnos = []
            
            
            if let userObj = self.userObj {
                print("id: \(userObj.id) email: \(userObj.email) role: \(userObj.role) reportAnonymously: \(userObj.reportAnonymously)")
                
                if userObj.role == "resident" {
                    self.navigationItem.title = "My Reports"
                    
                    DataService.ds.REF_REPORTS.child(userObj.id).observe(.value, with: { (snapshot) in
                        
                        self.reports = [] // THIS IS THE NEW LINE
                        
                        if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                            for snap in snapshot {
                                print("SNAP: \(snap)")
                                if let reportDict = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
                                    let report = Report(reportKey: key, reportData: reportDict)
                                    self.reports.append(report)
                                    
                                    //Create user Annotaion and append to the array
                                    //init(title: String, address: String, size: String,coordinate: CLLocationCoordinate2D)
                                    print("Report info .. \(Double(report.latitude)) ... \(Double(report.longitude))")
                                    let userAnno = UserAnnotation(title: report.description!,address: report.address!, size: report.size!,coordinate:CLLocationCoordinate2D(latitude: Double(report.latitude)!, longitude: Double(report.longitude)!))
                                    print("UserAnnotation is created here --> \(userAnno)")
                                    
                                    self.mapView.addAnnotation(userAnno)
                                    self.userAnnos.append(userAnno)
                                }
                            }
                        }
                        
                    })
                } else { //officer
                    self.navigationItem.title = "Resident Reports"
                    
                    DataService.ds.REF_REPORTS.observe(.value, with: { (snapshot) in
                        
                        self.reports = [] // THIS IS THE NEW LINE
                        
                        if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                            for snap in snapshot {
                                print("SNAP: \(snap)")
                                if let subsnap = snap.children.allObjects as? [FIRDataSnapshot] {
                                    for sub in subsnap {
                                        if let reportDict = sub.value as? Dictionary<String, AnyObject> {
                                            let key = sub.key
                                            let report = Report(reportKey: key, reportData: reportDict)
                                            self.reports.append(report)
                                            
                                            //Create user Annotaion and append to the array
                                            //init(title: String, address: String, size: String,coordinate: CLLocationCoordinate2D)
                                            print("Report info .. \(Double(report.latitude)) ... \(Double(report.longitude))")
                                            let userAnno = UserAnnotation(title: report.description!,address: report.address!, size: report.size!,coordinate:CLLocationCoordinate2D(latitude: Double(report.latitude)!, longitude: Double(report.longitude)!))
                                            print("UserAnnotation is created here --> \(userAnno)")
                                            
                                            self.mapView.addAnnotation(userAnno)
                                            self.userAnnos.append(userAnno)
                                        }
                                    }
                                }
                            }
                        }
                        
                    })
                }
                
            } else {
                print("ERROR: USER IS NIL")
            }
            
            
//            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
//                for snap in snapshot {
//                    //print("SNAP: \(snap)")
//                    if let reportDict = snap.value as? Dictionary<String, AnyObject> {
//                        let key = snap.key
//                        let report = Report(reportKey: key, reportData: reportDict)
//                        self.reports.append(report)
//                        
//                        //Create user Annotaion and append to the array
//                        //init(title: String, address: String, size: String,coordinate: CLLocationCoordinate2D)
//                        print("Report info .. \(Double(report.latitude)) ... \(Double(report.longitude))")
//                        let userAnno = UserAnnotation(title: report.description!,address: report.address!, size: report.size!,coordinate:CLLocationCoordinate2D(latitude: Double(report.latitude)!, longitude: Double(report.longitude)!))
//                        print("UserAnnotation is created here --> \(userAnno)")
//                        
//                        self.mapView.addAnnotation(userAnno)
//                        self.userAnnos.append(userAnno)
//                        
//                       
//                        
//                        
//                    }
//                }
//            }
            
            //self.tableView.reloadData()
        })
        
    }
    
    func mapView(_ mapView: MKMapView,
                 viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? UserAnnotation {
            let identifier = "artPin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                
                dequeuedView.image = UIImage(named: "red_slant")
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.image = UIImage(named: "red_slant")
                view.canShowCallout = true
                view.pinTintColor = .red
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
                
            }
            
            //view.pinTintColor = annotation.pinTintColor()
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! UserAnnotation
        //let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        print("Annotation whenever added it comes here...")
        
        let indexOfReport = userAnnos.index(of: view.annotation as! UserAnnotation)
        print("reportIndex .... \(indexOfReport!) .. location \(location.coordinate)")
        
        let report:Report = reports[indexOfReport!]
        
        print("report at the same index ... \(report.latitude) ... \(report.longitude)")
        
        
        performSegue(withIdentifier: "ShowMapToDetail", sender: report)

        
        //location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowMapToDetail" {
            let reportDetailViewController = segue.destination as! ReportDetailViewController
            
            // Get the cell that generated this segue.
             let report = sender as? Report
        
                reportDetailViewController.report = report
                reportDetailViewController.userObj = userObj
                /*let ref = FIRStorage.storage().reference(forURL: report!.imageURL!)
                print("Image URL \(report!.imageURL!)")
                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("Unable to download image from Firebase storage")
                    } else {
                        print("Image downloaded from Firebase storage")
                        if let imgData = data {
                            if let img = UIImage(data: imgData) {
                                //self.reportImageView.image = img
                                //set the image here for forwarding
                                
                                reportDetailViewController.image = img
                                //ReportTableViewController.imageCache.setObject(img, forKey: report.imageURL as NSString)
                            }
                        }
                    }
                })*/
            
            
            
            
        }
    }
    
    
    @IBAction func backToProfile(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    /*func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if let loc = userLocation.location {
            if !firstTime {
                centerMapOnLocation(location: loc)
                firstTime = true
            }
        }
        initialLocation = userLocation.location!
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annoIdentifier = "Report"
        var annotationView: MKAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self) {
             print("Reusable identifier if")
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "user")
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            print("Reusable identifier if-else")
            annotationView = deqAnno
            annotationView?.annotation = annotation
        } else {
            print("Create new Annot else block")
            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = av
        }
        
        if let annotationView = annotationView, let anno = annotation as? UserAnnotation {
            
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "\(anno.reportID)")
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.setImage(UIImage(named: "map"), for: .normal)
            annotationView.rightCalloutAccessoryView = btn
        }
        
        return annotationView
        
    }
    
    func createSighting(forLocation location: CLLocation, withReport reportID: String) {
        
        geoFire.setLocation(location, forKey: "\(reportID)")
        
        print("createSighting Annotation 1 \(location.coordinate)")
        let anno = UserAnnotation(coordinate: location.coordinate, reportID: reportID)
        print("createSighting Annotation 2 \(location.coordinate)")
        self.mapView.addAnnotation(anno)
        print("createSighting on map user Annotation \(location.coordinate)")
        
    }*/
    
    /*func showSightingsOnMap(location: CLLocation) {
        let circleQuery = geoFire!.query(at: location, withRadius: 25)
        print("IS showSightingsOnMap called for \(location.coordinate)")
        _ = circleQuery?.observe(GFEventType.keyMoved,with: { (key, location) in
            
            if let key = key, let location = location {
                print("Inside set user Annotation 1 \(location.coordinate)")
                let anno = UserAnnotation(coordinate: location.coordinate, reportID: key)
                print("Inside set user Annotation 2 \(location.coordinate)")
                self.mapView.addAnnotation(anno)
                print("Added annotation on map user Annotation \(location.coordinate)")
            }
        })
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        print("regionWillChangeAnimated: Is region updated? \(loc.coordinate)")
        showSightingsOnMap(location: loc)
    }*/
    
    /*func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let anno = view.annotation as? UserAnnotation {
            
            var place: MKPlacemark!
            if #available(iOS 10.0, *) {
                place = MKPlacemark(coordinate: anno.coordinate)
            } else {
                place = MKPlacemark(coordinate: anno.coordinate, addressDictionary: nil)
            }
            let destination = MKMapItem(placemark: place)
            destination.name = "Report Sighting"
            let regionDistance: CLLocationDistance = 3000
            let regionSpan = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey:  NSValue(mkCoordinateSpan: regionSpan.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
        
    }*/
    
    /*@IBAction func goBack(_ sender: Any) {
        
        /*DataService.ds.REF_REPORTS.observe(.value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    //print("Report: \(snap)")
                    if let reportDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let report = Report(reportKey: key, reportData: reportDict)
                        //let lat = Double(report.latitude)
                        //let lng = Double(report.longitude) , longitude:
                        let lat = 37.723511836016936
                        let lng = -122.4295042610309
                        //let loc = CLLocation(latitude: lat!, longitude: lng!)
                        let loc = CLLocation(latitude: lat, longitude: lng)
                        print("Creating Sighting for : \(key)")
                        
                        //self.createSighting(forLocation: loc, withReport: key)
                        
                    }
                }
            }
            
        })*/
        
    }*/
    
    
}
