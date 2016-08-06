//
//  DAGA_2016UITests.swift
//  DAGA 2016UITests
//
//  Created by Tilo Westermann on 18/02/16.
//  Copyright © 2016 Quality and Usability Lab, Telekom Innovation Laboratories, TU Berlin. All rights reserved.
//

import XCTest

class DAGA_2016UITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        XCUIDevice.sharedDevice().orientation = .FaceUp
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        
        
//        let tabBarsQuery = app.tabBars
//        tabBarsQuery.buttons.elementBoundByIndex(2).tap()
        
//        let map1Image = app.images["Map1"]
//        map1Image.doubleTap()
//        map1Image.doubleTap()
//        map1Image.swipeLeft()
//        let map2Image = app.images["Map2"]
//        map2Image.swipeRight()
//        snapshot("04Map")
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        sleep(2)
        
        
        var tablesQuery = app.tables
        snapshot("01Agenda")
        tablesQuery.cells.elementBoundByIndex(0).tap()
        
        tablesQuery = app.tables
        snapshot("02Session")
        tablesQuery.cells.elementBoundByIndex(0).tap()
        
        snapshot("03Paper")
    }
    
}
