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

    
    
    override func didMove(to view: SKView) {
        //gridNode = childNode(withName: "//gridNode") as! Grid
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

        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("creating")
        let touch = touches.first!
        let location = touch.location(in: self)
        piece = (SKScene(fileNamed: "Piece")?.childNode(withName: "piece") as! SKSpriteNode).copy() as! Piece
        addChild(piece)
        piece.connectCells()
        piece.setup()
        //piece.declareType()
        piece.position = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        piece.position = location
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
