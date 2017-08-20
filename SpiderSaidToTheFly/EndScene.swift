//
//  GameOverScene.swift
//  orient
//
//  Created by Frank on 10/07/16.
//  Copyright © 2016 FvH. All rights reserved.
//

import SpriteKit

class EndScene: SubScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        self.addCenterLabel(text: "You beat the spider", aligmnent: .bottom, size: 20)
        self.addCenterLabel(text: "Touch the screen to start all over", aligmnent: .top, size: 12)
    }
}
