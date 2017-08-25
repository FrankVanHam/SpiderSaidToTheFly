//
//  GameSettings.swift
//  SpiderSaidToTheFly
//
//  Created by Frank on 17/08/2017.
//  Copyright © 2017 FvH. All rights reserved.
//

import Foundation
import SpriteKit

class LevelSettings {
    var spiderSpeed: CGFloat
    var flySpeed: CGFloat
    var flyPosition: CGFloat
    var subText: [String]
    
    init (spiderSpeed: CGFloat, flySpeed: CGFloat, flyPosition: CGFloat, subText: [String]) {
        self.spiderSpeed = spiderSpeed
        self.flySpeed = flySpeed
        self.flyPosition = flyPosition
        self.subText = subText
    }
    
}
