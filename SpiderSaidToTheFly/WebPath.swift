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
        return WebPathPosition(path: self)
    }
    func lastPosition() -> WebPathPosition {
        let last = self.lastSectorNr()
        let dist = self.sectorDistance(last)
        return WebPathPosition(path: self, sectorNr: last, sectorDist: dist)
    }
    func scaleTo(_ scaleX: CGFloat, scaleY: CGFloat) {
        for (index, point) in points.enumerated() {
            points[index] = CGPoint(x: point.x * scaleX, y: point.y * scaleY)
        }
    }
    func fitIn(xmin: CGFloat, ymin: CGFloat, xmax: CGFloat, ymax: CGFloat) {
        let (myxmin, myymin, myxmax, myymax) = self.minMax()
        let xtrans = xmin - myxmin
        let ytrans = ymin - myymin
        let xscale = (xmax-xmin)/(myxmax-myxmin)
        let yscale = (ymax-ymin)/(myymax-myymin)
        
        for (index, point) in points.enumerated() {
            let newx = point.x + xtrans
            let newy = point.y + ytrans
            
            let relx = newx - xmin
            let rely = newy - ymin
            
            let transx = relx * xscale + xmin
            let transy = rely * yscale + ymin
            
            let newPoint = CGPoint(x: transx, y: transy )
            points[index] = newPoint
        }
    }
    func flipHorizontal() {
        let (_, ymin, _, ymax) = self.minMax()
        let midy = (ymax+ymin)/2
        for (index, point) in points.enumerated() {
            let rely = midy - point.y
            let newPoint = CGPoint(x: point.x, y: point.y + 2*rely )
            points[index] = newPoint
        }
        
    }
    func minMax() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        let aPoint = points[0]
        var myxmin = aPoint.x
        var myymin = aPoint.y
        var myxmax = aPoint.x
        var myymax = aPoint.y
        for point in self.points {
            myxmin = min(myxmin, point.x)
            myymin = min(myymin, point.y)
            myxmax = max(myxmax, point.x)
            myymax = max(myymax, point.y)
        }
        return (myxmin,myymin,myxmax,myymax)
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
            pos = WebPathPosition(path: self, sectorNr: sectorNr, sectorDist: sectorDist - leftToRun)
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
            pos = WebPathPosition(path: self, sectorNr: runningSectorNr, sectorDist: leftToRun)
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
    
    func isEmpty() -> Bool {
        return points.isEmpty
    }
    
    func count() -> Int {
        return points.count
    }
    
    func getPath() -> CGPath {
        let path = CGMutablePath()
        for point in points {
            path.move(to: point)
        }
        return path
    }
    
    func isPositionAtEnd(_ position: WebPathPosition) -> Bool {
        let last = self.lastSectorNr()
        if (position.sectorNr == last) {
            let dist = self.sectorDistance(last)
            return abs(dist-position.sectorDist) < 0.1
        } else {
            return false
        }
    }
    
    func length() -> CGFloat {
        var len = CGFloat(0)
        for (index, point) in points.enumerated() {
            if index > 0 {
                let prevPoint = points[index-1]
                let sectorDist = self.distance(p1: prevPoint, p2: point)
                len += sectorDist
            }
        }
        return len
    }
    
    private func lastSectorNr() -> Int {
        return self.points.count - 2
    }
    
    func cleanUp() {
        return
//        var newPoints : [CGPoint] = []
//        for point in points {
//            if newPoints.count > 0 {
//                let last = newPoints[newPoints.endIndex-1]
//                if (Int(point.x) == Int(last.x)) && (Int(point.y) == Int(last.y)) {
//                    continue
//                }
//            }
//            // If the point is linear to the last point
//            // then replace the last.
//            if newPoints.count > 1 {
//                let p1 = newPoints[newPoints.endIndex-2]
//                var p2 = newPoints[newPoints.endIndex-1]
//                
//                let a  = NAngle.betweenPoints(p1: p1, p2: p2)
//                let b = NAngle.betweenPoints(p1: p1, p2: point)
//                
//                let dif = a.difference(b)
//                let same = (abs(dif.value) < 0.001)
//                let toBig = (abs(dif.value) > 0.2)
//                if same || toBig{
//                    p2.x = point.x
//                    p2.y = point.y
//                    newPoints[newPoints.endIndex-1] = p2
//                    continue
//                }
//            }
//        newPoints.append(point)
//        }
//        self.points = newPoints
    }

}
