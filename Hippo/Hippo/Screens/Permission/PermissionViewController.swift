//
//  PermissionViewController.swift
//  Hippo
//
//  Created by Huy Le on 21/7/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Speech

final class PermissionViewController: UIViewController {

    @IBOutlet private weak var placeholderImageView: UIImageView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var allowButton: UIButton!

    var isAuthenticatedForDevices: Bool {
        return bothAuthenticationStatus(were: .authorized)
    }

    var videoAuth: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
    }

    var audioAuth: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
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
        Analytics.track(event: .openPermissionScreen)
        super.viewDidAppear(animated)
        openCameraIfNeeded()
    }

    @IBAction func touchAllow(_ sender: Any) {
        Analytics.track(event: .tapAllowButtonPermission)
        if ApplicationMirror.isTakingSnapshot { openCamera(); return }
        SFSpeechRecognizer.requestAuthorization { (status) in
            switch status {
            case .authorized:
                Analytics.track(event: .allowDictationPermission)
                break
            case .denied:
                Analytics.track(event: .deniedDictationPermission)
                break
            case .notDetermined: break
            case .restricted: break
            }
        }

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
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                // Then request access for audio
                if granted { Analytics.track(event: .allowCameraPermission) }
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { (granted) in
                    if granted { Analytics.track(event: .allowMicPermission) }
                    self.openCameraIfNeeded()
                })
            })
        }

    }

    func openCameraIfNeeded() {
        if ApplicationMirror.isTakingSnapshot { return }
        guard isAuthenticatedForDevices || !ApplicationMirror.isDevice else { return }
        DispatchQueue.main.async { self.openCamera() }
    }

    func openCamera() {
        performSegue(withIdentifier: "openCamera", sender: nil)
    }
}
