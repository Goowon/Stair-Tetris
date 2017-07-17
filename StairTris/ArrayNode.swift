//
//  ArrayNode.swift
//  StairTris
//
//  Created by George Hong on 7/17/17.
//  Copyright © 2017 George Hong. All rights reserved.
//

import Foundation
import SpriteKit

class ArrayNode: SKSpriteNode {
    
    var columns = 5
    var cellHeight = 40
    var cellWidth = 0
    var array = [Piece]()
    
    func setUpArray(){
        for index in 0 ..< columns {
            let piece = (SKScene(fileNamed: "Piece")?.childNode(withName: "piece") as! SKSpriteNode).copy() as! Piece
            piece.connectCells()
            addChild(piece)
            piece.setup()
            array.append(piece)
            piece.position.y = 0
            piece.position.x = CGFloat(index*cellWidth + cellWidth/2)
            piece.xScale = 0.25
            piece.yScale = 0.25
        }
    }
    
    func moveArray() {
        for index in 0 ..< columns {
            if index < 4 {
                array[index] = array[index + 1]
                array[index].position.x = CGFloat(index*cellWidth + cellWidth/2)
            }
            if index == 4 {
                let piece = (SKScene(fileNamed: "Piece")?.childNode(withName: "piece") as! SKSpriteNode).copy() as! Piece
                piece.connectCells()
                addChild(piece)
                piece.setup()
                array[4] = piece
                piece.position.y = 0
                piece.position.x = CGFloat(index*cellWidth + cellWidth/2)
                piece.xScale = 0.25
                piece.yScale = 0.25
            }
        }
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        cellWidth = Int(size.width) / columns
    }
    
}
