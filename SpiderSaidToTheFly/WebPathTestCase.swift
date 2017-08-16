//
//  WebPathTestCase.swift
//  SpiderSaidToTheFly
//
//  Created by Frank on 15/08/2017.
//  Copyright © 2017 FvH. All rights reserved.
//

import XCTest
@testable import SpiderSaidToTheFly

class WebPathTestCase: XCTestCase {
    
    private var path : WebPath?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPositionForDistance() {
        path = WebPath()
        path!.addPoint(CGPoint(x: 0,   y: 0))
        path!.addPoint(CGPoint(x: 100, y: 0))
        let pos = path?.positionForDistance(50)
        XCTAssertTrue(pos?.sectorDist == 50)
        XCTAssertTrue(pos?.distance() == 50)
    }
    
    func testDistance() {
        path = WebPath()
        path!.addPoint(CGPoint(x: 0,   y: 0))
        path!.addPoint(CGPoint(x: 100, y: 0))
        path!.addPoint(CGPoint(x: 200, y: 0))
        XCTAssertTrue(path?.length() == 200)
    }
    
    func testPosDistanceInSector() {
        path = WebPath()
        path!.addPoint(CGPoint(x: 0,   y: 0))
        path!.addPoint(CGPoint(x: 100, y: 0))
        
        self.assertDistance(setDist: 10, testDist: 10)
        self.assertDistance(setDist: 110, testDist: 100)
    }
    
    func testPosDistance() {
        path = WebPath()
        path!.addPoint(CGPoint(x: 0,   y: 0))
        path!.addPoint(CGPoint(x: 100, y: 0))
        path!.addPoint(CGPoint(x: 200, y: 0))
        path!.addPoint(CGPoint(x: 300, y: 0))
        
        self.assertDistance(setDist: 150, testDist: 150)
        self.assertDistance(setDist: 310, testDist: 300)
    }
    
    private func assertDistance(setDist: CGFloat, testDist: CGFloat) {
        let p1 = path!.positionForDistance(setDist)
        let dist = path!.distanceForPosition(p1)
        XCTAssertTrue( dist == testDist)
    }
    
    func testMoveForwardInSector() {
        path = WebPath()
        path!.addPoint(CGPoint(x: 0,   y: 0))
        path!.addPoint(CGPoint(x: 100, y: 0))
        
        self.assertMove(start:  0, moveDist: 10, testDist: 10)
        self.assertMove(start: 10, moveDist: 10, testDist: 20)
        self.assertMove(start:  0, moveDist: 110, testDist: 100)
        self.assertMove(start:  10, moveDist: 100, testDist: 100)
    }
    
    func testMoveForwardInMultipleSector() {
        path = WebPath()
        path!.addPoint(CGPoint(x: 0,   y: 0))
        path!.addPoint(CGPoint(x: 100, y: 0))
        path!.addPoint(CGPoint(x: 200, y: 0))
        path!.addPoint(CGPoint(x: 300, y: 0))
        
        self.assertMove(start:  0, moveDist: 210, testDist: 210)
        self.assertMove(start:  0, moveDist: 600, testDist: 300)
        self.assertMove(start: 50, moveDist: 200, testDist: 250)
        self.assertMove(start: 50, moveDist: 300, testDist: 300)
    }
    
    func testMoveBackwardInSector() {
        path = WebPath()
        path!.addPoint(CGPoint(x: 0,   y: 0))
        path!.addPoint(CGPoint(x: 100, y: 0))
        
        self.assertMove(start:  0,  moveDist: -10, testDist: 0)
        self.assertMove(start: 20,  moveDist: -30, testDist: 0)
        self.assertMove(start: 20,  moveDist: -10, testDist: 10)
        self.assertMove(start: 110, moveDist: -20, testDist: 80)
    }
    
    func testMoveBackwardInMultipleSector() {
        path = WebPath()
        path!.addPoint(CGPoint(x: 0,   y: 0))
        path!.addPoint(CGPoint(x: 100, y: 0))
        path!.addPoint(CGPoint(x: 200, y: 0))
        path!.addPoint(CGPoint(x: 300, y: 0))
        
        self.assertMove(start: 250, moveDist: -200, testDist: 50)
        self.assertMove(start: 150, moveDist: -600, testDist: 0)
    }

    private func assertMove(start: CGFloat, moveDist: CGFloat, testDist: CGFloat) {
        let p1 = path!.positionForDistance(start)
        let newPos = path!.movePosition(p1, moveDist: moveDist)
        let dist = path!.distanceForPosition(newPos)
        XCTAssertTrue( dist == testDist)
    }
    
}
