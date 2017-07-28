//
//  Helper.swift
//  HippoUITests
//
//  Created by Huy Le on 28/7/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import XCTest

enum WaitingCondition {
    case exists
    case hittable
    case labelContains(String)
    
    var predicate: NSPredicate {
        switch self {
        case .exists: return NSPredicate(format: "exists == 1")
        case .hittable: return NSPredicate(format: "hittable == 1")
        case .labelContains(let label): return NSPredicate(format: "label contains %@", label)
        }
    }
}

let app = XCUIApplication()

class UIBaseTests: XCTestCase {

    private static let isTestingLaunchArgument = "uitesting"
    // MARK: Screens
    
    lazy var permissionScreen: PermissionScreen = PermissionScreen(testcase: self)
    lazy var cameraScreen: CameraScreen = CameraScreen(testcase: self)
    lazy var videoPlayerScreen: VideoPlayerScreen = VideoPlayerScreen(testcase: self)
    
    // MARK: Life cycle
    private func launchWithArguments(_ arguments: [String]) {
        continueAfterFailure = false
        // Must reset launchArguments each time, because launchArguments survive between sessions
        app.launchArguments = [UIBaseTests.isTestingLaunchArgument] + arguments
        app.launch()
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    func launch() {
        launchWithArguments([])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.terminate()
        super.tearDown()
    }
    // MARK: Helper methods

    
    /// Change this value before compile time to enable `_run` tests
    static let shouldRunIgnoredTests = false
    
    func run(_ description: String, block: () -> Void) {
        print("\n 🤙🏻 ---- \(description) ----")
        block()
    }
    
    func _run(_ description: String, block: () -> Void) {
        if UIBaseTests.shouldRunIgnoredTests {
            _run(description, block: block)
        } else {
            print("\n ✊🏾 IGNORING! ---- \(description) ----")
        }
    }
    
}

// Help our logs be more readable
func log(f: String = #function, _ printables: Any...) {
    print("\n 🤳🏾", f, printables)
}

extension XCTestCase {
    
    /// Direction for scroll action
    ///
    /// - up: swipe from bottom to top
    /// - down: swipe from top to bottom
    enum SwipeDirection {
        case up
        case down
        case left
        case right
    }
    
    @discardableResult
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 10, waitCondition: WaitingCondition = .exists, file: StaticString = #file, line: UInt = #line, handler: XCWaitCompletionHandler? = nil) -> XCUIElement {
        log("\(waitCondition)", element.description)
        let expectation = self.expectation(for: waitCondition.predicate, evaluatedWith: element, handler: nil)
        
        switch XCTWaiter.wait(for: [expectation], timeout: timeout) {
        case .completed:
            break
        case .timedOut:
            print("⌛️ \(#function) `app` dump:")
            dump(app)
            XCTFail("\(element) not \(waitCondition) after \(timeout) seconds", file: file, line: line)
        case .incorrectOrder,
             .invertedFulfillment,
             .interrupted:
            print("⌛️ \(#function) `app` dump:")
            dump(app)
            XCTFail("\(description)", file: file, line: line)
        }
        
        return element
    }
    
    @discardableResult
    private func waitAndPerformAction(_ element: XCUIElement, timeout: TimeInterval, file: StaticString = #file, line: UInt = #line, action: (XCUIElement) -> Void) -> XCUIElement {
        waitForElement(element, timeout: timeout, waitCondition: .exists, file: file, line: line)
        waitForElement(element, timeout: timeout, waitCondition: .hittable, file: file, line: line)
        action(element)
        return element
    }
    
    @discardableResult
    func waitAndTap(_ element: XCUIElement, timeout: TimeInterval = 10, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        log(element.description)
        return waitAndPerformAction(element, timeout: timeout, file: file, line: line) { (element) in
            element.tap()
        }
    }
    
    @discardableResult
    func waitAndLongTap(_ element: XCUIElement, timeout: TimeInterval = 10, duration: TimeInterval = 1.0, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        log(element.description)
        return waitAndPerformAction(element, timeout: timeout, file: file, line: line) { (element) in
            element.press(forDuration: duration)
        }
    }
    
    @discardableResult
    func waitAndSwipeLeft(_ element: XCUIElement, timeout: TimeInterval = 10, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        log(element.description)
        return waitAndPerformAction(element, timeout: timeout, file: file, line: line) { (element) in
            element.swipeLeft()
        }
    }
    
    @discardableResult
    func waitAndSwipeRight(_ element: XCUIElement, timeout: TimeInterval = 10, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        log(element.description)
        return waitAndPerformAction(element, timeout: timeout, file: file, line: line) { (element) in
            element.swipeRight()
        }
    }
    
    @discardableResult
    func waitAndType(_ element: XCUIElement, timeout: TimeInterval = 10, text: String, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        log(element.description)
        return waitAndPerformAction(element, timeout: timeout, file: file, line: line) { (element) in
            element.typeText(text)
        }
    }
    
    @discardableResult
    func waitForLabel(_ element: XCUIElement, timeout: TimeInterval = 10, toContain labelText: String, file: StaticString = #file, line: UInt = #line, handler: XCWaitCompletionHandler? = nil) -> XCUIElement {
        log(element.description, labelText)
        waitForElement(element, timeout: timeout, file: file, line: line, handler: handler)
        waitForElement(element, timeout: timeout, waitCondition: .labelContains(labelText), file: file, line: line, handler: handler)
        return element
    }
    
    @discardableResult
    func scrollUntilTap(_ element: XCUIElement, within withinElement: XCUIElement, swipeDirection: SwipeDirection = .up, timeout: TimeInterval = 10, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        log(element.description)
        
        scroll(within: withinElement,
               swipeDirection: swipeDirection,
               timeout: timeout,
               file: file,
               line: line,
               until: { element.exists && element.isHittable },
               andThen: { waitAndTap(element) })
        
        return element
    }
    
    @discardableResult
    func scrollUntilLongTap(_ element: XCUIElement, within withinElement: XCUIElement, swipeDirection: SwipeDirection = .up, timeout: TimeInterval = 10, duration: TimeInterval = 1.0, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        log(element.description)
        scroll(within: withinElement,
               swipeDirection: swipeDirection,
               timeout: timeout,
               file: file,
               line: line,
               until: { element.exists && element.isHittable },
               andThen: { waitAndLongTap(element, duration: duration) })
        
        return element
    }
    
    func scroll(
        within withinElement: XCUIElement,
        swipeDirection: SwipeDirection = .up,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line,
        until predicate: @escaping () -> Bool,
        andThen action: () -> Void = { }) {
        
        waitFor("scroll in \(withinElement)", timeout: timeout, file: file, line: line) { expectation in
            DispatchQueue.main.async {
                while !predicate() {
                    switch swipeDirection {
                    case .up: withinElement.swipeUp()
                    case .down: withinElement.swipeDown()
                    case .left: withinElement.swipeLeft()
                    case .right: withinElement.swipeRight()
                    }
                }
                expectation.fulfill()
            }
        }
        action()
    }
    
    @discardableResult
    func scrollUntilExists(_ element: XCUIElement, within withinElement: XCUIElement, swipeDirection: SwipeDirection = .up, timeout: TimeInterval = 10, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        
        scroll(within: withinElement,
               swipeDirection: swipeDirection,
               timeout: timeout,
               file: file,
               line: line,
               until: { element.exists })
        
        return element
    }
    
    /**
     A utility func that helps handle typing text.
     What this function does is:
     - Wait for the element hittable with timeout 10.0 seconds.
     - Then tap on element and clear the old text value
     - Typing the given text
     - Parameter text: the given text to enter into the field
     */
    func enterText(_ text: String, inElement element: XCUIElement, timeout: TimeInterval = 5.0, file: StaticString = #file, line: UInt = #line) {
        self.waitForElement(element, timeout: timeout, waitCondition: .hittable, file: file, line: line)
        
        guard let stringValue = element.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value", file: file, line: line)
            return
        }
        //Focus to textfield
        element.tap()
        element.tap()
        
        //Clean old text
        var deleteString: String = ""
        for _ in stringValue.characters {
            deleteString += "\u{8}"
        }
        element.typeText(deleteString)
        
        //Type new text
        element.typeText(text)
    }
    
    func waitFor(_ description: String, timeout: TimeInterval = 10, file: StaticString = #file, line: UInt = #line, callback: (XCTestExpectation) -> Void) {
        log(description)
        let expectation = self.expectation(description: description)
        callback(expectation)
        
        switch XCTWaiter.wait(for: [expectation], timeout: timeout) {
        case .completed:
            break
        case .timedOut:
            XCTFail("\(description) <Timed out after \(timeout) seconds>", file: file, line: line)
        case .incorrectOrder,
             .invertedFulfillment,
             .interrupted:
            XCTFail("\(description)", file: file, line: line)
        }
    }
    
}
