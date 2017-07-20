//
//  NSKeyValueObservation+Disposable.swift
//  Hippo
//
//  Created by Huy Le on 20/7/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import Foundation

extension NSKeyValueObservation {
    func dispose(by disposedBag: inout [NSKeyValueObservation]) {
        disposedBag.append(self)
    }
}
