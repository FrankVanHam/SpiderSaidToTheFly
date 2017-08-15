//
//  SpeedControl.swift
//  orient
//
//  Created by Frank on 03/07/16.
//  Copyright © 2016 FvH. All rights reserved.
//

import Foundation
import CoreGraphics.CGBase

class SpeedControl {
    
    var lastTime: TimeInterval = 0
    var speed = CGFloat(0.0)
    
    init(_ speed: CGFloat) {
        self.speed = speed
    }
    
    func setSpeed(_ speed: CGFloat) {
        self.speed = speed
    }
    
    func moveDistance(_ current: TimeInterval) -> CGFloat {
        if lastTime == 0.0 {
            lastTime = current
            return 0
        } else {
            let dif = CGFloat(current - lastTime)
            return speed * dif
        }
    }
    
    func advance(current: TimeInterval) -> TimeInterval {
        let dif = current - lastTime
        lastTime = current
        return dif
    }
    
    
}
