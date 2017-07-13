//
//  Grid.swift
//  StairTris
//
//  Created by George Hong on 7/11/17.
//  Copyright © 2017 George Hong. All rights reserved.
//

import Foundation
import SpriteKit

class Grid: SKSpriteNode {
    
    /* Grid array dimensions */
    let rows = 7
    let columns = 9
    
    /* Individual cell dimension, calculated in setup*/
    var cellWidth = 0
    var cellHeight = 0
    
    /* Creature Array */
    var gridArray = [[Cell]]()
    
    func addCellAtGrid(x: Int, y: Int){
        let cell = (SKScene(fileNamed: "Cell")?.childNode(withName: "cell") as! SKSpriteNode).copy() as! Cell
        let gridPosition = CGPoint(x: x*cellWidth+20, y: y*cellHeight+20)
        cell.position = gridPosition
        cell.isHidden = true
        addChild(cell)
        gridArray[x].append(cell)
    }
    
    func populateGrid() {
        /* Populate the grid with cells */
        
        /* Loop through columns */
        for gridX in 0..<columns {
            
            /* Initialize empty column */
            gridArray.append([])
            
            /* Loop through rows */
            for gridY in 0..<rows {
                
                /* Create a new cell at row / column position */
                addCellAtGrid(x:gridX, y:gridY)
            }
        }
    }
    
    
    func addPiece(piece: Piece) {
        //for loop iterate through children of piece
        //convert each piece's position to position on grid
        //use gridArray[Int(location.x)/cellWidth][Int(location.y)/cellHeight] to determine which cell on the grid it should go to
        //remove cell as child of parent
        //add cell as child of grid, set position to grid position that you determined
        for cell in piece.children as! [SKSpriteNode] {
            if cell.isHidden { continue }
            else {
                let position = piece.convert(cell.position, to: self.scene!)
                let location = (self.scene?.convert(position, to: self))!
                print(location)
                //gridArray[Int(location.x)/cellWidth][Int(location.y)/cellHeight] = cell as! Cell
                cell.removeFromParent()
                addChild(cell)
                cell.position.x = CGFloat((Int(location.x)/cellWidth)*cellWidth + cellWidth/2)
                cell.position.y = CGFloat((Int(location.y)/cellHeight)*cellHeight + cellHeight/2)
                print(location)
            }
        }
        piece.removeFromParent()
        addChild(piece)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        /* Calculate individual cell dimensions */
        cellWidth = Int(size.width) / columns
        cellHeight = Int(size.height) / rows
        
        //Populate grid with cells
        populateGrid()
    }
}
