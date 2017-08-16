//
//  WebPathFitTestCase.swift
//  SpiderSaidToTheFly
//
//  Created by Frank on 16/08/2017.
//  Copyright © 2017 FvH. All rights reserved.
//

import XCTest
@testable import SpiderSaidToTheFly

class WebPathFitTestCase: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleFit() {
        let path = WebPath()
        path.addPoint(CGPoint(x: 0,  y:  0))
        path.addPoint(CGPoint(x: 10, y: 10))
        path.fitIn(xmin: 0, ymin: 0, xmax: 100, ymax: 100)
        
        XCTAssertTrue(path.first().x == 0)
        XCTAssertTrue(path.first().y == 0)
        XCTAssertTrue(path.last().x == 100)
        XCTAssertTrue(path.last().y == 100)
    }
    
    func testSimpleFlip() {
        let path = WebPath()
        path.addPoint(CGPoint(x: 0,  y:  0))
        path.addPoint(CGPoint(x: 10, y: 10))
        path.flipHorizontal()
        
        XCTAssertTrue(path.first().x == 0)
        XCTAssertTrue(path.first().y == 10)
        XCTAssertTrue(path.last().x == 10)
        XCTAssertTrue(path.last().y == 0)
    }
    
    func testSimpleTranslateAndScale() {
        let path = WebPath()
        path.addPoint(CGPoint(x: 0,  y:  0))
        path.addPoint(CGPoint(x: 10, y: 10))
        path.fitIn(xmin: 10, ymin: 10, xmax: 100, ymax: 100)
        
        XCTAssertTrue(path.first().x == 10)
        XCTAssertTrue(path.first().y == 10)
        XCTAssertTrue(path.last().x == 100)
        XCTAssertTrue(path.last().y == 100)
    }
    
    func testTranslateAndScale() {
        let path = WebPath()
        path.addPoint(CGPoint(x: 0,  y:  0))
        path.addPoint(CGPoint(x: 5, y:  5))
        path.addPoint(CGPoint(x: 10, y: 10))
        path.fitIn(xmin: 10, ymin: 10, xmax: 100, ymax: 100)
        
        XCTAssertTrue(path.points[0].x == 10)
        XCTAssertTrue(path.points[0].y == 10)
        XCTAssertTrue(path.points[1].x == 55)
        XCTAssertTrue(path.points[1].y == 55)
        XCTAssertTrue(path.points[2].x == 100)
        XCTAssertTrue(path.points[2].y == 100)
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
