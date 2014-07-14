//
//  ViewController.swift
//  AlertTest
//
//  Created by Ashley Robinson on 27/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleWearAlert.showAlert(title: "Success", type: .Success)
        
        GoogleWearAlert.showAlert(title:"Error", image:nil, type: .Error, duration: 2.0, inViewController: self)
        
        GoogleWearAlert.showAlert(title: "Warning", image: nil, type: .Warning, duration: 2.0, inViewController: self, atPostion: .Top, canBeDismissedByUser: true)
        
        GoogleWearAlert.showAlert(title: "Message", image: nil, type: .Message, duration: 2.0, inViewController: self, atPostion: .Bottom, canBeDismissedByUser: true)
    }
}

