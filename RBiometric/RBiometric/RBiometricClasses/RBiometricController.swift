//
//  RBiometricController.swift
//  RBiometric
//
//  Created by Raj Sharma on 28/11/19.
//  Copyright © 2019 Raj Sharma. All rights reserved.
//

import UIKit

private let bt = RBiometric.shared.bioText

class RBiometricController: UIViewController {
    
   var onAuthSuccess : (() -> Void)?
   var onAuthError : ((RAuthError) -> (Void))?
    
   private var movedToSettings = false
   private var systemCancelledAuth = false
   var showAlertToEnableFromSetting = false

    init() {
        super.init(nibName: nil, bundle: nil)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func initialSetup() {
        addObservers()
        addBlurEffect()
    }
    
    private func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
    }
      
   func biometricAuthentication() {
      //print("biometricAuthentication start")
        RBiometric.biometricAuthentication() { [weak self] (result) in
         switch result {
            case .success( _): self?.processSuccess()
            case .failure(let error): self?.processError(error)
            }
        }
    }
    
    private func passcodeAuthentication(message: String) {
        //print("passcodeAuthentication start")
        RBiometric.passcodeAuthentication(reason: message) { [weak self] (result) in
            switch result {
            case .success( _): self?.processSuccess()
            case .failure(let error): self?.processError(error)
            }
        }
    }
}

// MARK:- Observer Section
extension RBiometricController {
    
    private func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appDidBecameActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
        
    @objc func appMovedToForeground() {
        //print("appMovedToForeground \(systemCancelledAuth)")
       if movedToSettings {
          movedToSettings = false
          biometricAuthentication()
       } else if systemCancelledAuth {
          systemCancelledAuth = false
         DispatchQueue.main.async { self.biometricAuthentication() }
       }
    }
    
    @objc func appDidBecameActive() {
        //print("appDidBecameActive \(systemCancelledAuth)")
       if systemCancelledAuth {
          systemCancelledAuth = false
          DispatchQueue.main.async { self.biometricAuthentication() }
       }
    }

    @objc func appMovedToBackground() {
        //print("App moved to Background!")
    }
}

extension RBiometricController {
   
   private func processError(_ error: RAuthError) {
      //print("process error block: \(error) \(error.message)")
    onAuthError?(error)

    switch error {
    case .systemCancel: self.systemCancelledAuth = true
    case .biometryNotEnrolled, .passcodeNotSet, .touchIdNotEnrolled:
        if showAlertToEnableFromSetting {
            askToEnableFromSetting(error: error)
        } else {
            showErrorAlert(error)
        }
    case .userFallback, .biometryLockedout: passcodeAuthentication(message: error.message)

    default: showErrorAlert(error)
    }
   }
   
   private func processSuccess() {
      dismiss(animated: true) { [weak self] in
         self?.onAuthSuccess?()
      }
   }
}

private extension RBiometricController {
    
    func showErrorAlert(_ error: RAuthError) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: error.message, message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: bt.tryAgain, style: .default) { [weak self]  action in
                self?.biometricAuthentication()
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func askToEnableFromSetting(error: RAuthError) {
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: error.message, message: "", preferredStyle: UIAlertController.Style.alert)

         if #available(iOS 10.0, *) {
            alert.addAction(UIAlertAction(title: bt.cancel, style: UIAlertAction.Style.default, handler: { _ in
                self.biometricAuthentication()
            }))
            alert.addAction(UIAlertAction(title: bt.settings,
                                          style: UIAlertAction.Style.destructive,
                                          handler: { (_: UIAlertAction) in
                                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                                            
                                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                             self.movedToSettings = true
                                               UIApplication.shared.open(settingsUrl, options: [:])
                                            }
            }))

         } else {
            alert.addAction(UIAlertAction(title: bt.tryAgain, style: UIAlertAction.Style.default, handler: { _ in
                self.biometricAuthentication()
            }))
         }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

