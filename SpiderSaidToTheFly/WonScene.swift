//
//  GameOverScene.swift
//  orient
//
//  Created by Frank on 10/07/16.
//  Copyright © 2016 FvH. All rights reserved.
//

import SpriteKit

class WonScene: SubScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        self.addCenterLabel(text: "You made it!", aligmnent: .bottom, size: 20)
        self.addCenterLabel(text: "Touch the screen to move to the next level", aligmnent: .top, size: 12)
    }
}
