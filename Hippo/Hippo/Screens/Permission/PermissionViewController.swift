//
//  PermissionViewController.swift
//  Hippo
//
//  Created by Huy Le on 21/7/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import UIKit
import AVKit

final class PermissionViewController: UIViewController {
    
    @IBOutlet private weak var placeholderImageView: UIImageView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var allowButton: UIButton!
    
    var isAuthenticatedForDevices: Bool {
        return bothAuthenticationStatus(were: .authorized)
    }
    
    var videoAuth: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    var audioAuth: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .audio)
    }
    
    var authentications: (AVAuthorizationStatus, AVAuthorizationStatus) {
        return (videoAuth, audioAuth)
    }
    
    func bothAuthenticationStatus(either status: AVAuthorizationStatus) -> Bool {
        switch authentications {
        case (_, status):
            return true
        case (status, _):
            return true
        default:
            return false
        }
    }
    
    func bothAuthenticationStatus(were status: AVAuthorizationStatus) -> Bool {
        switch authentications {
        case (status, status):
            return true
        default:
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoLabel.textColor = Style.PermissionScreen.InfoLabel.textColor
        allowButton.setTitleColor(Style.PermissionScreen.AllowButton.textColor, for: .normal)        
        allowButton.backgroundColor = Style.PermissionScreen.AllowButton.backgroundColor
        allowButton.layer.cornerRadius = 10
        allowButton.accessibilityIdentifier = "allow.permission.button"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openCameraIfNeeded()
    }
    
    @IBAction func touchAllow(_ sender: Any) {
        if ApplicationMirror.isTakingSnapshot { openCamera(); return }
        if bothAuthenticationStatus(either: .restricted) {
            // Show alertView
            let alert = UIAlertController(title: "Retricted", message: "Camera or Microphone access is restricted by device settings", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in }))
            alert.show(self, sender: nil)
            return
        }
        
        if bothAuthenticationStatus(either: .denied) {
            guard
                let settingsUrl = URL(string: UIApplicationOpenSettingsURLString),
                UIApplication.shared.canOpenURL(settingsUrl) else { return }
            UIApplication.shared.open(settingsUrl)
            return
        }
        
        if bothAuthenticationStatus(were: .notDetermined) {
            // Request access for video
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                // Then request access for audio
                AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (granted) in
                    self.openCameraIfNeeded()
                })
            })
        }
        
    }
    
    func openCameraIfNeeded() {
        if ApplicationMirror.isTakingSnapshot { return }
        guard isAuthenticatedForDevices || !ApplicationMirror.isDevice else { return }
        openCamera()
    }
    
    func openCamera() {
        performSegue(withIdentifier: "openCamera", sender: nil)
    }
}
