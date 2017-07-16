//
//  CameraViewController.swift
//  Hippo
//
//  Created by Huy Le on 16/7/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import UIKit
import CameraEngine
import AVKit

final class CameraViewController: UIViewController {
    
    private let cameraEngine = CameraEngine()
    private var videoURL: URL? = CameraEngineFileManager.temporaryPath("video.mp4")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraEngine.startSession()
        cameraEngine.cameraFocus = .continuousAutoFocus
        cameraEngine.rotationCamera = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraEngine.changeCurrentDevice(.front)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let layer = self.cameraEngine.previewLayer else { return }
        
        layer.frame = self.view.bounds
        self.view.layer.insertSublayer(layer, at: 0)
        self.view.layer.masksToBounds = true
    }
    
    @IBAction func touchCapture(_ sender: UIButton) {
        guard let url = videoURL else {
            assertionFailure("url is nil")
            return
        }
        _ = try? FileManager().removeItem(at: url)
        sender.isEnabled = false
        cameraEngine.startRecordingVideo(url) { (url, error) -> (Void) in
            if let error = error {
                assertionFailure(error.description)
            }
            DispatchQueue.main.async {
                sender.isEnabled = true
                guard let url = url else { return }
                let player = AVPlayer(url: url)
                let vc = AVPlayerViewController()
                vc.player = player
                self.present(vc, animated: true) {
                    player.play()
                }
            }
        }
        print("Start recording")
    }
    
    @IBAction func touchDone(_ sender: Any) {
        print("Stop recording")
        cameraEngine.stopRecordingVideo()
    }
}
