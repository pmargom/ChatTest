//
//  MessageViewCell.swift
//  ChatTest
//
//  Created by Pedro Martin Gomez on 31/7/16.
//  Copyright © 2016 Ligarto Labs. All rights reserved.
//

import UIKit

class MessageViewCell: UITableViewCell {

    
    @IBOutlet weak var userImageView: CircularImageView!
    @IBOutlet weak var messageText: UILabel!
    @IBOutlet weak var sentAt: UILabel!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
