//
//  GoogleWearAlertView.swift
//  GoogleWearAlertView
//
//  Created by Ashley Robinson on 27/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class func successGreen() -> UIColor {
        return UIColor(red: 69.0/255.0, green: 181.0/255.0, blue: 38.0/255.0, alpha: 1)
    }
    class func errorRed() -> UIColor {
        return UIColor(red: 255.0/255.0, green: 82.0/255.0, blue: 82.0/255.0, alpha: 1)
    }
    class func warningYellow() -> UIColor {
        return UIColor(red: 255.0/255.0, green: 205.0/255.0, blue: 64.0/255.0, alpha: 1)
    }
    class func messageBlue() -> UIColor {
        return UIColor(red: 2.0/255.0, green: 169.0/255.0, blue: 244.0/255.0, alpha: 1)
    }
}

class GoogleWearAlertView: UIView, UIGestureRecognizerDelegate {
    
    //Constants 
    let alertViewSize:CGFloat = 0.4 // 40% of presenting viewcontrollers width
    let imageViewSize:CGFloat = 0.4 //4 0% of AlertViews width
    let imageViewOffsetFromCentre:CGFloat = 0.25 // Offset of image along Y axis
    let titleLabelWidth:CGFloat = 0.7 // 70% of AlertViews width
    let titleLabelHeight:CGFloat = 30
    let navControllerHeight:CGFloat = 44
    
    /** The displayed title of this message */
    var title:NSString?
    
    /** The view controller this message is displayed in, only used to size the alert*/
    var viewController:UIViewController!
    
    /** The duration of the displayed message. If it is 0.0, it will automatically be calculated */
    var duration:Double?
    
    /** The position of the message (top or bottom) */
    var alertPosition:GoogleWearAlertPosition?
    
    /** Is the message currenlty fully displayed? Is set as soon as the message is really fully visible */
    var messageIsFullyDisplayed:Bool?
    
    /** If you'd like to customise the image shown with the alert */
    var iconImage:UIImage?
    
    /** Internal properties needed to resize the view on device rotation properly */
    lazy var titleLabel: UILabel = UILabel()
    lazy var iconImageView: UIImageView = UIImageView()
    
    /** Inits the notification view. Do not call this from outside this library.
    @param title The text of the notification view
    @param image A custom icon image (optional)
    @param notificationType The type (color) of the notification view
    @param duration The duration this notification should be displayed (optional)
    @param viewController the view controller this message should be displayed in
    @param position The position of the message on the screen
    @param dismissingEnabled Should this message be dismissed when the user taps it?
    */
    
    init(title:String, image:UIImage?, type:GoogleWearAlertType, duration:Double, viewController:UIViewController, position:GoogleWearAlertPosition, canbeDismissedByUser:Bool) {
        super.init(frame: CGRectZero)
        
        self.title = title
        self.iconImage = image
        self.duration = duration
        self.viewController = viewController
        self.alertPosition = position
        
        // Setup background color and choose icon
        var imageProvided = image != nil
        switch type {
            case .Error:
                backgroundColor = UIColor.errorRed()
                if !imageProvided { self.iconImage = UIImage(named: "errorIcon") }
                    
            case .Message:
                backgroundColor = UIColor.messageBlue()
                if !imageProvided { self.iconImage = UIImage(named: "messageIcon") }
                    
            case .Success:
                backgroundColor = UIColor.successGreen()
                if !imageProvided { self.iconImage = UIImage(named: "successIcon") }
                
            case .Warning:
                backgroundColor = UIColor.warningYellow()
                if !imageProvided { self.iconImage = UIImage(named: "warningIcon") }
            
            default:
                NSLog("Unknown message type provided")
        }
        
        // Setup self
        setTranslatesAutoresizingMaskIntoConstraints(false)
        frame.size = CGSizeMake(viewController.view.bounds.size.width * alertViewSize, viewController.view.bounds.width * alertViewSize)
        layer.cornerRadius = self.frame.width/2
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(0, 0)
        self.layer.shadowOpacity = 0.8
        self.clipsToBounds = false
        
        // Setup Image View
        iconImageView.image = iconImage
        iconImageView.frame = CGRectMake(0, 0, frame.size.width * imageViewSize, frame.size.width * imageViewSize)
        iconImageView.center = center
        iconImageView.center.y -= iconImageView.frame.size.height * imageViewOffsetFromCentre
        self.addSubview(iconImageView)
        
        // Setup Text Label
        titleLabel.text = title
        titleLabel.frame = CGRectMake(self.center.x - (frame.size.width * titleLabelWidth) / 2, iconImageView.frame.origin.y + iconImageView.frame.size.height - 5, frame.size.width * titleLabelWidth, titleLabelHeight)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.font = UIFont.systemFontOfSize(18)
        self.addSubview(titleLabel)
        
        //Position the alert
        positionAlertForPosition(position)
        
        if canbeDismissedByUser {
            let tagGestureRecognizer = UITapGestureRecognizer(target:self, action: Selector("dismissAlert"))
            self.addGestureRecognizer(tagGestureRecognizer)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSException(name: "init from storyboard error", reason: "alert cannot be initalized from a storybaord", userInfo: nil).raise()
    }
    
    func dismissAlert() {
        GoogleWearAlert.sharedInstance.removeCurrentAlert(self)
    }
    
    func insideNavController() -> Bool {
        
        if let vc = viewController {
            if vc.parentViewController is UINavigationController {
                return true
            } else if vc is UINavigationController {
                return true
            }
        }
        return false
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection!) {
        layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let position = alertPosition {
            positionAlertForPosition(position)
        }
    }
    
    func positionAlertForPosition(position:GoogleWearAlertPosition) {
        
        if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
            
            var centerX = viewController.view.bounds.width/2
            var centerY = viewController.view.bounds.height/2
            center = CGPointMake(centerX, centerY)
            
        } else {
            
            switch position {
            case .Top:
                center = CGPointMake(viewController.view.center.x, viewController.view.frame.size.height / 4)
                if insideNavController() { center.y += navControllerHeight }
                
            case .Center:
                center = viewController.view.center
                
            case .Bottom:
                center = CGPointMake(viewController.view.center.x, viewController.view.frame.size.height * 0.75)
                
            default:
                NSLog("Unknown position type provided")
            }
        }
    }
    
    
    
}