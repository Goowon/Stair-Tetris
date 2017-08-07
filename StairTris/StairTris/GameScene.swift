//
//  GameScene.swift
//  StairTris
//
//  Created by George Hong on 7/11/17.
//  Copyright © 2017 George Hong. All rights reserved.
//

import SpriteKit
import GameplayKit
import Firebase


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Ads
    static weak var viewController: GameViewController!
    var interstitial: GADInterstitial!
    
    // Double Jump Mechanic
    var filledLayerCount = 0
    var canShake = false
    var jumpPower: CGFloat = 10
    var sidePower: CGFloat = 3
    
    // Scroll Mechanic
    var timeLimit: CFTimeInterval = 10
    var scrollTimer: CFTimeInterval = 10
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var scrollLayer: SKNode!
    
    // Grid Placement Mechanic
    var gridNode: Grid!
    var piece: Piece!
    var pieceArray: ArrayNode!
    var offset: CGFloat = 0
    
    // Labels
    var scoreLabel: SKLabelNode!
    var score: Int = 0
    var highScoreLabel: SKLabelNode!
    var highScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: "highScore")
        }
        set(high) {
            UserDefaults.standard.set(high, forKey: "highScore")
        }
    }
    
    // Touch Mechanic
    var secondFinger = false //newBlock = true
    var touching = false
    
    // Automatic Mechanics
    var hero: SKSpriteNode!
    var gameOver: SKSpriteNode!
    var jumping = false
    var dead = false
    
    // Buttons
    var restartButton: MSButtonNode!
    var mainMenuButton: MSButtonNode!
    var dieNowButton: MSButtonNode!
    var pauseButton: MSButtonNode!
    var playButton: MSButtonNode!
    
    //Settings
    static var disableSound: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "disableSounds")
        }
        set(use) {
            UserDefaults.standard.set(use, forKey: "disableSounds")
        }
    }
    
    
    func loadAd() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.load(GADRequest())
    }
    
    func showAd() {
        if Products.store.isProductPurchased(Products.removeAds) {
            return
        }
        if let ad = interstitial {
            if ad.isReady {
                interstitial.present(fromRootViewController: GameScene.viewController )
            } else {
                print("Ad wasn't ready")
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        // Game Mechanics
        gridNode = childNode(withName: "//gridNode") as! Grid
        hero = childNode(withName: "//hero") as! SKSpriteNode
        // Labels
        scoreLabel = childNode(withName: "//scoreLabel") as! SKLabelNode
        gameOver = childNode(withName: "gameOver") as! SKSpriteNode
        gameOver.isHidden = true
        // Buttons
        restartButton = childNode(withName: "//restartButton") as! MSButtonNode
        restartButton.selectedHandler = {
            let scene = GameScene(fileNamed: "GameScene")
            scene?.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        mainMenuButton = childNode(withName: "//mainMenuButton") as! MSButtonNode
        mainMenuButton.selectedHandler = {
            let scene = MainMenu(fileNamed: "MainMenu")
            scene?.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        dieNowButton = childNode(withName: "//dieNowButton") as! MSButtonNode
        dieNowButton.selectedHandler = { [unowned self] in
            self.gameOver.isHidden = false
            self.isPaused = true
            self.dead = true
            if arc4random_uniform(4) == 0 {
                self.showAd()
            }
        }
        pauseButton = childNode(withName: "//pauseButton") as! MSButtonNode
        pauseButton.selectedHandler = { [unowned self] in
            self.pauseButton.isHidden = true
            self.playButton.isHidden = false
            self.isPaused = true
    
        }
        playButton = childNode(withName: "//playButton") as! MSButtonNode
        playButton.isHidden = true
        playButton.selectedHandler = { [unowned self] in
            self.playButton.isHidden = true
            self.pauseButton.isHidden = false
            self.isPaused = false
        }
        pieceArray = childNode(withName: "arrayNode") as! ArrayNode
        scrollLayer = childNode(withName: "//scrollLayer")!
        highScoreLabel = childNode(withName: "//highScoreLabel") as! SKLabelNode
        
        loadAd()
        
        pieceArray.setUpArray()
        
        physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        if contactA.node == nil {
            return
        }
        if contactB.node == nil {
            return
        }
        /* Get references to the physics body parent SKSpriteNode */
        // let nodeA = contactA.node as! SKSpriteNode
        // let nodeB = contactB.node as! SKSpriteNode
        if contactA.categoryBitMask == 1 || contactB.categoryBitMask == 1 {
            if contactB.categoryBitMask == 4 || contactA.categoryBitMask == 4 {
                gameOver.isHidden = false
                self.isPaused = true
                dead = true
                showAd()
            }
            else if contactB.categoryBitMask == 2 || contactA.categoryBitMask == 2 {
                if contactA.categoryBitMask == 1 {
                    contactA.velocity = CGVector(dx: 0, dy: 0)
                    
                }
                else {
                    contactB.velocity = CGVector(dx: 0, dy: 0)
                }
                if jumpPower != 8 {
                    hero.color = .cyan
                }
                jumpPower = 8
                sidePower = 3
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isPaused { return }
        let touch = touches.first!
        let location = touch.location(in: self)
        let nodeAtPoint = atPoint(location)
        if nodeAtPoint.name == "gameOver" { return }
        if !touching && !dead && piece == nil {
            pieceArray.array[0].removeFromParent()
            piece = pieceArray.array[0]
            piece.xScale = 1
            piece.yScale = 1
            addChild(piece)
            piece.position = location
            if piece.position.x < -144 - offset {
                piece.position.x = -144 - offset
            }
            pieceArray.moveArray()
        }
        else if touching {
            secondFinger = true
            if piece.type != .square {
                piece.rotate()
            }
        }
        touching = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPaused { return }
        if piece != nil && !secondFinger && !dead {
            let touch = touches.first!
            let location = touch.location(in: self)
            piece.position = location
            //x clamp on left side
            if piece.position.x < -144 - offset {
                piece.position.x = -144 - offset
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isPaused { return }
        if secondFinger {
            secondFinger = false
        }
        else if piece != nil {
            if gridNode.validMove(piece: piece,offset: offset, hero: hero) {
                score += 1
                gridNode.addPiece(piece: piece,offset: offset)
                piece.removeFromParent()
                piece = nil
                if !GameScene.disableSound {
                    let sound = SKAction.playSoundFileNamed("NFF-menu-03-a", waitForCompletion: false)
                    self.run(sound)
                }
            }
            touching = false
        }
    }
    
    func scrollTheLayer() {
        scrollLayer.position.y -= CGFloat((40*fixedDelta)/timeLimit)
        scrollLayer.position.x -= CGFloat((fixedDelta*40)/timeLimit)
        offset += CGFloat((fixedDelta*40)/timeLimit)
    }
    
    func resetTimer() {
        hero?.physicsBody?.applyImpulse(CGVector(dx: sidePower, dy: self.jumpPower))
        jumping = false
        scrollTimer = timeLimit
        offset = 0
        let unsquish = SKAction(named: "Unsquish")!
        hero.run(unsquish)
    }
    
    func shake() {
        if canShake {
            print("I am SHOOK")
            jumpPower = 11
            sidePower = 2
        }
        canShake = false
        filledLayerCount = 0
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if piece != nil {
            if gridNode.validMove(piece: piece,offset: offset, hero: hero) {
                piece.alpha = 1
            } else {
                piece.alpha = 0.5
            }
        }
        if scrollTimer < 3.5 && !jumping {
            jumping = true
            let moveBack = SKAction(named: "movePlayerBack")!
            let squish = SKAction(named: "Squish")!
            let sequence = SKAction.sequence([moveBack, squish])
            hero.run(sequence)
            
        }
        scrollTheLayer()
        scrollTimer -= fixedDelta
        scoreLabel.text = String(score)
        if filledLayerCount == 1 {
            canShake = true
            hero.color = .yellow
        }
        if scrollTimer > 0 {
        }
        else {
            if timeLimit > 4 {
                timeLimit -= 1
            }
            resetTimer()
            if gridNode.scrollCells() {
                filledLayerCount += 1
            }
        }
        if score > highScore {
            highScore = score
        }
        highScoreLabel.text = String(highScore)
    }
}
