//
//  MainMenu.swift
//  StairTris
//
//  Created by George Hong on 7/17/17.
//  Copyright © 2017 George Hong. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import Firebase

class MainMenu: SKScene {
    
    var playButton: MSButtonNode!
    var tutorialButton: MSButtonNode!
    var settingsButton: MSButtonNode!
    weak static var viewController: GameViewController!
    var bannerView: GADBannerView!
    static var ranTutorial = true
    
    
    override func didMove(to view: SKView) {
        settingsButton = childNode(withName: "settingsButton") as! MSButtonNode
        settingsButton.selectedHandler = { [unowned self] in
            if let banner = self.bannerView {
                banner.removeFromSuperview()
            }
            let scene = Settings(fileNamed: "Settings")!
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        playButton = childNode(withName: "playButton") as! MSButtonNode
        playButton.selectedHandler = { [unowned self] in
            if let banner = self.bannerView {
                banner.removeFromSuperview()
            }
            if !MainMenu.ranTutorial {
                let scene = Tutorial(fileNamed: "Tutorial")!
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
                MainMenu.ranTutorial = true
            }
            else {
                let scene = GameScene(fileNamed: "GameScene")
                scene?.scaleMode = .aspectFit
                view.presentScene(scene)
            }
        }
        tutorialButton = childNode(withName: "tutorialButton") as! MSButtonNode
        tutorialButton.selectedHandler = { [unowned self] in
            if let banner = self.bannerView {
                banner.removeFromSuperview()
            }
            let scene = Tutorial(fileNamed: "Tutorial")!
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
            MainMenu.ranTutorial = true
        }
        
        if arc4random_uniform(2) == 0 {
            showAd() //Comment out this line if youre testing on an unapproved device
        }
    }
    
    func showAd() {
        print("show ad")
        /* If User.current is not nil, and that user has bought the ad pass */
        if Products.store.isProductPurchased(Products.removeAds) {
            return
        }
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerLandscape)
        bannerView.adUnitID = "ca-app-pub-8750198063494542/5405183582"
        bannerView.rootViewController = MainMenu.viewController
        let request = GADRequest()
        //request.testDevices = ["21174a67009c04267108ace0eda5f891"] // comment when releasing
        bannerView.load(request)
        view!.addSubview(bannerView)
    }
    
    
}
