//
//  GameOverScene.swift
//  orient
//
//  Created by Frank on 10/07/16.
//  Copyright © 2016 FvH. All rights reserved.
//

import SpriteKit

class StartupScene: SubScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        self.addCenterLabel(text: "Tilt your device to let the", aligmnent: .bottom, size: 10)
        self.addCenterLabel(text: "fly slide down the rope.", aligmnent: .top, size: 12)
    }
}
