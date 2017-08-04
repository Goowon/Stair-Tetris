//
//  Piece.swift
//  physicsdemo
//
//  Created by George Hong on 7/11/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import SpriteKit


enum Orientation: Int {
    case up = 1, left, down, right
}


enum PieceType: UInt32 {
    case square, z, zinv, l, linv, tri, line, normal
    
    static func allValues() -> [PieceType] {
        return [.square, .z, .zinv, .l, .linv, .tri, .line, .normal]
    }
    
    static func randomType() -> PieceType {
        // pick and return a new value
        let rand = arc4random_uniform(UInt32(PieceType.allValues().count-1))
        return PieceType.allValues()[Int(rand)]
    }
}

class Piece: SKSpriteNode {
    
    var type: PieceType = .normal {
        didSet {
            switch type {
            case .square:
                colorCells(color: .yellow)
                cell1.isHidden = true
                cell4.isHidden = true
                cell7.isHidden = true
                cell8.isHidden = true
                cell9.isHidden = true
                cell10.isHidden = true
                cell2.position.x -= 20
                cell2.position.y -= 20
                cell3.position.x -= 20
                cell3.position.y -= 20
                cell5.position.x -= 20
                cell5.position.y -= 20
                cell6.position.x -= 20
                cell6.position.y -= 20
            case .z:
                colorCells(color: .blue)
                cell3.isHidden = true
                cell4.isHidden = true
                cell7.isHidden = true
                cell8.isHidden = true
                cell9.isHidden = true
                cell10.isHidden = true
                cell1.position.y -= 20
                cell2.position.y -= 20
                cell5.position.y -= 20
                cell6.position.y -= 20
            case .zinv:
                colorCells(color: .green)
                cell1.isHidden = true
                cell6.isHidden = true
                cell7.isHidden = true
                cell8.isHidden = true
                cell9.isHidden = true
                cell10.isHidden = true
                cell2.position.y -= 20
                cell3.position.y -= 20
                cell4.position.y -= 20
                cell5.position.y -= 20
            case .l:
                colorCells(color: .red)
                cell1.isHidden = true
                cell3.isHidden = true
                cell4.isHidden = true
                cell6.isHidden = true
                cell7.isHidden = true
                cell10.isHidden = true
            case .linv:
                colorCells(color: .cyan)
                cell3.isHidden = true
                cell1.isHidden = true
                cell4.isHidden = true
                cell6.isHidden = true
                cell9.isHidden = true
                cell10.isHidden = true
            case .line:
                colorCells(color: .orange)
                cell2.isHidden = true
                cell1.isHidden = true
                cell3.isHidden = true
                cell7.isHidden = true
                cell8.isHidden = true
                cell9.isHidden = true
                cell4.position.x -= 20
                cell5.position.x -= 20
                cell6.position.x -= 20
                cell10.position.x -= 20
            case .tri:
                colorCells(color: .magenta)
                cell1.isHidden = true
                cell7.isHidden = true
                cell3.isHidden = true
                cell8.isHidden = true
                cell9.isHidden = true
                cell10.isHidden = true
            case .normal:
                break
            }
        }
    }
    
    var cell1: SKSpriteNode!
    var cell2: SKSpriteNode!
    var cell3: SKSpriteNode!
    var cell4: SKSpriteNode!
    var cell5: SKSpriteNode!
    var cell6: SKSpriteNode!
    var cell7: SKSpriteNode!
    var cell8: SKSpriteNode!
    var cell9: SKSpriteNode!
    var cell10: SKSpriteNode!
    
    func connectCells() {
        cell1 = childNode(withName: "cell1") as! SKSpriteNode
        cell2 = childNode(withName: "cell2") as! SKSpriteNode
        cell3 = childNode(withName: "cell3") as! SKSpriteNode
        cell4 = childNode(withName: "cell4") as! SKSpriteNode
        cell5 = childNode(withName: "cell5") as! SKSpriteNode
        cell6 = childNode(withName: "cell6") as! SKSpriteNode
        cell7 = childNode(withName: "cell7") as! SKSpriteNode
        cell8 = childNode(withName: "cell8") as! SKSpriteNode
        cell9 = childNode(withName: "cell9") as! SKSpriteNode
        cell10 = childNode(withName: "cell10") as! SKSpriteNode
    }
    
    func rotate() {
        if type == .square { return }
        zRotation += CGFloat(GLKMathDegreesToRadians(90))
    }
    
    /* You are required to implement this for your subclass to work */
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    func colorCells(color: UIColor) {
        cell1.color = color
        cell1.colorBlendFactor = 1
        cell2.color = color
        cell2.colorBlendFactor = 1
        cell3.color = color
        cell3.colorBlendFactor = 1
        cell4.color = color
        cell4.colorBlendFactor = 1
        cell5.color = color
        cell5.colorBlendFactor = 1
        cell6.color = color
        cell6.colorBlendFactor = 1
        cell7.color = color
        cell7.colorBlendFactor = 1
        cell8.color = color
        cell8.colorBlendFactor = 1
        cell9.color = color
        cell9.colorBlendFactor = 1
        cell10.color = color
        cell10.colorBlendFactor = 1
    }
    
    func setup() {
        type = PieceType.randomType()
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
