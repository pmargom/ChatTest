//
//  Message.swift
//  ChatTest
//
//  Created by Pedro Martin Gomez on 31/7/16.
//  Copyright © 2016 Ligarto Labs. All rights reserved.
//

import UIKit

struct Message {
    
    var id: String
    var idService: String
    
    init(id: String, idService: String) {
        self.id = id
        self.idService = idService
    }
}