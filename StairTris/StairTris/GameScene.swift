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
    
    var timeLimit: CFTimeInterval = 10
    var gridNode: Grid!
    var scoreLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var piece: Piece!
    var pieceArray: ArrayNode!
    var scrollTimer: CFTimeInterval = 10
    var lockTimer: CFTimeInterval = 3
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var secondFinger = false //newBlock = true
    var lastScoreAt: CGFloat = -245.5
    var score: Int = 0
    var rotateArea: SKSpriteNode!
    var touching = false
    var hero: SKSpriteNode!
    var gameOver: SKSpriteNode!
    var restartButton: MSButtonNode!
    var clearScreen: SKSpriteNode!
    var scrollLayer: SKNode!
    var offset: CGFloat = 0
    var canShake = true
    var jumpPower: CGFloat = 8
    var jumping = false
    var lastGround: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        gridNode = childNode(withName: "//gridNode") as! Grid
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        timerLabel = childNode(withName: "timerLabel") as! SKLabelNode
        rotateArea = childNode(withName: "rotateArea") as! SKSpriteNode
        hero = childNode(withName: "hero") as! SKSpriteNode
        gameOver = childNode(withName: "gameOver") as! SKSpriteNode
        gameOver.isHidden = true
        restartButton = childNode(withName: "//restartButton") as! MSButtonNode
        restartButton.selectedHandler = {
            let scene = GameScene(fileNamed: "GameScene")
            scene?.scaleMode = .aspectFit
            view.presentScene(scene)
        }
        clearScreen = childNode(withName: "clearScreen") as! SKSpriteNode
        clearScreen.isHidden = true
        pieceArray = childNode(withName: "arrayNode") as! ArrayNode
        scrollLayer = childNode(withName: "//scrollLayer")!
        
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
                if currentState == .normal {
                    clearScreen.isHidden = false
                }
            }
            else if contactB.categoryBitMask == 2 || contactA.categoryBitMask == 2 {
                //jumping = false
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        let nodeAtPoint = atPoint(location)
        if nodeAtPoint.name == "gameOver" { return }
        if !touching {
            pieceArray.array[0].removeFromParent()
            piece = pieceArray.array[0]
            piece.xScale = 1
            piece.yScale = 1
            addChild(piece)
            piece.position = location
            if piece.position.x < -10 - offset {
                piece.position.x = -10 - offset
            }
            touching = true
            pieceArray.moveArray()
        }
        else if touching && nodeAtPoint.name == "rotateArea" {
            secondFinger = true
            if piece.type != .square {
                piece.rotate()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if piece != nil && secondFinger != true {
            let touch = touches.first!
            let location = touch.location(in: self)
            piece.position = location
            //x clamp on left side
            if piece.position.x < -10 - offset {
                piece.position.x = -10 - offset
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
                touching = false
            }
        }
    }
    
    func scrollTheLayer() {
        scrollLayer.position.y -= CGFloat((40*fixedDelta)/timeLimit)
        scrollLayer.position.x -= CGFloat((fixedDelta*40)/timeLimit)
        offset += CGFloat((fixedDelta*40)/timeLimit)
    }
    
    func resetTimer() {
        /*
        let jump = SKAction.run() {
            let hero = self.hero
            hero?.physicsBody?.applyImpulse(CGVector(dx: 2, dy: self.jumpPower))
        }
        let moveBack = SKAction(named: "movePlayerBack")!
        moveBack.speed = CGFloat(1.0/(timeLimit-1))
        let takeOff = SKAction.sequence([moveBack, jump])
        hero.run(takeOff)*/
        scrollTimer = timeLimit
        offset = 0
    }
    
    func shake() {
        if canShake {
            print("I am SHOOK")
            jumping = false
            jumpPower += 4
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        let stairs = nodes(at: CGPoint(x: hero.position.x + 15, y: hero.position.y))
        for node in stairs {
            if node.physicsBody?.categoryBitMask == 2 && !jumping {
                hero.physicsBody?.applyImpulse(CGVector(dx: 0.25, dy: self.jumpPower))
                if jumpPower != 8 {
                    jumpPower = 8
                }
                jumping = true
            }
        }
        let ground = nodes(at: CGPoint(x: hero.position.x, y: hero.position.y - 20))
        for node in ground {
            if node.physicsBody?.categoryBitMask == 2 {
                if node != lastGround {
                    lastGround = node as! SKSpriteNode
                    jumping = false
                }
            }
        }
        /*
        if hero.physicsBody?.velocity == CGVector(dx:0 , dy: 0) {
            jumping = false
        }*/
        // Called before each frame is rendered
        scrollTheLayer()
        scrollTimer -= fixedDelta
        timerLabel.text = String(Int(scrollTimer))
        scoreLabel.text = String(score)
        if scrollTimer > 0 {
        }
        else {
            if timeLimit > 5 {
                timeLimit -= 1
            }
            resetTimer()
            gridNode.scrollCells()
        }
    }
}
