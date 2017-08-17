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
    var path: WebPath
    
    init(path: WebPath) {
        self.path = path
    }
    init(path: WebPath, sectorNr: Int, sectorDist: CGFloat ) {
        self.path = path
        self.sectorNr = sectorNr
        self.sectorDist = sectorDist
    }
    func initValues(path: WebPath, sectorNr: Int, sectorDist: CGFloat ) {
        self.path = path
        self.sectorNr = sectorNr
        self.sectorDist = sectorDist
    }
    
    func isAtEnd() -> Bool {
        return self.path.isPositionAtEnd(self)
    }

    func isOn(_ position: WebPathPosition, margin: CGFloat) -> Bool {
        return abs(self.distanceInPath() - position.distanceInPath()) <= margin
    }
    func distanceInPath() -> CGFloat {
        return path.distanceForPosition(self)
    }
    func distanceTo(_ other: WebPathPosition) -> CGFloat {
        return abs(self.distanceInPath() - other.distanceInPath())
    }
    func point() -> CGPoint {
        return path.pointForPosition(self)
    }
    func copyFrom(_ position: WebPathPosition) {
        position.copyTo(self)
    }
    func copyTo(_ position: WebPathPosition) {
        position.initValues(path: self.path, sectorNr: self.sectorNr, sectorDist: self.sectorDist)
    }
}
