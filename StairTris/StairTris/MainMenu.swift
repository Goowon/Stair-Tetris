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
    static var viewController: GameViewController!
    var bannerView: GADBannerView!
    
    
    override func didMove(to view: SKView) {
        playButton = childNode(withName: "playButton") as! MSButtonNode
        playButton.selectedHandler = {
            let scene = GameScene(fileNamed: "GameScene")
            scene?.scaleMode = .aspectFit
            view.presentScene(scene)
            if let banner = self.bannerView {
                banner.removeFromSuperview()
            }
        }
        tutorialButton = childNode(withName: "tutorialButton") as! MSButtonNode
        tutorialButton.selectedHandler = {
            let scene = Tutorial(fileNamed: "Tutorial")!
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
            if let banner = self.bannerView {
                banner.removeFromSuperview()
            }
        }
        
        if arc4random_uniform(2) == 0 {
            showAd()
        }
    }
    
    func showAd() {
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerLandscape)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = MainMenu.viewController
        bannerView.load(GADRequest())
        view!.addSubview(bannerView)
    }
    
    
}
