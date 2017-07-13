//
//  Cell.swift
//  StairTris
//
//  Created by George Hong on 7/13/17.
//  Copyright © 2017 George Hong. All rights reserved.
//

import Foundation
import SpriteKit


class Cell: SKSpriteNode {
    
    /* You are required to implement this for your subclass to work */
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
