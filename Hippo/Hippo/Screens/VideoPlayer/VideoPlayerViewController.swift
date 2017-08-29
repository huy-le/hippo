//
//  VideoPlayerViewController.swift
//  Hippo
//
//  Created by Huy Le on 17/7/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

final class VideoPlayerViewController: AVPlayerViewController {
    
    var videoURL: URL!
    var bestTranscription: String?
    
    private lazy var dictationTextView: UITextView = self.lazy_dictationTextView()
    private let closeGesture = UISwipeGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeGesture.direction = .down
        closeGesture.addTarget(self, action: #selector(close))
        view.addGestureRecognizer(closeGesture)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player?.pause()
    }
    
    @objc private func close() {
        Analytics.track(event: .swipeToDismissReviewScreen)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ApplicationMirror.isTakingSnapshot { return }
        player = AVPlayer(url: videoURL)
        dictationTextView.text = bestTranscription
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Analytics.track(event: .openReviewScreen)
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.player?.play()
        }
    }
    
    private func lazy_dictationTextView() -> UITextView {
        let textView = UITextView()
        view.addSubview(textView)
        textView.layer.cornerRadius = 8
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.textColor = Style.DictationView.textColor
        textView.contentInset = Style.DictationView.insets
        textView.alpha = Style.DictationView.alpha
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        textView.alwaysBounceVertical = true
        return textView
    }
}
