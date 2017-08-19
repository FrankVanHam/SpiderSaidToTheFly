//
//  WebPathLoaderTestCase.swift
//  SpiderSaidToTheFly
//
//  Created by Frank on 17/08/2017.
//  Copyright © 2017 FvH. All rights reserved.
//

import XCTest
@testable import SpiderSaidToTheFly

class WebPathLoaderTestCase: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEmptyLoad() {
        let loader = WebPathLoader()
        let path = loader.pathFromString("")
        
        XCTAssertTrue(path.isEmpty())
    }
    
    func testSmallLoad() {
        let loader = WebPathLoader()
        let path = loader.pathFromString(";\"/><path d=\"M0,100l100,-100l10,10\" stroke=\"bla")
        XCTAssertTrue(path.count() == 3)
        XCTAssertTrue(path.points[2].x == 110 )
        XCTAssertTrue(path.points[2].y == 10 )
    }
}
