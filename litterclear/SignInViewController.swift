//
//  ViewController.swift
//  litterclear
//
//  Created by Rachita Shetty on 11/27/16.
//  Copyright © 2016 SJSU. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    var userUID : String?
    var userEmail: String?
    
    @IBOutlet weak var emailaddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       /* let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: (view.frame.width/2 - 75), y: 400 , width: 150, height: 150)
        //googleButton.center = view.center
        view.addSubview(googleButton)
        GIDSignIn.sharedInstance().uiDelegate = self*/
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginToFacebook(_ sender: Any) {
        let facebookLoginManager = FBSDKLoginManager()
        
        facebookLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("LitterApp - Unable to authenticate to FB - \(error)")
            } else if result?.isCancelled == true {
                print("LitterApp - User cancelled authentication")
            } else {
                print("LitterApp - Successfully authenticated to facebook")
                let userCred = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(userCred)
            }
            
        }
    }

    public func firebaseAuth(_ cred: FIRAuthCredential){
        FIRAuth.auth()?.signIn(with: cred, completion: { (user, error) in
            if error != nil {
                print("LitterApp - Unable to authenticate to firebase")
            } else {
                print("LitterApp - Successfully authenticated to firebase")
                self.userUID = user?.uid
                self.userEmail = user!.email
                self.showHomeScreen()
            }
        })
    }
    
    @IBAction func emailSignIn(_ sender: Any) {
        if let email = emailaddressField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("LitterApp - Successfully authenticated with Firebase")
                    self.userUID = user?.uid
                    self.userEmail = user!.email
                    self.showHomeScreen()
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil{
                            print("LitterApp - Unable to authenticate with Firebase")
                        } else {
                            print("LitterApp - Successfully authenticated with Firebase")
                            self.userUID = user?.uid
                            self.userEmail = user!.email
                            
                            //To update role and other fields in database
                            let role: String?
                            
                            if self.userEmail!.contains("@gmail.com"){
                                role = "official"
                            }else{
                                role = "resident"
                            }
                            
                            let values = ["userid": self.userUID!, "email": self.userEmail!, "role": role!, "reportAnonymously": "false"]
                            self.registerUserIntoDatabase(uid: self.userUID!, values: values as [String : AnyObject])
                            
                            
                            self.showHomeScreen()
                        }
                    })
                }
            })
        }
    }
    
    func showHomeScreen(){
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "homeView") as! HomeViewController
        print("The user id in signin view controller is \(userUID) ")
        homeVC.userUID = self.userUID
        self.present(homeVC, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if delegate.userUID != nil {
            print(delegate.userUID!)
            self.userUID = delegate.userUID
            self.userEmail = delegate.userEmail
        }
        
        let role: String?
        
        if userEmail!.contains("@gmail.com"){
            role = "official"
        }else{
            role = "resident"
        }
        
        let values = ["userid": self.userUID!, "email": self.userEmail!, "role": role!]
        registerUserIntoDatabase(uid: self.userUID!, values: values as [String : AnyObject])
        //print(GIDSignIn.sharedInstance().currentUser.userID)

        let profViewController : ProfileViewController = segue.destination as! ProfileViewController
        profViewController.userUID = self.userUID
        
    }
    
    private func registerUserIntoDatabase(uid: String, values: [String: AnyObject]){
        let ref = FIRDatabase.database().reference(fromURL: "https://litterclear.firebaseio.com/")
        let usersRef = ref.child("user_profile").child(uid)
        
        
        usersRef.updateChildValues(values, withCompletionBlock: {(err, ref) in
            if let error = err  {
                print (error)
                return
            }
        })
    }
    
    @IBAction func landingViewAction(_ sender: Any) {
        print("inside landing view action")
        let reportVC = self.storyboard?.instantiateViewController(withIdentifier: "reportView") as! ReportViewController
        present(reportVC, animated: true, completion: nil)
    }
    
    @IBAction func viewReports(_ sender: UIButton) {
        let reportVC = self.storyboard?.instantiateViewController(withIdentifier: "filedReports") as! ReportTableViewController
        present(reportVC, animated: true, completion: nil)
    }
    
    @IBAction func googleSignInAction(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
}

