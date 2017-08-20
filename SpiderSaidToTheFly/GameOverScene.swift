//
//  GameOverScene.swift
//  orient
//
//  Created by Frank on 10/07/16.
//  Copyright © 2016 FvH. All rights reserved.
//

import SpriteKit

class GameOverScene: SubScene {
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        self.addCenterLabel(text: "Game over!", aligmnent: .bottom, size: 20)
        self.addCenterLabel(text: "Touch the screen to restart the game", aligmnent: .top, size: 12)
    }
}
