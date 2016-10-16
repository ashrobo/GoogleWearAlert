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
        super.init(frame: CGRect.zero)

        self.title = title as NSString?
        self.iconImage = image
        self.duration = duration
        self.viewController = viewController
        self.alertPosition = position

        // Setup background color and choose icon
        let imageProvided = image != nil
        switch type {
        case .error:
            backgroundColor = UIColor.errorRed()
            if !imageProvided { self.iconImage = UIImage(named: "errorIcon") }

        case .message:
            backgroundColor = UIColor.messageBlue()
            if !imageProvided { self.iconImage = UIImage(named: "messageIcon") }

        case .success:
            backgroundColor = UIColor.successGreen()
            if !imageProvided { self.iconImage = UIImage(named: "successIcon") }

        case .warning:
            backgroundColor = UIColor.warningYellow()
            if !imageProvided { self.iconImage = UIImage(named: "warningIcon") }
        }

        // Setup self
        translatesAutoresizingMaskIntoConstraints = false
        frame.size = CGSize(width: viewController.view.bounds.size.width * alertViewSize, height: viewController.view.bounds.width * alertViewSize)
        layer.cornerRadius = self.frame.width/2
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.8
        self.clipsToBounds = false

        // Setup Image View
        iconImageView.image = iconImage
        iconImageView.frame = CGRect(x: 0, y: 0, width: frame.size.width * imageViewSize, height: frame.size.width * imageViewSize)
        iconImageView.center = center
        iconImageView.center.y -= iconImageView.frame.size.height * imageViewOffsetFromCentre
        self.addSubview(iconImageView)

        // Setup Text Label
        titleLabel.text = title
        titleLabel.frame = CGRect(x: self.center.x - (frame.size.width * titleLabelWidth) / 2, y: iconImageView.frame.origin.y + iconImageView.frame.size.height - 5, width: frame.size.width * titleLabelWidth, height: titleLabelHeight)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.addSubview(titleLabel)

        //Position the alert
        positionAlertForPosition(position)

        if canbeDismissedByUser {
            let tagGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(GoogleWearAlertView.dismissAlert))
            self.addGestureRecognizer(tagGestureRecognizer)
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        NSException(name: NSExceptionName(rawValue: "init from storyboard error"), reason: "alert cannot be initalized from a storybaord", userInfo: nil).raise()
    }

    func dismissAlert() {
        GoogleWearAlert.sharedInstance.removeCurrentAlert(self)
    }

    func insideNavController() -> Bool {

        if let vc = viewController {
            if vc.parent is UINavigationController {
                return true
            } else if vc is UINavigationController {
                return true
            }
        }
        return false
    }

    @available(iOS 8.0, *)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection!) {
        layoutSubviews()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let position = alertPosition {
            positionAlertForPosition(position)
        }
    }

    func positionAlertForPosition(_ position:GoogleWearAlertPosition) {

        if UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation) {

            let centerX = viewController.view.bounds.width/2
            let centerY = viewController.view.bounds.height/2
            center = CGPoint(x: centerX, y: centerY)

        } else {

            switch position {
            case .top:
                center = CGPoint(x: viewController.view.center.x, y: viewController.view.frame.size.height / 4)
                if insideNavController() { center.y += navControllerHeight }

            case .center:
                center = viewController.view.center

            case .bottom:
                center = CGPoint(x: viewController.view.center.x, y: viewController.view.frame.size.height * 0.75)
            }
        }
    }
}
