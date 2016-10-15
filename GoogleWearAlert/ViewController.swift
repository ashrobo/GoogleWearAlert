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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleWearAlert.showAlert(title: "Success", .success)
        
        GoogleWearAlert.showAlert(title:"Error", nil, type: .error, duration: 2.0, inViewController: self)
        
        GoogleWearAlert.showAlert(title: "Warning", nil, type: .warning, duration: 2.0, inViewController: self, atPostion: .top, canBeDismissedByUser: true)
        
        GoogleWearAlert.showAlert(title: "Message", nil, type: .message, duration: 2.0, inViewController: self, atPostion: .bottom, canBeDismissedByUser: true)
    }

    
}

