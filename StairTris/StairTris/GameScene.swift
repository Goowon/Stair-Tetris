//
//  GameScene.swift
//  StairTris
//
//  Created by George Hong on 7/11/17.
//  Copyright © 2017 George Hong. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var gridNode: Grid!
    var scoreLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var scrollLayer: SKNode!
    var piece: Piece!
    var pieceArray: [Piece]!
    var timer: CFTimeInterval = 5
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var newBlock = true
    var score: Int = 0
    
    
    override func didMove(to view: SKView) {
        gridNode = childNode(withName: "//gridNode") as! Grid
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        timerLabel = childNode(withName: "timerLabel") as! SKLabelNode
        scrollLayer = childNode(withName: "scrollLayer")!
        
        
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
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        nodeA.removeFromParent()
        nodeB.removeFromParent()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        if newBlock {
            piece = (SKScene(fileNamed: "Piece")?.childNode(withName: "piece") as! SKSpriteNode).copy() as! Piece
            addChild(piece)
            piece.connectCells()
            piece.setup()
            piece.position = location
            newBlock = false
        }
        else if nodeAtPoint.name == "piece" {
            piece.position = location
        }
        else if nodeAtPoint.name == "gridNode" {
            piece = (SKScene(fileNamed: "Piece")?.childNode(withName: "piece") as! SKSpriteNode).copy() as! Piece
            addChild(piece)
            piece.connectCells()
            piece.setup()
            piece.position = location
            newBlock = false
            timer = 5.0
        }
        else {
            piece.rotate()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if piece != nil {
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
        print("touch ended")
        if piece != nil {
            gridNode.addPiece(piece: piece)
            piece.removeFromParent()
            piece = nil
            resetTimer()
        }
        
    }
    
    func resetTimer() {
        timer = 5
        newBlock = true
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        timer -= fixedDelta
        if timer > 0 { return }
        else {
            resetTimer()
        }
        timerLabel.text = String(Int(timer))
        scoreLabel.text = String(score)
    }
}
