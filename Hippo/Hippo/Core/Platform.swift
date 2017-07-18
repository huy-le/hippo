//
//  Platform.swift
//  Hippo
//
//  Created by Huy Le on 19/7/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import Foundation

final class Platform {
    static var isDevice: Bool {
        return TARGET_OS_SIMULATOR == 0
    }
}
