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
    
    private var lastTime: TimeInterval = 0
    private var speed = CGFloat(0.0)
    private var maxSpeed = CGFloat(0.0)
    
    init(maxSpeed: CGFloat, speed: CGFloat) {
        self.speed = speed
        self.maxSpeed = maxSpeed
    }
    
    func setSpeed(_ speed: CGFloat) {
        self.speed = speed
    }
    
    func percentage() -> CGFloat {
        return 100.0*(self.speed/self.maxSpeed)
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
    
    func moveDistanceIn(_ interval: TimeInterval) -> CGFloat {
        return speed * CGFloat(interval)
    }
    
    func advance(current: TimeInterval) -> TimeInterval {
        let dif = current - lastTime
        lastTime = current
        return dif
    }
    
    func throttle(_ perc: CGFloat) {
        self.speed = perc * self.maxSpeed
    }
    
    
}
