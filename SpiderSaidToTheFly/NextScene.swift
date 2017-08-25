//
//  GameOverScene.swift
//  orient
//
//  Created by Frank on 10/07/16.
//  Copyright © 2016 FvH. All rights reserved.
//

import SpriteKit

class NextScene: SubScene {
    
    var game: Game?
    
    func setGame(_ game: Game) {
        self.game = game
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
  
        var labels = (game?.settings.subText)!
        labels.append("")
        labels.append("touch the screen to continue")
        self.addCenterLabels(mains: ["Level \(game!.level())"], subs: labels)
    }
}
