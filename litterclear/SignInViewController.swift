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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: (view.frame.width/2 - 75), y: 400 , width: 150, height: 150)
        //googleButton.center = view.center
        view.addSubview(googleButton)
        GIDSignIn.sharedInstance().uiDelegate = self
        
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
            }
        })
    }
}

