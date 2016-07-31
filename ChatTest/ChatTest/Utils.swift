//
//  Utils.swift
//  ChatTest
//
//  Created by Pedro Martin Gomez on 30/7/16.
//  Copyright © 2016 Ligarto Labs. All rights reserved.
//

import UIKit

func showModal(callerController: UIViewController, calledContainer: UIViewController) {
    
    callerController.presentViewController(calledContainer, animated: true, completion: nil)
    
}