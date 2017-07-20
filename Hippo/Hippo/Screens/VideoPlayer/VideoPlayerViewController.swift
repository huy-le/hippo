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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
