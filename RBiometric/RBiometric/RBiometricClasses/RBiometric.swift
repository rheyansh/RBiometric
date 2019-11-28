//
//  RBiometric.swift
//  RBiometric
//
//  Created by Raj Sharma on 28/11/19.
//  Copyright © 2019 Raj Sharma. All rights reserved.
//

import UIKit
import LocalAuthentication

open class RBiometric: NSObject {
    
    /// Shared instance
    static let shared = RBiometric()
    
    /// closure to observe authentication success
    var onAuthSuccess : (() -> Void)?
    
    /// closure to observe authentication failure

    var onAuthError : ((RAuthError) -> (Void))?
    
    /// Controller is responsible for authentication flow and process. Use this more controller customization and actions
    var controller: RBiometricController?
    
    /// If true, user will be redirected to Device Settings to enable biometric authentication. Once came back to app, authentication process will start automatically
    var canShowAlertToEnableFromSetting = true {
        didSet {
            controller?.showAlertToEnableFromSetting = canShowAlertToEnableFromSetting
        }
    }
    
    /// Biometric Authenticator context
    lazy var context: LAContext? = {
        return LAContext()
    }()
    
    /// Allows to set your own text on authentication contoller and dialogs
    lazy var bioText: RBiometricText = {
        return RBiometricText()
    }()
    
    /// Time interval for accepting a successful Touch ID or Face ID device unlock (on the lock screen) from the past
    var allowableReuseDuration: TimeInterval? = nil {
        didSet {
            guard let duration = allowableReuseDuration else { return }
            if #available(iOS 9.0, *) {
                self.context?.touchIDAuthenticationAllowableReuseDuration = duration
            }
        }
    }
    
    /// Prevent object construction in Swift
    private override init() { }
}

extension RBiometric {
    
    /// Open Biometric Authenticator with default options
    class func show() {
        
        let controller = RBiometric.shared.getBiometicController()
        
        controller.showAlertToEnableFromSetting = RBiometric.shared.canShowAlertToEnableFromSetting
        
        if let currentController = UIWindow.currentController {
            if !controller.isBeingPresented {
                // Present RBiometricController only if it is not already.
                currentController.present(controller, animated: false) {
                }
                controller.biometricAuthentication()
            }
        }
        
        controller.onAuthSuccess = { handleSuccess() }
        controller.onAuthError = { (error) in  handleError(error)}
    }
    
    /// Dismiss Biometric Authenticator
    class func dismissBiometric() {
        RBiometric.shared.controller?.dismiss(animated: true, completion: nil)
        RBiometric.shared.controller = nil
    }
    
    /**
        Show Passcode Authenticator
        - Parameter reason: Reason for requesting authentication, which displays in the authentication dialog presented to the user.
    */
    class func showPasscode(reason: String) {
        
        RBiometric.passcodeAuthentication(reason: reason) { (result) in
            switch result {
            case .success( _): handleSuccess()
            case .failure(let error): handleError(error)
            }
        }
    }
    
    /// Common function to handle authentication success
    class private func handleSuccess() {
        RBiometric.shared.onAuthSuccess?()
    }
    
    /// Common function to handle authentication failue
    class private func handleError(_ error: RAuthError) {
        //print("handleError error: \(error)")
        RBiometric.shared.onAuthError?(error)
    }
}

// MARK:- Private functions

extension RBiometric {
    
    private func getBiometicController() -> RBiometricController {
        
        if let vc = controller {
            //vc.showAlertToEnableFromSetting = RBiometric.shared.canShowAlertToEnableFromSetting
            return vc
        } else {
            controller = RBiometricController()
            //controller!.showAlertToEnableFromSetting = RBiometric.shared.canShowAlertToEnableFromSetting
            controller!.modalPresentationStyle = .overCurrentContext
            controller!.modalTransitionStyle = .crossDissolve
            return controller!
        }
    }
    
    private func evaluate(policy: LAPolicy, with context: LAContext, reason: String, completion: @escaping (Result<Bool, RAuthError>) -> ()) {
        
        context.evaluatePolicy(policy, localizedReason: reason) { (success, err) in
            DispatchQueue.main.async {
                if success {
                    DispatchQueue.main.async {
                        completion(.success(true))
                    }
                } else {
                    let errorType = RAuthError.error(err as! LAError)
                    completion(.failure(errorType))
                }
            }
        }
    }
}

// MARK:- Public functions

public extension RBiometric {
    
    /**
    Open Biometric Authenticator with more control options.
    
    - Parameters:
        - reason: Reason for requesting authentication, which displays in the authentication dialog presented to the user.
        - fallbackTitle: Allows fallback button title customization. If set to empty string, the button will be hidden. A default title "Enter Password" is used when this property is left nil.
        - cancelTitle: Set cancel button title customization. A default title "Cancel" is used when this property is left nil or is set to empty string.
        - completion: A closure that is executed when policy evaluation finishes.
     
     - returns: closure with sucess and failure.
*/
    class func biometricAuthentication(reason: String = "", fallbackTitle: String? = nil, cancelTitle: String? = "", completion: @escaping (Result<Bool, RAuthError>) -> Void) {
        
        let reasonString = reason.isEmpty ? RBiometric.defaultBiometricAuthReason : reason
        let fallbackTitle = fallbackTitle == nil ? bt.userFallbackAuth : fallbackTitle
        
        var context: LAContext!
        if RBiometric.shared.isReuseDurationSet {
            context = RBiometric.shared.context
        } else {
            context = LAContext()
        }
        context = LAContext()
        
        context.localizedFallbackTitle = fallbackTitle
        
        if #available(iOS 10.0, *) { context.localizedCancelTitle = cancelTitle }
        
        RBiometric.shared.evaluate(policy: .deviceOwnerAuthentication, with: context, reason: reasonString, completion: completion)
    }
    
    /**
        Show Passcode Authenticator  with more control options
        - Parameters:
            - reason: Reason for requesting authentication, which displays in the authentication dialog presented to the user.
            - fallbackTitle: Allows fallback button title customization. If set to empty string, the button will be hidden. A default title "Enter Password" is used when this property is left nil.
            - cancelTitle: Set cancel button title customization. A default title "Cancel" is used when this property is left nil or is set to empty string.
            - completion: A closure that is executed when policy evaluation finishes.
         
         - returns: closure with sucess and failure.
    */
    class func passcodeAuthentication(reason: String, cancelTitle: String? = "", completion: @escaping (Result<Bool, RAuthError>) -> ()) {
        
        let reasonString = reason.isEmpty ? RBiometric.defaultPasscodeAuthReason : reason
        let context = LAContext()
        
        if #available(iOS 10.0, *) { context.localizedCancelTitle = cancelTitle }
        
        // authenticate
        if #available(iOS 9.0, *) {
            RBiometric.shared.evaluate(policy: .deviceOwnerAuthentication, with: context, reason: reasonString, completion: completion)
        } else {
            RBiometric.shared.evaluate(policy: .deviceOwnerAuthenticationWithBiometrics, with: context, reason: reasonString, completion: completion)
        }
    }
}

// MARK:- Public Properties

public extension RBiometric {
    
    class var canAuthenticate: Bool {
        var isBiometricAuthenticationAvailable = false
        var error: NSError? = nil
        if LAContext().canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isBiometricAuthenticationAvailable = (error == nil)
        }
        return isBiometricAuthenticationAvailable
    }
    
    class var hasFaceID: Bool {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            return (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) && context.biometryType == .faceID)
        }
        return false
    }
    
    class var hasTouchID: Bool {
        let context = LAContext()
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if #available(iOS 11.0, *) {
            return canEvaluate && context.biometryType == .touchID
        }
        return canEvaluate
    }
}

// MARK:- Private Properties

private let bt = RBiometric.shared.bioText

extension RBiometric {
    
    private class var defaultBiometricAuthReason: String {
        return hasFaceID ? bt.faceIdAuthReason : bt.touchIdAuthReason
    }
    
    /// Reason to show while device passcode attempts failed after multiple time.
    private class var defaultPasscodeAuthReason: String {
        return hasFaceID ? bt.faceIdLockedReason : bt.touchIdLockedReason
    }
    
    /// checks if allowableReuseDuration is set
    private var isReuseDurationSet: Bool {
        guard allowableReuseDuration != nil else {
            return false
        }
        return true
    }
}

// MARK:- Private Extensions

private extension UIApplication {
    static var keyWindow: UIWindow? {
        
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        } else {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            return appDelegate?.window
        }
    }
}

private extension UIWindow {
    
    static var currentController: UIViewController? {
        return UIApplication.keyWindow?.currentController
    }
    
    var currentController: UIViewController? {
        if let vc = self.rootViewController {
            return topViewController(controller: vc)
        }
        return nil
    }
    
    func topViewController(controller: UIViewController? = UIApplication.keyWindow?.rootViewController) -> UIViewController? {
        if let nc = controller as? UINavigationController {
            if nc.viewControllers.count > 0 {
                return topViewController(controller: nc.viewControllers.last!)
            } else {
                return nc
            }
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

