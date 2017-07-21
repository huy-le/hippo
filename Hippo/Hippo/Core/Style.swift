//
//  Style.swift
//  Hippo
//
//  Created by Huy Le on 20/7/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import UIKit

struct Style {
    struct RecordButton {
        static let normalColor = UIColor.white
        static let selectedColor = UIColor.red
    }
}

protocol UIImageConvertable: RawRepresentable {
    var image: UIImage { get }
}

extension UIImageConvertable where Self.RawValue == String {
    var image: UIImage {
        return UIImage(named: rawValue)!
    }
}
