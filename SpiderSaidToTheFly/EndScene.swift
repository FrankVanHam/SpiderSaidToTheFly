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
        
        var labels: [String] = []
        labels.append("")
        labels.append("touch the screen to start over")
        
        self.addCenterLabels( mains: ["You beat the spider"], subs: labels )
    }
}
