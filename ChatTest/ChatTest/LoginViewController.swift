//
//  LoginViewController.swift
//  ChatTest
//
//  Created by Pedro Martin Gomez on 29/7/16.
//  Copyright © 2016 Ligarto Labs. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var userProfileImage: CircularImageView!
    
    var ref: FIRDatabaseReference!
    var users: [FIRDataSnapshot] = []
    var msglength: NSNumber = 10
    private var _refHandle: FIRDatabaseHandle!
    
    deinit {
        self.ref.child("users").removeObserverWithHandle(_refHandle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDatabase()
        configureStorage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let user = FIRAuth.auth()?.currentUser {
            self.signedIn(user)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapSignIn(sender: AnyObject) {
        // Sign In with credentials.
        let email = emailField.text
        let password = passwordField.text
        FIRAuth.auth()?.signInWithEmail(email!, password: password!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let userData = (self.ref.child("users").queryEqualToValue(user?.uid))
            print(userData)
            self.loadImageProfile(user!)
        }
    }
    
    @IBAction func didTapSignUp(sender: AnyObject) {
        let email = emailField.text
        let password = passwordField.text
        FIRAuth.auth()?.createUserWithEmail(email!, password: password!) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.setDisplayName(user!)
        }
    }
    
    func setDisplayName(user: FIRUser?) {
        let changeRequest = user!.profileChangeRequest()
        changeRequest.displayName = user!.email!.componentsSeparatedByString("@")[0]
        changeRequest.commitChangesWithCompletion(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signedIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    func setPhotoUrl(user: FIRUser?, imageUrl: String) {
        let changeRequest = user!.profileChangeRequest()
        changeRequest.photoURL = NSURL(string: imageUrl)
        changeRequest.commitChangesWithCompletion(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signedIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
//        _refHandle = self.ref.child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
//            self.users.append(snapshot)
//            //self.clientTable.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messages.count-1, inSection: 0)], withRowAnimation: .Automatic)
//        })
        
    }
    
    func configureStorage() {
    }
    
    func loadImageProfileData(user: FIRUser, imageUrl: String) {
        if imageUrl.hasPrefix("gs://") {
            FIRStorage.storage().referenceForURL(imageUrl).dataWithMaxSize(INT64_MAX){ (data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                self.userProfileImage.image = UIImage.init(data: data!)
                self.setPhotoUrl(user, imageUrl: imageUrl)
            }
        } else if let url = NSURL(string:imageUrl), data = NSData(contentsOfURL: url) {
            self.userProfileImage.image = UIImage.init(data: data)
        }
        
    }
    
    func loadImageProfile(user: FIRUser) {
        ref.child("usersExtendedInfo").child(user.uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
            print(snapshot)
            let info = snapshot.value as! Dictionary<String, String>
            let imageUrl = info["photoUrl"] as String!
            self.loadImageProfileData(user, imageUrl: imageUrl)
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func signedIn(user: FIRUser?) {
        MeasurementHelper.sendLoginEvent()
        
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.photoUrl = user?.photoURL
        AppState.sharedInstance.signedIn = true
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.NotificationKeys.SignedIn, object: nil, userInfo: nil)
        //performSegueWithIdentifier(Constants.Segues.SignInToFp, sender: nil)
        showChats()
    }
    
    func showChats() {
        let chatsViewController = ChatsViewController(nibName: "ChatsView", bundle: nil)
        showModal(self, calledContainer: chatsViewController)
    }
    
}






















