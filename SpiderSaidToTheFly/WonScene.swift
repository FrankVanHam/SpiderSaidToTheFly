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
        
        var labels: [String] = []
        labels.append("Move to the next level")
        labels.append("")
        labels.append("touch the screen to continue")
        
        self.addCenterLabels(mains: ["You made it"], subs: labels)
    }
}
