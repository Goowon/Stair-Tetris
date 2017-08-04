//
//  GameViewController.swift
//  StairTris
//
//  Created by George Hong on 7/11/17.
//  Copyright © 2017 George Hong. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Firebase
import AVFoundation


class GameViewController: UIViewController {

    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if let skView = view as? SKView, let scene = skView.scene as? GameScene {
                scene.shake()
            }
            if let skView = view as? SKView, let scene = skView.scene as? Tutorial {
                scene.shake()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Let Sound Mix
        do { try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true) } catch let error as NSError { print(error) }
        //
        
        MainMenu.viewController = self
        GameScene.viewController = self
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = MainMenu(fileNamed: "MainMenu") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
