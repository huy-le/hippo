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
    static let analytic: Amplitude! = Amplitude.instance()
    static func setup() {
        analytic.initializeApiKey("0e21ac2ebbc4bfac58fdea2e8407f027")
    }
    
    static func track(event: Event, property: [String: Any] = [:]) {
        analytic.logEvent(event.rawValue, withEventProperties: property)
    }
    
    enum Event: String {
        case openIntroductionScreen
        case openPermissionScreen
        case tapAllowButtonPermission
        case allowDictationPermission
        case deniedDictationPermission
        case allowMicPermission
        case allowCameraPermission
        case openCameraScreen
        case openReviewScreen
        case swipeToDismissReviewScreen
        case tapRecordButton
        case tapChangeLanguageButton
        case failGetDictation
        case completeRecord
        case tapLoveButton
        case shareApp
        case rateApp
    }
}
