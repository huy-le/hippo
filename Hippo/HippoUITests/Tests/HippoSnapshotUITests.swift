//
//  HippoUITests.swift
//  HippoUITests
//
//  Created by Huy Le on 16/7/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import XCTest

class HippoSnapshotUITests: UIBaseTests {
        
    override func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        setupSnapshot(app)
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testTakeSnapshot() {
        snapshot("IntroductionScreen")
        IntroductionScreen.nextButton.tap()
        snapshot("PermissionScreen")
        PermissionScreen.allowPermissionButton.tap()
        snapshot("CameraScreen")
        CameraScreen.recordButton.tap()
        snapshot("CameraScreen-OnRecording")
        CameraScreen.recordButton.tap()
        snapshot("VideoPlayerScreen")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
