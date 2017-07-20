//
//  VideoPlayerViewController.swift
//  Hippo
//
//  Created by Huy Le on 17/7/17.
//  Copyright © 2017 Huy Le. All rights reserved.
//

import UIKit
import AVKit

final class VideoPlayerViewController: AVPlayerViewController {
    
    var videoURL: URL!
    
    private let closeGesture = UISwipeGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeGesture.direction = .down
        closeGesture.addTarget(self, action: #selector(close))
        view.addGestureRecognizer(closeGesture)
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.player = AVPlayer(url: self.videoURL)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.player?.play()
        }
    }
}
