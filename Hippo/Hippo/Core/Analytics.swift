//
//  Analytics.swift
//  Hippo
//
//  Created by Huy Le on 22/8/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import Foundation
import Amplitude

struct Analytics {
    static func setup() {
        Amplitude().initializeApiKey("0e21ac2ebbc4bfac58fdea2e8407f027")
    }
}
