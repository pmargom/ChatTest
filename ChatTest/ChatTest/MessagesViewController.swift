//
//  MessagesViewController.swift
//  ChatTest
//
//  Created by Pedro Martin Gomez on 31/7/16.
//  Copyright © 2016 Ligarto Labs. All rights reserved.
//

import Photos
import UIKit
import Firebase

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var serviceId: String!
    
    var ref: FIRDatabaseReference!
    var messages: [FIRDataSnapshot]! = []
    var msglength: NSNumber = 10
    private var _refHandle: FIRDatabaseHandle!
    
    let cellId = "messageCell"
    let nibId = "MessageViewCell"
    
    // MARK: Constructors & destructors
    
    // MARK: - Init
    convenience init(serviceId: String) {
        self.init(nibName: "MessagesView", bundle: nil)
        self.serviceId    = serviceId
    }
    
    deinit {
        self.ref.child("chats").removeObserverWithHandle(_refHandle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCustomCell()
        configureDatabase()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private methods
    
    func registerCustomCell() {
        
        tableView.registerNib(UINib(nibName: nibId, bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    @IBAction func didTapClose(sender: AnyObject) {
        print("Closing...")
//        do {
//            try FIRAuth.auth()?.signOut()
//        } catch {
//            print("Firebase sign out fail")
//        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: Firebase
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        //Listen for new messages in the Firebase database
        _refHandle = self.ref.child("chats").child("service-\(serviceId)").child("messages").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
            self.messages.append(snapshot)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messages.count-1, inSection: 0)], withRowAnimation: .Automatic)
        })
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= self.msglength.integerValue // Bool
    }
    
    // UITableViewDataSource protocol methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = self.tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! MessageViewCell
        // Unpack message from Firebase DataSnapshot
        let messageSnapshot: FIRDataSnapshot! = self.messages[indexPath.row]
        let message = messageSnapshot.value as! Dictionary<String, String>
        
        cell.userImageView.loadImageFromURL(message["photoUrl"]!)
        cell.messageText?.text = message["text"] as String!
        cell.name?.text = message["name"] as String!
        cell.sentAt?.text = message["sentAt"] as String!

        return cell
    }
    
    // UITextViewDelegate protocol methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let data = [Constants.MessageFields.text: textField.text! as String]
        sendMessage(data)
        return true
    }
    
    func sendMessage(data: [String: String]) {
        var mdata = data
        mdata[Constants.MessageFields.name] = AppState.sharedInstance.displayName
        if let photoUrl = AppState.sharedInstance.photoUrl {
            mdata[Constants.MessageFields.photoUrl] = photoUrl.absoluteString
        }
    }
    
    // MARK: - Image Picker
    
    @IBAction func didTapAddPhoto(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        presentViewController(picker, animated: true, completion:nil)
    }
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion:nil)
        
        // if it's a photo from the library, not an image from the camera
        if let referenceUrl = info[UIImagePickerControllerReferenceURL] {
            let assets = PHAsset.fetchAssetsWithALAssetURLs([referenceUrl as! NSURL], options: nil)
            let asset = assets.firstObject
            asset?.requestContentEditingInputWithOptions(nil, completionHandler: { (contentEditingInput, info) in
                _ = contentEditingInput?.fullSizeImageURL
                _ = "\(FIRAuth.auth()?.currentUser?.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000))/\(referenceUrl.lastPathComponent!)"
            })
        } else {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            _ = UIImageJPEGRepresentation(image, 0.8)
            _ = FIRAuth.auth()!.currentUser!.uid +
                "/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000)).jpg"
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion:nil)
    }
    

}
