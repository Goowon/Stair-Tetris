//
//  GameScene.swift
//  StairTris
//
//  Created by George Hong on 7/11/17.
//  Copyright © 2017 George Hong. All rights reserved.
//

import SpriteKit
import GameplayKit

extension SKSpriteNode {
    
    func addGlow(radius: Float = 30) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        effectNode.name = "effectNode"
        addChild(effectNode)
        //does this cause a memory leak?
        effectNode.addChild(SKSpriteNode(texture: texture))
        effectNode.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius":radius])
    }
    
    func removeGlow(){
        self.childNode(withName: "effectNode")?.removeFromParent()
    }
}

enum GameState {
    case normal, debug
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    var currentState: GameState = .debug
    
    var filledLayerCount = 0
    var timeLimit: CFTimeInterval = 10
    var gridNode: Grid!
    var scoreLabel: SKLabelNode!
    var piece: Piece!
    var pieceArray: ArrayNode!
    var scrollTimer: CFTimeInterval = 10
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var secondFinger = false //newBlock = true
    var score: Int = 0
    var touching = false
    var hero: SKSpriteNode!
    var gameOver: SKSpriteNode!
    var restartButton: MSButtonNode!
    var mainMenuButton: MSButtonNode!
    var dieNowButton: MSButtonNode!
    var scrollLayer: SKNode!
    var offset: CGFloat = 0
    var canShake = false
    var jumpPower: CGFloat = 10
    var jumping = false
    var highScoreLabel: SKLabelNode!
    var sidePower: CGFloat = 3
    var dead = false
    var highScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: "highScore")
        }
        set(high) {
            UserDefaults.standard.set(high, forKey: "highScore")
        }
    }
    
    override func didMove(to view: SKView) {
        gridNode = childNode(withName: "//gridNode") as! Grid
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        hero = childNode(withName: "//hero") as! SKSpriteNode
        gameOver = childNode(withName: "gameOver") as! SKSpriteNode
        gameOver.isHidden = true
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
        dieNowButton.selectedHandler = {
            self.gameOver.isHidden = false
            self.isPaused = true
            self.dead = true
        }
        pieceArray = childNode(withName: "arrayNode") as! ArrayNode
        scrollLayer = childNode(withName: "//scrollLayer")!
        highScoreLabel = childNode(withName: "//highScoreLabel") as! SKLabelNode
        
        /*
         let jump = SKAction.run() {
         let hero = self.hero
         hero?.physicsBody?.applyImpulse(CGVector(dx: 2, dy: self.jumpPower))
         }
         let moveBack = SKAction(named: "movePlayerBack")!
         let takeOff = SKAction.sequence([moveBack, jump])
         takeOff.speed = CGFloat(1.0/(timeLimit-1))
         hero.run(takeOff)
         */
        
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
        if secondFinger {
            secondFinger = false
        }
        else if piece != nil {
            if gridNode.validMove(piece: piece,offset: offset) {
                score += 1
                gridNode.addPiece(piece: piece,offset: offset)
                piece.removeFromParent()
                piece = nil
                let sound = SKAction.playSoundFileNamed("NFF-menu-03-a", waitForCompletion: false)
                self.run(sound)
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
        if scrollTimer < 3.5 && !jumping {
            jumping = true
            let moveBack = SKAction(named: "movePlayerBack")!
            hero.run(moveBack)
        }
        scrollTheLayer()
        scrollTimer -= fixedDelta
        scoreLabel.text = String(score)
        if filledLayerCount == 1 {
            canShake = true
            hero.color = .brown
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
