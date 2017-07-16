//
//  CameraViewController.swift
//  Hippo
//
//  Created by Huy Le on 16/7/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import UIKit
import CameraEngine

final class CameraViewController: UIViewController {
    
    private let cameraEngine = CameraEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraEngine.startSession()
        cameraEngine.cameraFocus = .continuousAutoFocus
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let layer = self.cameraEngine.previewLayer else { return }
        
        layer.frame = self.view.bounds
        self.view.layer.insertSublayer(layer, at: 0)
        self.view.layer.masksToBounds = true
    }
}
