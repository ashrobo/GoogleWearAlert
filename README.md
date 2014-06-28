GoogleWearAlert
===============

An Android Wear style confirmation view for iOS - Written in Swift

This library is not intended as fully fledged alert view replacement (it has no buttons) this confirmation view is ideal 
for giving a success/fail/done/posted etc confirmation to the user.

The view has a number of customisations and you're welcome to tweak the constants to adjust the look/size/colors etc.

There are 4 different types already set up for you: Success, Error, Warning, Message (take a look at the screenshots)

**Take a look at the Example project to see how to use this library.** 

Follow the developer on Twitter: (http://twitter.com/a2hgo) (Ash Robinson)

![alt tag](http://i1058.photobucket.com/albums/t417/A2HGO/GoogleAlert.gif)

![alt tag](http://i1058.photobucket.com/albums/t417/A2HGO/Success.gif)
![alt tag](http://i1058.photobucket.com/albums/t417/A2HGO/Error-1.gif)
![alt tag]()
![alt tag]()


## Installation

Drag the "GoogleWearAlertView" folder from the example project into your project. This library requires ARC.

To show notifications use the following code:
--------

```objective-c

//Basic init
GoogleWearAlert.showAlert(title: "Success", type: .Success)

//Convenience init
GoogleWearAlert.showAlert(title:"Error", image:nil, type: .Error, duration: 2.0, inViewController: self)

//Full init      
GoogleWearAlert.showAlert(title: "Message", image: nil, type: .Message, duration: 2.0, inViewController: self, atPostion: .Bottom, canBeDismissedByUser: true)

//If using the basic init, it's recommended you set the default controller to present the alert in first
GoogleWearAlert.setDefaultViewController(self)

```

Consecutive calls will result in the alerts being queued and presented after the previous one has been dismissed.

Set canBeDismissedByUser to true to allow the user to tap to dismiss the alert.

The following properties can be set:

* **viewController**: The view controller to show the notification in. This might be the navigation controller.
* **title**: The title of the notification view
* **subtitle**: The text that is displayed underneath the title (optional)
* **image**: A custom icon image that is used instead of the default one (optional)
* **type**: The notification type (Message, Warning, Error, Success)
* **duration**: The duration the notification should be displayed

**Supports iOS7 and iOS8**

If you have ideas how to improve this library please let me know or send a pull request.

