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
    var gridArray = [[Piece]]()
    
    /* Counters */
    var populationCounter = 0
    var generationCounter = 0
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        /* There will only be one touch as multi touch is not enabled by default */
        let touch = touches.first!
        let location = touch.location(in: self)
    }
    
    
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        /* Enable own touch implementation for this node */
        //isUserInteractionEnabled = true
        
        /* Calculate individual cell dimensions */
        cellWidth = Int(size.width) / columns
        cellHeight = Int(size.height) / rows
    }
}
