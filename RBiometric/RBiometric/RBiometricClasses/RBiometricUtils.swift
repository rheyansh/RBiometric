//
//  RBiometricUtils.swift
//  RBiometric
//
//  Created by Raj Sharma on 28/11/19.
//  Copyright © 2019 Raj Sharma. All rights reserved.
//

import UIKit
import LocalAuthentication

class RBiometricText {
   
   //General ---------------------
   
   var appCancelAuth = "Authentication was cancelled by application."
   var invalidCredentails = "Failed to provide valid credentials."
   var biometryNotAvailableReason = "Biometric authentication is not available for this device."
   var systemCancelledAuth = "Biometric authentication is cancelled by system."
   var userCancelledAuth = "Authentication was cancelled by user"
    var userFallbackAuth = "Enter Passcode"
   var invalidContext = "The context is invalid"

   var settings = "Settings"
   var cancel = "Cancel"
   var tryAgain = "Try Again"

   //Touch ID ---------------------

   var touchIdAuthReason = "Touch ID required to authenticate."
   var touchIdLockedReason = "Touch ID is locked now, because of too many failed attempts. Enter passcode to unlock Touch ID."

   var setPasscodeForTouchID = "Please set device passcode to use Touch ID for authentication."
   var noFingerprintEnrolled = "There are no fingerprints enrolled in the device. Please go to Device Settings -> Touch ID & Passcode and enroll your fingerprints."
   var defaultTouchIDAuthFailedReason = "Touch ID does not recognize your fingerprint. Please try again with your enrolled fingerprint."

   //Face ID ---------------------

   var faceIdAuthReason = "Face ID required to authenticate."
   var faceIdLockedReason = "Face ID is locked now, because of too many failed attempts. Enter passcode to unlock Face ID."

   var setPasscodeForFaceID = "Please set device passcode to use Face ID for authentication."
   var noFaceIdentityEnrolled = "There is no face enrolled in the device. Please go to Device Settings -> Face ID & Passcode and enroll your face."
   var defaultFaceIDAuthFailedReason = "Face ID does not recognize your face. Please try again with your enrolled face."
   
}

private let bt = RBiometric.shared.bioText

public enum RAuthError: Error {
    
    case appCancel, failed, userCancel, userFallback, systemCancel, passcodeNotSet, biometryNotEnrolled, biometryLockedout, touchIdLockedout, invalidContext , biometryNotAvailable, touchIdNotAvailable, touchIdNotEnrolled, other
    
    public static func error(_ error: LAError) -> RAuthError {
        switch Int32(error.errorCode) {
            
        case kLAErrorAuthenticationFailed:
            return failed
        case kLAErrorUserCancel:
            return userCancel
        case kLAErrorUserFallback:
            return userFallback
        case kLAErrorSystemCancel:
            return systemCancel
        case kLAErrorPasscodeNotSet:
            return passcodeNotSet
         case kLAErrorAppCancel:
             return appCancel
         case kLAErrorInvalidContext:
             return invalidContext
        case kLAErrorBiometryNotEnrolled:
            return biometryNotEnrolled
        case kLAErrorBiometryLockout:
            return biometryLockedout
        case kLAErrorBiometryNotAvailable:
            return biometryNotAvailable
         case kLAErrorTouchIDNotAvailable:
             return touchIdNotAvailable
         case kLAErrorTouchIDNotEnrolled:
             return touchIdNotEnrolled
         case kLAErrorTouchIDLockout:
             return touchIdLockedout

        default:
           return other
        }
    }
    
    var message: String {
        switch self {
        case .appCancel: return bt.appCancelAuth
            
        case .failed: return bt.invalidCredentails
                        
        case .userFallback: return bt.userFallbackAuth
            
        case .userCancel: return bt.userCancelledAuth
        
        case .passcodeNotSet: return RBiometric.hasFaceID ? bt.setPasscodeForFaceID : bt.setPasscodeForTouchID

        case .systemCancel: return bt.systemCancelledAuth
            
        case .biometryNotAvailable: return bt.biometryNotAvailableReason

         case .touchIdNotAvailable: return bt.biometryNotAvailableReason

        case .biometryNotEnrolled: return bt.noFaceIdentityEnrolled
            
         case .touchIdNotEnrolled: return bt.noFingerprintEnrolled

        case .biometryLockedout: return bt.faceIdLockedReason
         
        case .touchIdLockedout: return bt.touchIdLockedReason

        case .other, .invalidContext: return RBiometric.hasFaceID ? bt.defaultFaceIDAuthFailedReason : bt.defaultTouchIDAuthFailedReason
       
        }
    }
}
