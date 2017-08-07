//
//  Tutorial.swift
//  StairTris
//
//  Created by George Hong on 7/24/17.
//  Copyright © 2017 George Hong. All rights reserved.
//

import Foundation
import GameplayKit
import FirebaseAnalytics

class Tutorial: SKScene, SKPhysicsContactDelegate {
    
    enum GameState {
        case death, blockPlacement, arrayNode, rotateArea, paused, freePlay, doubleJump, useDoubleJump
    }
    
    var doubleJumpLabel2: SKLabelNode!
    var nextLessonLabel:SKLabelNode!
    var heroLabel: SKLabelNode!
    var pointerLayer: SKSpriteNode!
    var currentGameState: GameState = .death {
        didSet {
            switch currentGameState {
            case .blockPlacement:
                heroLabel.isHidden = true
                holdGesture.isHidden = false
                skipper.isHidden = true
                break
            case .arrayNode:
                nextBlockLabel.isHidden = false
                pointer.isHidden = false
                skipper.isHidden = true
                break
            case .rotateArea:
                holdGesture.isHidden = false
                skipper.isHidden = true
                break
            case .freePlay:
                break
            case .doubleJump:
                pointerLayer.isHidden = false
                tapGesture.isHidden = true
                holdGesture.isHidden = true
                pointer.isHidden = true
                nextBlockLabel.isHidden = true
                doubleJumpLabel.isHidden = false
                darkScreen5.isHidden = false
                skipper.isHidden = true
                break
            case .useDoubleJump:
                doubleJumpLabel.isHidden = true
                doubleJumpLabel2.isHidden = false
            default:
                break
            }
        }
    }
    
    var finishedLabel: SKLabelNode!
    var holdGesture: SKSpriteNode!
    var tapGesture: SKSpriteNode!
    var pointer: SKSpriteNode!
    var pointer2: SKSpriteNode!
    var nextBlockLabel: SKLabelNode!
    var timeLimit: CFTimeInterval = 2
    var gridNode: Grid!
    var scoreLabel: SKLabelNode!
    var piece: Piece!
    var pieceArray: ArrayNode!
    var scrollTimer: CFTimeInterval = 2
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    var secondFinger = false //newBlock = true
    var score: Int = 0
    var touching = false
    var hero: SKSpriteNode!
    var scrollLayer: SKNode!
    var offset: CGFloat = 0
    var canShake = false
    var jumpPower: CGFloat = 10
    var jumping = false
    var sidePower: CGFloat = 3
    var darkScreen5: SKSpriteNode!
    var nextButton: MSButtonNode!
    var skipper: MSButtonNode!
    var scaleLocation: CGPoint!
    var doubleJumpLabel: SKLabelNode!
    var doubleJumpScroll = false
    
    override func didMove(to view: SKView) {
        Analytics.logEvent("tutorial_started", parameters: [
            AnalyticsParameterItemID: "id-startedtutorial" as NSObject,
            AnalyticsParameterItemName: "startedtutorial" as NSObject,
            AnalyticsParameterContentType: "cont" as NSObject
            ])
        doubleJumpLabel2 = childNode(withName: "doubleJumpLabel2") as! SKLabelNode
        doubleJumpLabel2.isHidden = true
        doubleJumpLabel = childNode(withName: "doubleJumpLabel") as! SKLabelNode
        doubleJumpLabel.isHidden = true
        finishedLabel = childNode(withName: "finishedLabel") as! SKLabelNode
        finishedLabel.isHidden = true
        nextLessonLabel = childNode(withName: "nextLessonLabel") as! SKLabelNode
        nextLessonLabel.isHidden = true
        holdGesture = childNode(withName: "holdGesture") as! SKSpriteNode
        holdGesture.isHidden = true
        tapGesture = childNode(withName: "tapGesture") as! SKSpriteNode
        tapGesture.isHidden = true
        pointer = childNode(withName: "pointer") as! SKSpriteNode
        pointer.isHidden = true
        pointer2 = childNode(withName: "pointer2") as! SKSpriteNode
        pointer2.isHidden = true
        nextBlockLabel = childNode(withName: "nextBlockLabel") as! SKLabelNode
        nextBlockLabel.isHidden = true
        gridNode = childNode(withName: "//gridNode") as! Grid
        scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
        hero = childNode(withName: "//hero") as! SKSpriteNode
        pieceArray = childNode(withName: "arrayNode") as! ArrayNode
        scrollLayer = childNode(withName: "//scrollLayer")!
        pointerLayer = childNode(withName: "//pointerLayer") as! SKSpriteNode
        pointerLayer.isHidden = true
        darkScreen5 = childNode(withName: "darkScreen5") as! SKSpriteNode
        darkScreen5.isHidden = true
        heroLabel = childNode(withName: "heroLabel") as! SKLabelNode
        skipper = childNode(withName: "skipper") as! MSButtonNode
        skipper.isHidden = true
        skipper.selectedHandler = { [unowned self] in
            if self.currentGameState == .death {
                let scene = Tutorial(fileNamed: "Tutorial")!
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
                scene.currentGameState = .blockPlacement
            }
            else if self.currentGameState == .blockPlacement {
                let scene = Tutorial(fileNamed: "Tutorial")!
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
                scene.currentGameState = .blockPlacement
                scene.currentGameState = .rotateArea
            }
            else if self.currentGameState == .rotateArea {
                let scene = Tutorial(fileNamed: "Tutorial")!
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
                scene.currentGameState = .blockPlacement
                scene.currentGameState = .rotateArea
                scene.currentGameState = .arrayNode
                scene.tapGesture.isHidden = true
                scene.holdGesture.isHidden = true
            }
            else if self.currentGameState == .arrayNode || self.currentGameState == .freePlay {
                let scene = Tutorial(fileNamed: "Tutorial")!
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
                scene.currentGameState = .blockPlacement
                scene.currentGameState = .rotateArea
                scene.currentGameState = .arrayNode
                scene.currentGameState = .freePlay
                scene.currentGameState = .doubleJump
            }
            else {
                let scene = MainMenu(fileNamed: "MainMenu")!
                scene.scaleMode = .aspectFit
                view.presentScene(scene)
                Analytics.logEvent("tutorial_finished", parameters: [
                    AnalyticsParameterItemID: "id-finishedtutorial" as NSObject,
                    AnalyticsParameterItemName: "finishedtutorial" as NSObject,
                    AnalyticsParameterContentType: "cont" as NSObject
                    ])
            }
        }
        
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
        // One of them is hero and the other is the death blocks. else if it is a cell.
        if contactA.categoryBitMask == 1 || contactB.categoryBitMask == 1 {
            if (contactB.categoryBitMask == 4 || contactA.categoryBitMask == 4) && currentGameState == .death {
                self.isPaused = true
                nextLessonLabel.isHidden = false
                pointer2.isHidden = false
                skipper.isHidden = false
            }
            else if contactB.categoryBitMask == 2 || contactA.categoryBitMask == 2 {
                if contactA.categoryBitMask == 1 {
                    contactA.velocity = CGVector(dx: 0, dy: 0)
                    
                }
                else {
                    contactB.velocity = CGVector(dx: 0, dy: 0)
                }
                if jumpPower != 8 {
                    if currentGameState == .useDoubleJump {
                        pointer2.isHidden = false
                        finishedLabel.isHidden = false
                        skipper.isHidden = false
                    }
                }
                jumpPower = 8
                sidePower = 3
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == .death || currentGameState == .paused || currentGameState == .useDoubleJump { return }
        else if currentGameState == .doubleJump && !doubleJumpScroll {
            doubleJumpScroll = true
            currentGameState = .paused
            return
        }
        else if currentGameState == .useDoubleJump { return }
        if !holdGesture.isHidden && currentGameState == .rotateArea {
            holdGesture.isHidden = true
            tapGesture.isHidden = false
        }
        else if !holdGesture.isHidden && currentGameState == .blockPlacement {
            holdGesture.isHidden = true
        }
        else if currentGameState == .arrayNode {
            nextBlockLabel.isHidden = true
            pointer.isHidden = true
            //currentGameState = .blockPlacement
            //currentGameState = .rotateArea
            currentGameState = .freePlay
        }
        let touch = touches.first!
        let location = touch.location(in: self)
        let nodeAtPoint = atPoint(location)
        if nodeAtPoint.name == "gameOver" { return }
        if !touching && piece == nil {
            pieceArray.array[0].removeFromParent()
            piece = pieceArray.array[0]
            piece.xScale = 1
            piece.yScale = 1
            addChild(piece)
            piece.position = location
            if piece.position.x < 80 - offset {
                piece.position.x = 80 - offset
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
        if currentGameState != .death && currentGameState != .paused {
            if piece != nil && secondFinger != true {
                let touch = touches.first!
                let location = touch.location(in: self)
                piece.position = location
                //x clamp on left side
                if piece.position.x < 80 - offset {
                    piece.position.x = 80 - offset
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if secondFinger {
            secondFinger = false
        }
        else if piece != nil {
            if gridNode.validMove(piece: piece,offset: offset, hero: hero) {
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
        if canShake && currentGameState != .death {
            print("I am SHOOK")
            jumpPower = 12
            sidePower = 2
            canShake = false
            doubleJumpScroll = true
            doubleJumpLabel2.isHidden = true
            darkScreen5.isHidden = true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if piece != nil {
            if gridNode.validMove(piece: piece,offset: offset, hero: hero) {
                piece.alpha = 1
            } else {
                piece.alpha = 0.7
            }
        }
        if score == 5 {
            pointer2.isHidden = false
            skipper.isHidden = false
            if currentGameState == .doubleJump {
                finishedLabel.isHidden = false
            }
            else {
                nextLessonLabel.isHidden = false
            }
        }
        if currentGameState == .death || doubleJumpScroll {
            // Called before each frame is rendered
            if scrollTimer < 1.5 && !jumping {
                jumping = true
                let moveBack = SKAction(named: "FasterJump")!
                let squish = SKAction(named: "Squish")!
                let sequence = SKAction.sequence([moveBack, squish])
                hero.run(sequence)
            }
            scrollTheLayer()
            scrollTimer -= fixedDelta
            if scrollTimer > 0 {
            }
            else {
                if timeLimit > 5 {
                    timeLimit -= 1
                }
                resetTimer()
                doubleJumpScroll = false
                if !pointerLayer.isHidden {
                    pointerLayer.isHidden = true
                }
                if gridNode.scrollCells() {
                    canShake = true
                }
                if currentGameState == .paused {
                    currentGameState = .useDoubleJump
                }
            }
        }
        scoreLabel.text = String(score)
    }
    
    
    
    
    
}
