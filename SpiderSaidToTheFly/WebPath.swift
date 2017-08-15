//
//  WebPath.swift
//  SpiderSaidToTheFly
//
//  Created by Frank on 14/08/2017.
//  Copyright © 2017 FvH. All rights reserved.
//

import Foundation
import CoreGraphics

class WebPath {
    
    var points : [CGPoint] = []
    
    init() {
    }
    
    func firstPosition() -> WebPathPosition {
        return WebPathPosition(rope: self)
    }
    func lastPosition() -> WebPathPosition {
        let last = self.lastSectorNr()
        let dist = self.sectorDistance(last)
        return WebPathPosition(rope: self, sectorNr: last, sectorDist: dist)
    }
    func scaleTo(_ scaleX: CGFloat, scaleY: CGFloat) {
        for (index, point) in points.enumerated() {
            points[index] = CGPoint(x: point.x * scaleX, y: point.y * scaleY)
        }
    }
    func movePosition(_ position: WebPathPosition, moveDist: CGFloat) -> WebPathPosition {
        if moveDist > 0 {
            return self.advancePosition(position, moveDist: moveDist)
        } else {
            return self.retreatPosition(position, moveDist: -moveDist)
        }
    }
    
    func advancePosition(_ position: WebPathPosition, moveDist: CGFloat) -> WebPathPosition {
        return self.intPositionForDistance(sectorNr: position.sectorNr, sectorDist: position.sectorDist, distance: moveDist)
    }
    
    func retreatPosition(_ position: WebPathPosition, moveDist: CGFloat) -> WebPathPosition {
        var sectorNr = position.sectorNr
        var runningDist = CGFloat(0)
        let runningTarget = self.sectorDistance(sectorNr) - position.sectorDist + moveDist // Add position dist as extra distance to run to uniform the algoritm
        
        var leftToRun = CGFloat(0)
        var sectorDist = CGFloat(0)
        repeat {
            sectorDist = self.sectorDistance(sectorNr)
            
            leftToRun = runningTarget - runningDist
            if (leftToRun > sectorDist) {
                runningDist += sectorDist
                sectorNr -= 1
            }
        } while (leftToRun > sectorDist) && (sectorNr >= 0)
        
        var pos: WebPathPosition
        if (leftToRun < sectorDist) {
            pos = WebPathPosition(rope: self, sectorNr: sectorNr, sectorDist: sectorDist - leftToRun)
        } else {
            pos = self.firstPosition()
        }
        return pos
    }

    func distanceForPosition(_ position: WebPathPosition) -> CGFloat {
        var runningSectorNr = 0
        var runningDist = CGFloat(0)
        
        while (runningSectorNr < position.sectorNr) && (runningSectorNr <= self.lastSectorNr()){
            let sectorDist = self.sectorDistance(runningSectorNr)
            runningDist += sectorDist
            runningSectorNr += 1
        }
        
        if (runningSectorNr == position.sectorNr) {
            runningDist += position.sectorDist
        }
        return runningDist
    }
    
    func positionForDistance(_ distance: CGFloat) -> WebPathPosition {
        return self.intPositionForDistance(sectorNr: 0, sectorDist: 0, distance: distance)
    }
    
    private func intPositionForDistance(sectorNr: Int, sectorDist: CGFloat, distance: CGFloat) -> WebPathPosition {
        var runningSectorNr = sectorNr
        var runningDist = CGFloat(0)
        let runningTarget = sectorDist + distance // Add position dist as extra distance to run to uniform the algoritm
        
        var leftToRun = CGFloat(0)
        var sectorDist = CGFloat(0)
        repeat {
            sectorDist = self.sectorDistance(runningSectorNr)
            
            leftToRun = runningTarget - runningDist
            if (leftToRun > sectorDist) {
                runningDist += sectorDist
                runningSectorNr += 1
            }
        } while (leftToRun > sectorDist) && (runningSectorNr <= self.lastSectorNr())
        
        var pos: WebPathPosition
        if (leftToRun < sectorDist) {
            pos = WebPathPosition(rope: self, sectorNr: runningSectorNr, sectorDist: leftToRun)
        } else {
            pos = self.lastPosition()
        }
        return pos
    }
    
    func angleAt(_ position: WebPathPosition) -> NAngle {
        if (position.sectorNr+1) >= points.count {
            return NAngle(0)
        }
        let p1 = points[position.sectorNr]
        let p2 = points[position.sectorNr+1]
        let angle = atan2((p2.y-p1.y),(p2.x-p1.x))
        return NAngle(angle)
    }
    func pointForPosition(_ position: WebPathPosition) -> CGPoint {
        if (position.sectorNr+1) >= points.count {
            return points.last!
        }
        let p1 = points[position.sectorNr]
        let p2 = points[position.sectorNr+1]
        let dist = position.sectorDist
        
        let angle = atan2((p2.y-p1.y),(p2.x-p1.x))
        let dx = cos(angle) * dist
        let dy = sin(angle) * dist
        
        return CGPoint(x: p1.x + dx, y: p1.y + dy)
    }
    
    private func sectorDistance(_ sectorNr: Int) -> CGFloat {
        let p1 = self.points[sectorNr]
        let p2 = self.points[sectorNr+1]
        return self.distance(p1: p1, p2: p2)
    }
    
    fileprivate func distance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let xd = p2.x - p1.x
        let yd = p2.y - p1.y
        return sqrt(xd*xd + yd*yd)
    }
    func empty() {
        points.removeAll()
    }
    func addPoint(_ point: CGPoint) {
        points.append(point)
    }
    
    func first() -> CGPoint {
        return points.first!
    }
    
    func last() -> CGPoint {
        return points.last!
    }
    
    func getPath() -> CGPath {
        let path = CGMutablePath()
        for point in points {
            path.move(to: point)
        }
        return path
    }
    
    func length() -> CGFloat {
        var len = CGFloat(0)
        for (index, point) in points.enumerated() {
            if index > 0 {
                let prevPoint = points[index-1]
                let sectorDist = sqrt(point.x * prevPoint.x + point.y * prevPoint.y)
                len += sectorDist
            }
        }
        return len
    }
    
    private func lastSectorNr() -> Int {
        return self.points.count - 2
    }
    
}