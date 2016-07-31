//
//  ChatViewCell.swift
//  ChatTest
//
//  Created by Pedro Martin Gomez on 30/7/16.
//  Copyright © 2016 Ligarto Labs. All rights reserved.
//

import UIKit

class ChatViewCell: UITableViewCell {

    @IBOutlet weak var chatImageView: CircularImageView!
    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var dateCreated: UILabel!
    @IBOutlet weak var serviceOwner: UILabel!
    @IBOutlet weak var messageText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        print("cell selected...")
    }
    
//    var chat: Chat? {
//        didSet {
//            if let chat = chat {
//                priceLabel.text = chat.
//                commentLabel.text = service.description
//                
//                // load the image asynchronous
//                if service.mainImage != nil {
//                    loadImage(service.mainImage!, imageView: imageService)
//                }
//                
//                if service.ownerImage != nil {
//                    loadImage(service.ownerImage!, imageView: imageUser)
//                }
//            }
//        }
//    }
    
}
