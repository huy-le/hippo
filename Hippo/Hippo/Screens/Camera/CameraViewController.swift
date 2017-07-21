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
import CoreGraphics

final class CameraViewController: UIViewController {
    
    private let cameraEngine = CameraEngine()
    private var videoURL: URL? = CameraEngineFileManager.temporaryPath("video.mp4")
    private var isUsingFrontCamera: Bool = false
    lazy private var durationTimeFormatter: DateComponentsFormatter = self.lazy_durationTimeFormatter()
    lazy private var reviewViewController: VideoPlayerViewController = VideoPlayerViewController()
    
    @IBOutlet private weak var durationBackgroundView: UIView!
    @IBOutlet private weak var durationBackgroundImageView: UIImageView!
    @IBOutlet private weak var durationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        durationBackgroundImageView.image = Style.MyAsset.duration_background.image
        durationBackgroundView.backgroundColor = .clear
        durationBackgroundView.transform = CGAffineTransform(scaleX: 0, y: 0)
        guard Platform.isDevice else { return }
        self.cameraEngine.startSession()
        self.cameraEngine.cameraFocus = .continuousAutoFocus
        self.cameraEngine.rotationCamera = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard Platform.isDevice else { return }
        guard !isUsingFrontCamera else { return }
        self.cameraEngine.changeCurrentDevice(.front)
        isUsingFrontCamera = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard Platform.isDevice else { return }
        guard let layer = self.cameraEngine.previewLayer else { return }
        layer.frame = self.view.bounds
        self.view.layer.insertSublayer(layer, at: 0)
        self.view.layer.masksToBounds = true
    }
    
    @IBAction func touchButton(_ sender: RecordButton) {
        sender.isSelected = !sender.isSelected
        capture()
    }
    
    func capture() {
        guard Platform.isDevice else { return }
        guard !cameraEngine.isRecording else {
            done()
            return
        }
        guard let url = videoURL else {
            assertionFailure("url is nil")
            return
        }
        _ = try? FileManager().removeItem(at: url)
        cameraEngine.startRecordingVideo(url) { (url, error) -> (Void) in
            if let error = error {
                assertionFailure(error.description)
            }
            DispatchQueue.main.async {
                self.reviewViewController.videoURL = url
                self.present(self.reviewViewController, animated: false, completion: nil)
            }
        }
        cameraEngine.blockCompletionProgress = { duration in
            let seconds = round(duration)
            guard let durationDescription = self.durationTimeFormatter.string(from: seconds) else { return }
            DispatchQueue.main.async {
                self.durationLabel.text = "\(durationDescription)"
            }
        }
        print("Start recording")
        showDuration()
    }
    
   
    func done() {
        print("Stop recording")
        cameraEngine.stopRecordingVideo()
        hideDuration()
    }
    
    private func showDuration() {
        UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.7) {
            self.durationBackgroundView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }.startAnimation()
    }
    
    private func hideDuration() {
        UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.7) {
            self.durationBackgroundView.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
        }.startAnimation()
    }
    
    private func lazy_durationTimeFormatter() -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
}
