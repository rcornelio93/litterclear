//
//  AppDelegate.swift
//  litterclear
//
//  Created by Rachita Shetty on 11/27/16.
//  Copyright © 2016 SJSU. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var userUID: String?
    var userEmail: String?
    //var homeVC: SignInViewController?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()

        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("error while trying to sign into google: \(error)")
            return
        }
        print("Successfully signed into google")
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)

        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("LitterApp - Unable to authenticate to firebase")
            } else {
                print("LitterApp - Successfully authenticated to firebase after google \(user!.uid)")
                self.userUID = user!.uid
                self.userEmail = user!.email
                let values = ["userid": self.userUID!, "email": self.userEmail!, "role": "official", "reportAnonymously": "false"]
                self.registerUserIntoDatabase(uid: self.userUID!, values: values as [String : AnyObject])
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                let homeVC = storyboard.instantiateViewController(withIdentifier: "homeView") as! HomeViewController
                homeVC.userUID = user!.uid
                self.window?.rootViewController?.present(homeVC, animated: true, completion: nil)
            }
        })
    }

    private func registerUserIntoDatabase(uid: String, values: [String: AnyObject]){
        let ref = FIRDatabase.database().reference(fromURL: "https://litterclear.firebaseio.com/")
        let usersRef = ref.child("user_profile").child(uid)
        
        
        usersRef.updateChildValues(values, withCompletionBlock: {(err, ref) in
            if let error = err  {
                print ("Error while registering user using google\(error)")
                return
            }
        })
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, openURL: URL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let handled =  FBSDKApplicationDelegate.sharedInstance().application(application, open: openURL, sourceApplication: sourceApplication, annotation: annotation)
        
        GIDSignIn.sharedInstance().handle(openURL,
                                             sourceApplication: sourceApplication,
                                             annotation: annotation)
        //homeVC?.showHomeScreen()
        return handled
    }
}

