//
//  SignInFlowCoordinator.swift
//  GoodsScanner
//
//  Created by Alexander Kozlov on 8/12/19.
//  Copyright © 2019 iTomych. All rights reserved.
//

import UIKit

public protocol Coordinator {
    func start()
}

extension NSNotification.Name {
    static let logout = NSNotification.Name("logout")
}

public final class AuthFlowCoordinator: Coordinator {
    public let router: UINavigationController
    private let onCompletion: (ProfileModel) -> Void
    private var currentAuthKey: String?
    
    public init(completion: @escaping (ProfileModel) -> Void) {
        FontFamily.registerAllCustomFonts()
        router = StoryboardScene.Auth.initialScene.instantiate()
        onCompletion = completion
    }
    
    public func start() {
        if let authViewController = router.topViewController as? AuthViewController {
            authViewController.onSelectAuthByEmail = { [weak self] in
                self?.startAuthByEmail()
            }
            authViewController.onSelectAuthByPhone = { [weak self] in
                self?.startAuthByPhone()
            }
        }
    }
    
    private func startAuthByEmail() {
        let emailAuthViewController = StoryboardScene.Auth.emailAuth.instantiate()
        emailAuthViewController.onGetAuthCode = { [weak self] authKey in
            self?.currentAuthKey = authKey
            self?.showEmailConfirm()
        }
        router.pushViewController(emailAuthViewController, animated: true)
    }
    
    private func startAuthByPhone() {
        let phoneAuthViewController = StoryboardScene.Auth.phoneAuth.instantiate()
        phoneAuthViewController.onGetAuthCode = { [weak self] authKey in
            self?.currentAuthKey = authKey
            self?.showPhoneConfirm()
        }
        router.pushViewController(phoneAuthViewController, animated: true)
    }
    
    private func showEmailConfirm() {
        let emailConfirmViewController = StoryboardScene.Auth.emailConfirm.instantiate()
        emailConfirmViewController.currentAuthKey = currentAuthKey
        emailConfirmViewController.onAuthorize = { [weak self] tokens in
            self?.onAuthorize(tokens: tokens)
            emailConfirmViewController.getAppSettings()
        }
        emailConfirmViewController.onFinishAuth = { [weak self] profile in
            self?.onCompletion(profile)
        }
        router.pushViewController(emailConfirmViewController, animated: true)
    }
    
    private func showPhoneConfirm() {
        let phoneConfirmViewController = StoryboardScene.Auth.phoneConfirm.instantiate()
        phoneConfirmViewController.currentAuthKey = currentAuthKey
        phoneConfirmViewController.onAuthorize = { [weak self] tokens in
            self?.onAuthorize(tokens: tokens)
            phoneConfirmViewController.getAppSettings()
        }
        phoneConfirmViewController.onFinishAuth = { [weak self] profile in
            self?.onCompletion(profile)
        }
        router.pushViewController(phoneConfirmViewController, animated: true)
    }
    
    private func onAuthorize(tokens: AccessToken) {
        AuthController.shared.setAuth(tokens)
    }
}