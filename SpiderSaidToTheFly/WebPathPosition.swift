//
//  WebPathPosition.swift
//  SpiderSaidToTheFly
//
//  Created by Frank on 14/08/2017.
//  Copyright © 2017 FvH. All rights reserved.
//

import Foundation
import CoreGraphics

class WebPathPosition {
    
    var sectorNr = 0
    var sectorDist: CGFloat = 0.0
    var rope: WebPath
    
    init(rope: WebPath) {
        self.rope = rope
    }
    init(rope: WebPath, sectorNr: Int, sectorDist: CGFloat ) {
        self.rope = rope
        self.sectorNr = sectorNr
        self.sectorDist = sectorDist
    }
    func initValues(rope: WebPath, sectorNr: Int, sectorDist: CGFloat ) {
        self.rope = rope
        self.sectorNr = sectorNr
        self.sectorDist = sectorDist
    }

    func isOn(_ position: WebPathPosition, margin: CGFloat) -> Bool {
        return abs(self.distance() - position.distance()) <= margin
    }
    func distance() -> CGFloat {
        return rope.distanceForPosition(self)
    }
    func point() -> CGPoint {
        return rope.pointForPosition(self)
    }
    func copyFrom(_ position: WebPathPosition) {
        position.copyTo(self)
    }
    func copyTo(_ position: WebPathPosition) {
        position.initValues(rope: self.rope, sectorNr: self.sectorNr, sectorDist: self.sectorDist)
    }
}
