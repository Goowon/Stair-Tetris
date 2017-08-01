//
//  Settings.swift
//  StairTris
//
//  Created by George Hong on 8/1/17.
//  Copyright © 2017 George Hong. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import FirebaseAuthUI

class Settings: SKScene {
    
    var backButton: MSButtonNode!
    var removeAdsButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        removeAdsButton = childNode(withName: "removeAdsButton") as! MSButtonNode
        removeAdsButton.selectedHandler =  { [unowned self] in
            guard let authUI = FUIAuth.defaultAuthUI() else {
                return
            }
            authUI.delegate = self
            let authViewController = authUI.authViewController()
            MainMenu.viewController.present(authViewController, animated: true)
        }
        backButton = childNode(withName: "backButton") as! MSButtonNode
        backButton.selectedHandler = {
            let scene = MainMenu(fileNamed: "MainMenu")
            scene?.scaleMode = .aspectFit
            view.presentScene(scene)
        }
    }
}
extension Settings : FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let firUser = user else {
            return
        }
        UserService.show(forUID: firUser.uid) { (user) in
            if let user = user {
                /* If they signed in as an existing user */
                User.setCurrent(user, writeToUserDefaults: true)
            } else {
                UserService.create(firUser) { (newUser) in
                    /* Create a new user and set them as the current user */
                    if let newUser = newUser {
                        UserService.removeAds(forUID: newUser.uid) { (adlessUser) in
                            if let adlessUser = adlessUser {
                                User.setCurrent(adlessUser, writeToUserDefaults: true)
                            }
                        }
                    }
                    // TODO: Advertisement opt-out purchase
                }
            }
        }
    }
}
