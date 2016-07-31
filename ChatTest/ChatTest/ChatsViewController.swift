//
//  ChatsViewController.swift
//  ChatTest
//
//  Created by Pedro Martin Gomez on 30/7/16.
//  Copyright © 2016 Ligarto Labs. All rights reserved.
//

import UIKit
import Firebase

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
//    var model: [Chat]?
    let cellId = "chatCell"
    let nibId = "ChatViewCell"
    
    var ref: FIRDatabaseReference!
    var chats: [FIRDataSnapshot] = []
    private var _refHandle: FIRDatabaseHandle!
    
    // MARK: Constructors & destructors
    
    deinit {
        self.ref.child("chats").removeObserverWithHandle(_refHandle)
    }
    
    // MARK: Life Cycle

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
    
    // MARK: Actions
    
    @IBAction func didTapRefresh(sender: AnyObject) {
        print("Refreshing...")
    }
    
    
    @IBAction func didTapClose(sender: AnyObject) {
        print("Closing...")
        do {
            try FIRAuth.auth()?.signOut()
        } catch {
            print("Firebase sign out fail")
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Firebase
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        //Listen for new messages in the Firebase database
        _refHandle = self.ref.child("chats").observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
            self.chats.append(snapshot)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.chats.count-1, inSection: 0)], withRowAnimation: .Automatic)
        })
    }
    
    // MARK: Private methods
    
    func registerCustomCell() {
        
        tableView.registerNib(UINib(nibName: nibId, bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    // MARK: Table View Controller
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chats.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! ChatViewCell
        
        let charSnapshot: FIRDataSnapshot! = self.chats[indexPath.row]
        let chat = charSnapshot.value as! Dictionary<String, AnyObject>
        
        cell.chatImageView.loadImageFromURL(chat["mainImageUrl"] as! String)
        cell.serviceName.text = chat["name"] as? String
        cell.dateCreated.text = chat["dateCreated"] as? String
        cell.serviceOwner.text = chat["serviceOwner"] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row % chats.count
        showModal(index)
    }
    
    func showModal(index: Int) {
        let messagesViewController = MessagesViewController(serviceId: "29")
        self.presentViewController(messagesViewController, animated: true, completion: nil)
    }
}

extension UIImageView {
    
    func loadImageFromURL(imageUrl: String) {
        if imageUrl.hasPrefix("gs://") {
            FIRStorage.storage().referenceForURL(imageUrl).dataWithMaxSize(INT64_MAX){ (data, error) in
                if let error = error {
                    print("Error downloading: \(error)")
                    return
                }
                self.image = UIImage.init(data: data!)
            }
        } else if let url = NSURL(string:imageUrl), data = NSData(contentsOfURL: url) {
            self.image = UIImage.init(data: data)
        }
    }
    
}

































