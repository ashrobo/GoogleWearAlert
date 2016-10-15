//
//  GoogleWearAlert.swift
//  GoogleWearAlertView
//
//  Created by Ashley Robinson on 27/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

enum GoogleWearAlertType {
    case message
    case warning
    case error
    case success
}

enum GoogleWearAlertPosition {
    case top
    case center
    case bottom
}

class GoogleWearAlert: NSObject {
    
    //Singleon Class (Only needed for internal use)
    static let sharedInstance = GoogleWearAlert()
    private override init() {}
    
    // Constants
    let presentAnimationDuration: TimeInterval = 1.2
    let dismissAnimationDuration: TimeInterval = 0.3
    let springDamping: CGFloat = 0.6
    let springVelocity: CGFloat = 10
    
    lazy var alertQueue: NSMutableArray = NSMutableArray()
    var bgWindow: UIWindow = UIWindow();
    weak var defaultViewController:UIViewController?
    var alertActive:Bool = false
    var timer: Timer?
    
    class func showAlert(title:String, _ type:GoogleWearAlertType) {
        showAlert(title:title, nil, type: type, inViewController: GoogleWearAlert.sharedInstance.useDefaultController())
    }
    
    class func showAlert(title:String, _ image:UIImage?, type:GoogleWearAlertType, duration:Double = 2.5, inViewController:UIViewController) {
        showAlert(title: title, image, type: type, duration: duration, inViewController: inViewController, atPostion: .center, canBeDismissedByUser: true)
    }
    
    class func showAlert(title:String, _ image:UIImage?, type:GoogleWearAlertType, duration:Double, inViewController:UIViewController, atPostion:GoogleWearAlertPosition, canBeDismissedByUser:Bool) {
        let alertView = GoogleWearAlertView(title: title, image: image, type: type, duration: duration, viewController: inViewController, position: atPostion, canbeDismissedByUser: canBeDismissedByUser)
        
        GoogleWearAlert.sharedInstance.prepareNotificationToBeShown(alertView)
    }
    
    
    func prepareNotificationToBeShown(_ alert:GoogleWearAlertView) {
        
        let title = alert.titleLabel
        for message in alertQueue {
            if (message as AnyObject).titleLabel == title {
                return
            }
        }
        
        alertQueue.add(alert)

        if alertActive == false {
            presentAlert()
        }
    }
    
    func presentAlert() {
        
        if alertQueue.count == 0 { return }
        
        alertActive = true;
        
        let scale = CGAffineTransform(scaleX: 0.1, y: 0.1)
        let rotate = scale.rotated(by: CGFloat(M_PI))
        let transform = scale.concatenating(rotate)
        
        let currentView = alertQueue.firstObject as! GoogleWearAlertView
        currentView.transform = transform
        
        bgWindow.windowLevel = UIWindowLevelAlert
        bgWindow.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        let windowFrame = UIScreen.main.applicationFrame
        bgWindow.frame = CGRect(x: windowFrame.origin.x, y: windowFrame.origin.y - 20, width: windowFrame.size.width, height: windowFrame.size.height + 20)
        bgWindow.isHidden = true
        bgWindow.addSubview(currentView)
        bgWindow.makeKeyAndVisible()

        UIView.animate(withDuration: presentAnimationDuration,
            delay: 0.0,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: springVelocity,
            options:.curveEaseIn,
            animations: {
                self.bgWindow.alpha = 1.0
                self.bgWindow.isHidden = false;
                currentView.transform = .identity
            
            }, completion: {
                (completion: Bool) in
                currentView.messageIsFullyDisplayed = true
            })
        
        let timeInterval = TimeInterval(currentView.duration!)
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(GoogleWearAlert.removeAlert(_:)), userInfo:["currentView" : currentView], repeats: false)
    }
    
    func removeAlert(_ timer:Timer) {
        let currentView = (timer.userInfo as! [String: AnyObject])["currentView"] as! GoogleWearAlertView
        removeCurrentAlert(currentView)
    }
    
    func removeCurrentAlert(_ currentView:GoogleWearAlertView) {

        timer?.invalidate()
        currentView.messageIsFullyDisplayed = false
        
        UIView.animate(withDuration: dismissAnimationDuration,
            delay: 0.0,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: springVelocity,
            options: [.curveLinear, .allowUserInteraction],
            animations: {
                
                currentView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                
            }, completion: {
                (completion: Bool) in
                
                UIView.animate(withDuration: self.dismissAnimationDuration,
                    delay: 0.0,
                    usingSpringWithDamping: self.springDamping,
                    initialSpringVelocity: self.springVelocity,
                    options: [.curveLinear, .allowUserInteraction],
                    animations: {
                        self.bgWindow.alpha = 0.0
                        currentView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                        currentView.alpha = 0.0
                        
                    }, completion: {
                        (completion: Bool) in
                        
                        currentView.removeFromSuperview()
                        self.bgWindow.isHidden = true
                        
                        self.alertQueue.remove(currentView)
                        self.alertActive = false
                        
                        if self.alertQueue.count > 0 { self.presentAlert() }
                    })
            })
    }

    func useDefaultController() -> UIViewController {
        
        if let defaultVC = defaultViewController {
            return defaultVC
        } else {
            defaultViewController = UIApplication.shared.keyWindow?.rootViewController;
            return defaultViewController!
        }
    }
}
