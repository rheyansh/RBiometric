# RBiometric
Elegant and Easy-to-Use library for iOS Biometric (TouchId and FaceId) authentication.

# What's New
* Objective C Support [See How to use in Objective C Heading of this file]

# How to use
Add RBiometricClasses folder into your project.
You are ready to go!

**To open biometric authentication**

    RBiometric.show()
    
**To handle success case**

    RBiometric.shared.onAuthSuccess = { [weak self] in
            //success authentication
        }
        
**To handle error case**

    RBiometric.shared.onAuthError = { [weak self] (error) in
           if error == .userCancel {
              RBiometric.dismissBiometric()
           }
        }
# How to use in Objective C
**To open biometric authentication**

    [RBiometric show];
    
**To handle success case**

    RBiometric.shared.onAuthSuccess = ^{
             // on success
          };
         
# Author   

* [Raj Sharma](https://github.com/rheyansh)

## Communication

* If you **found a bug**, open an issue.
* If you **want to contribute**, submit a pull request.

# License
RPicker is available under the MIT license. See the LICENSE file for more info.

## Other Libraries

* [RPicker](https://github.com/rheyansh/RPicker):- Elegant and Easy-to-Use Date and Options Picker.
* [RFirebaseMessaging](https://github.com/rheyansh/RFirebaseMessaging):- Project provides basic idea and approach for building small social media application using firebase and implementing chat using Firebase.
* [RBeacon](https://github.com/rheyansh/RBeacon):- Sample project for turning android device into a Beacon device. App can work as both broadcaster and receiver.
* [RPdfGenerator](https://github.com/rheyansh/RPdfGenerator):- A sample project to generate PDF file from data using itextpdf/itext7 library.
