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
    case playing, dead, debug
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gridNode: Grid!
    var scoreLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var piece: Piece!
    var pieceArray: [Piece]!
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
    var currentState: GameState = .playing
    
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
                currentState = .dead
                gameOver.isHidden = false
                self.isPaused = true
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        let nodeAtPoint = atPoint(location)
        if nodeAtPoint.name == "gameOver" { return }
        if !touching {
            piece = (SKScene(fileNamed: "Piece")?.childNode(withName: "piece") as! SKSpriteNode).copy() as! Piece
            addChild(piece)
            piece.connectCells()
            piece.setup()
            piece.position = location
            if piece.position.x < -10 {
                piece.position.x = -10
            }
            touching = true
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
            if piece.position.x < -10 {
                piece.position.x = -10
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if secondFinger {
            secondFinger = false
        }
        else if piece != nil {
            if gridNode.validMove(piece: piece) {
                score += 1
                gridNode.addPiece(piece: piece)
                piece.removeFromParent()
                piece = nil
                touching = false
            }
        }
        
    }
    
    func makePieceArray(){
        for _ in 1...5 {
            piece = (SKScene(fileNamed: "Piece")?.childNode(withName: "piece") as! SKSpriteNode).copy() as! Piece
            piece.connectCells()
            piece.setup()
            pieceArray.append(piece)
        }
    }
    
    func resetTimer() {
        scrollTimer = 10
        hero.physicsBody?.applyImpulse(CGVector(dx:0,dy:8))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        scrollTimer -= fixedDelta
        timerLabel.text = String(Int(scrollTimer))
        scoreLabel.text = String(score)
        if scrollTimer > 0 { }
        else {
            resetTimer()
            gridNode.scrollCells()
        }
        hero.physicsBody?.applyForce(CGVector(dx:2, dy:0))
    }
}
