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
    
    struct PermissionScreen {
        struct AllowButton {
            static let textColor = UIColor.white
            static let backgroundColor = UIColor(red: 0.20, green: 0.27, blue: 0.39, alpha: 1.00)
        }
        
        struct InfoLabel {
            static let textColor = Text.contentColor
        }
    }
    
    struct IntroductionScreen {
        struct NextButton {
            static let textColor = UIColor.white
            static let backgroundColor = UIColor(red: 0.20, green: 0.27, blue: 0.39, alpha: 1.00)
        }
    }
    
    struct DictationView {
        static let textColor = Text.contentColor
        static let insets = UIEdgeInsetsMake(5, 5, -5, -5)
        static let alpha = 0.85 as CGFloat
    }
    
    struct Text {
        static let contentColor = UIColor(red: 0.04, green: 0.12, blue: 0.26, alpha: 1.00)
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
