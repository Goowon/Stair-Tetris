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
import StoreKit

class Settings: SKScene {
    
    // Buttons
    var backButton: MSButtonNode!
    var removeAdsButton: MSButtonNode!
    var soundButton: MSButtonNode!
    
    // Labels
    
    override func didMove(to view: SKView) {
        removeAdsButton = childNode(withName: "removeAdsButton") as! MSButtonNode
        removeAdsButton.selectedHandler =  {
            /*guard let authUI = FUIAuth.defaultAuthUI() else {
                return
            }
            authUI.delegate = self
            let authViewController = authUI.authViewController()
            MainMenu.viewController.present(authViewController, animated: true)*/
            let productID = Products.removeAds
            var product: SKProduct?
            Products.store.requestProducts { success, products in
                if success {
                    for prod in products! {
                        print(prod.productIdentifier)
                    }
                    product = products!.first(where: {product in product.productIdentifier == productID})
                    if Products.store.isProductPurchased(productID) {
                        print("Should display message to user about ads already removed (or disable this button entirely)")
                        return
                    } else if StoreService.canMakePayments() {
                        if let product = product {
                            Products.store.buyProduct(product)
                        } else {
                            print("Should display message to user about failed to find product")
                        }
                    } else {
                        print("Should display message to user about unable to make payments")
                    }
                }
            }
        }
        backButton = childNode(withName: "backButton") as! MSButtonNode
        backButton.selectedHandler = {
            let scene = MainMenu(fileNamed: "MainMenu")
            scene?.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        soundButton = childNode(withName: "soundButton") as! MSButtonNode
        soundButton.selectedHandler = { [unowned self] in
            if GameScene.disableSound {
                GameScene.disableSound = false
                self.soundButton.texture = SKTexture(imageNamed: "b_Sound1")
            }
            else {
                self.soundButton.texture = SKTexture(imageNamed: "b_Sound1_Inactive")
                GameScene.disableSound = true
            }
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
