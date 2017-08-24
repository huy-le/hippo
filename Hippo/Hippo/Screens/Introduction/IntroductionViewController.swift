//
//  IntroductionViewController.swift
//  Hippo
//
//  Created by Huy Le on 17/8/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import UIKit

final class IntroductionViewController: UIViewController {
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var lb1: UILabel!
    @IBOutlet private var lb2: UILabel!
    @IBOutlet private var lb3: UILabel!
    @IBOutlet private var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLabel.textColor = Style.Text.contentColor
        lb1.textColor = Style.Text.contentColor
        lb2.textColor = Style.Text.contentColor
        lb3.textColor = Style.Text.contentColor
        
        nextButton.setTitleColor(Style.IntroductionScreen.NextButton.textColor, for: .normal)
        nextButton.backgroundColor = Style.IntroductionScreen.NextButton.backgroundColor
        nextButton.layer.cornerRadius = 10
        nextButton.accessibilityIdentifier = "next.introduction.button"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Analytics.track(event: .openIntroductionScreen)
        super.viewDidAppear(animated)
        openPermissionScreenIfNeeded()
    }
    
    private func openPermissionScreenIfNeeded() {
        guard UserDefaults.standard.bool(forKey: "com.hippo.didPassIntro") != true else {
            performSegue(withIdentifier: "showPermission", sender: nil)
            return
        }
        UserDefaults.standard.set(true, forKey: "com.hippo.didPassIntro")
    }
}
