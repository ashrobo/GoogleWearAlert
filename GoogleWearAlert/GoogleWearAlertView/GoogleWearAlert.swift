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
    case Message
    case Warning
    case Error
    case Success
}

enum GoogleWearAlertPosition {
    case Top
    case Center
    case Bottom
}

class GoogleWearAlert: NSObject {
    
    //Singleon Class (Only needed for internal use)
    class var sharedInstance: GoogleWearAlert {
    struct Static {
        static var instance: GoogleWearAlert?
        static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = GoogleWearAlert()
        }
        
        return Static.instance!
    }
    
    // Constants
    let presentAnimationDuration: NSTimeInterval = 1.2
    let dismissAnimationDuration: NSTimeInterval = 0.3
    let springDamping: CGFloat = 0.6
    let springVelocity: CGFloat = 10
    
    @lazy var alertQueue: NSMutableArray = NSMutableArray()
    var bgWindow: UIWindow = UIWindow();
    weak var defaultViewController:UIViewController?
    var alertActive:Bool = false
    var timer: NSTimer?
    
    class func showAlert(#title:String, type:GoogleWearAlertType) {
        showAlert(title:title, image: nil, type: type, inViewController: GoogleWearAlert.sharedInstance.useDefaultController())
    }
    
    class func showAlert(#title:String, image:UIImage?, type:GoogleWearAlertType, duration:Double = 2.5, inViewController:UIViewController) {
        showAlert(title: title, image: image, type: type, duration: duration, inViewController: inViewController, atPostion: .Center, canBeDismissedByUser: true)
    }
    
    class func showAlert(#title:String, image:UIImage?, type:GoogleWearAlertType, duration:Double, inViewController:UIViewController, atPostion:GoogleWearAlertPosition, canBeDismissedByUser:Bool) {
        var alertView = GoogleWearAlertView(title: title, image: image, type: type, duration: duration, viewController: inViewController, position: atPostion, canbeDismissedByUser: canBeDismissedByUser)
        
        GoogleWearAlert.sharedInstance.prepareNotificationToBeShown(alertView)
    }
    
    
    func prepareNotificationToBeShown(alert:GoogleWearAlertView) {
        
        var title = alert.titleLabel
        for message: AnyObject in alertQueue {
            if message.titleLabel == title {
                return
            }
        }
        
        alertQueue.addObject(alert)

        if alertActive == false {
            presentAlert()
        }
    }
    
    func presentAlert() {
        
        if alertQueue.count == 0 { return }
        
        alertActive = true;
        
        var scale = CGAffineTransformMakeScale(0.1, 0.1)
        var rotate = CGAffineTransformRotate(scale, CGFloat(M_PI))
        var transform = CGAffineTransformConcat(scale, rotate)
        
        var currentView = alertQueue.firstObject as GoogleWearAlertView
        currentView.transform = transform
        
        bgWindow.windowLevel = UIWindowLevelAlert
        bgWindow.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        var windowFrame = UIScreen.mainScreen().applicationFrame
        bgWindow.frame = CGRectMake(windowFrame.origin.x, windowFrame.origin.y - 20, windowFrame.size.width, windowFrame.size.height + 20)
        bgWindow.hidden = true
        bgWindow.addSubview(currentView)
        bgWindow.makeKeyAndVisible()

        UIView.animateWithDuration(presentAnimationDuration,
            delay: 0.0,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: springVelocity,
            options:.CurveEaseIn,
            animations: {
                self.bgWindow.alpha = 1.0
                self.bgWindow.hidden = false;
                currentView.transform = CGAffineTransformIdentity
            
            }, completion: {
                (completion: Bool) in
                currentView.messageIsFullyDisplayed = true
            })
        
        var timeInterval = NSTimeInterval(currentView.duration!)
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: Selector("removeAlert:"), userInfo:["currentView" : currentView], repeats: false)
    }
    
    func removeAlert(timer:NSTimer) {
        var currentView = timer.userInfo.objectForKey("currentView")as GoogleWearAlertView
        removeCurrentAlert(currentView)
    }
    
    func removeCurrentAlert(currentView:GoogleWearAlertView) {

        timer?.invalidate()
        currentView.messageIsFullyDisplayed = false
        
        UIView.animateWithDuration(dismissAnimationDuration,
            delay: 0.0,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: springVelocity,
            options:.CurveLinear | .AllowUserInteraction,
            animations: {
                
                currentView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                
            }, completion: {
                (completion: Bool) in
                
                UIView.animateWithDuration(self.dismissAnimationDuration,
                    delay: 0.0,
                    usingSpringWithDamping: self.springDamping,
                    initialSpringVelocity: self.springVelocity,
                    options:.CurveLinear | .AllowUserInteraction,
                    animations: {
                        self.bgWindow.alpha = 0.0
                        currentView.transform = CGAffineTransformMakeScale(0.1, 0.1)
                        currentView.alpha = 0.0
                        
                    }, completion: {
                        (completion: Bool) in
                        
                        currentView.removeFromSuperview()
                        self.bgWindow.hidden = true
                        
                        self.alertQueue.removeObject(currentView)
                        self.alertActive = false
                        
                        if self.alertQueue.count > 0 { self.presentAlert() }
                    })
            })
    }

    func useDefaultController() -> UIViewController {
        
        if let defaultVC = defaultViewController {
            return defaultVC
        } else {
            defaultViewController = UIApplication.sharedApplication().keyWindow.rootViewController;
            return defaultViewController!
        }
    }
}