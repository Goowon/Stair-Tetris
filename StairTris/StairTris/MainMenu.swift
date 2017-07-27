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

class MainMenu: SKScene {
    
    var playButton: MSButtonNode!
    var tutorialButton: MSButtonNode!
    
    
    override func didMove(to view: SKView) {
        playButton = childNode(withName: "playButton") as! MSButtonNode
        playButton.selectedHandler = {
            let scene = GameScene(fileNamed: "GameScene")
            scene?.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        tutorialButton = childNode(withName: "tutorialButton") as! MSButtonNode
        tutorialButton.selectedHandler = {
            let scene = Tutorial(fileNamed: "Tutorial")!
            scene.scaleMode = .aspectFit
            view.presentScene(scene)
        }
    }
    
    
}
