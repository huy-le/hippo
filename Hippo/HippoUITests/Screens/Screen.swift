//
//  Screen.swift
//  HippoUITests
//
//  Created by Huy Le on 28/7/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import XCTest

class Screen: NSObject {
    
    weak var testcase: UIBaseTests!
    
    init(testcase: UIBaseTests) {
        self.testcase = testcase
    }
}
