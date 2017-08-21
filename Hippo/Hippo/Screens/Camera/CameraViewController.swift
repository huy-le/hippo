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
import Speech

extension UserDefaults {
    var selectedLocale: String? {
        set {
            set(newValue, forKey: "com.hippo.selectedLocale")
        }
        get {
            return value(forKey: "com.hippo.selectedLocale") as? String
        }
    }
}

final class CameraViewController: UIViewController {
    
    let supportedLanguages = ["🇻🇳 Vietnamese":"vi",
                              "🇦🇺 English":"en_AU",
                              "🇺🇸 English":"en_US",
                              "🇬🇧 English":"en_GB",
                              "🇪🇸 Spanish":"es",
                              "🇵🇹 Portuguese":"pt_PT",
                              "🇫🇷 French":"fr_FR",
                              "🇷🇺 Russian":"ru",
                              "🇯🇵 Japannese":"ja",
                              "🇰🇷 Korean":"ko",
                              "🇩🇪 German":"de_DE",
                              "🇳🇴 Norwegian":"no_NO",
                              "🇨🇳 Mandarin":"zh_HK",
                              "🇹🇼 Cantonese":"zh-Hans_HK"]
    
    private let cameraEngine = CameraEngine()
    private var videoURL: URL? = CameraEngineFileManager.temporaryPath("video.mp4")
    private var isUsingFrontCamera: Bool = false
    lazy private var durationTimeFormatter: DateComponentsFormatter = self.lazy_durationTimeFormatter()
    lazy private var reviewViewController: VideoPlayerViewController =
        VideoPlayerViewController()
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest = {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        return request
    }()
    
    private var bestTranscription: String? {
        didSet {
            dictationTextView.text = bestTranscription
            dictationTextView.scrollRectToVisible(CGRect(x: 0, y: dictationTextView.contentSize.height - 6, width:1, height: 1), animated: true)
        }
    }
    private var selectedLocale = Locale.current {
        didSet {
            guard let flag = UserDefaults.standard.selectedLocale else { return }
            localeButton.setTitle(flag, for: .normal)
        }
    }
    
    @IBOutlet private weak var durationBackgroundView: UIView!
    @IBOutlet private weak var durationBackgroundImageView: UIImageView!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet weak var recordButton: RecordButton!
    @IBOutlet weak var localeButton: UIButton!
    @IBOutlet private weak var dictationTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordButton.accessibilityIdentifier = "record.button"
        durationBackgroundImageView.image = Style.MyAsset.duration_background.image
        durationBackgroundView.backgroundColor = .clear
        durationBackgroundView.transform = CGAffineTransform(scaleX: 0, y: 0)
        guard ApplicationMirror.isDevice else { return }
        self.cameraEngine.startSession()
        self.cameraEngine.cameraFocus = .continuousAutoFocus
        self.cameraEngine.rotationCamera = true
        
        self.cameraEngine.blockCompletionAudioBuffer = { buffer in
            self.recognizeSpeech(sampleBuffer: buffer)
        }
        dictationTextView.textColor = Style.DictationView.textColor
        dictationTextView.contentInset = Style.DictationView.insets
        dictationTextView.alpha = Style.DictationView.alpha
        
        if
            let key = UserDefaults.standard.selectedLocale,
            let identifier = supportedLanguages[key] {
                selectedLocale = Locale(identifier: identifier)
        }
        
        localeButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        localeButton.setTitleColor(.white, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addScreenshotBackgroundIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard ApplicationMirror.isDevice else { return }
        guard let layer = self.cameraEngine.previewLayer else { return }
        layer.frame = self.view.bounds
        self.view.layer.insertSublayer(layer, at: 0)
        self.view.layer.masksToBounds = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func touchButton(_ sender: RecordButton) {
        UISelectionFeedbackGenerator().selectionChanged()
        sender.isSelected = !sender.isSelected
        capture()
        if ApplicationMirror.isTakingSnapshot {
            if sender.isSelected { showDuration() }
            else { openReviewScreen() }
        }
    }
    
    @IBAction func tapOnLocaleButton(_ sender: Any) {
        let vc = UIAlertController(title: "Dictation language", message: "Choose language you want to practice speaking", preferredStyle: .actionSheet)
        vc.popoverPresentationController?.sourceRect = localeButton.frame
        vc.popoverPresentationController?.sourceView = localeButton
        
        for lang in supportedLanguages {
            vc.addAction(UIAlertAction(title: lang.key, style: .default, handler: { (_) in
                UserDefaults.standard.selectedLocale = lang.key
                UserDefaults.standard.synchronize()
                self.selectedLocale = Locale(identifier: lang.value)
            }))
        }
        vc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
    }
    
    func capture() {
        
        guard ApplicationMirror.isDevice else { return }
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
                self.openReviewScreen()
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
        self.foo()
        showDuration()
    }
  
    func done() {
        print("Stop recording")
        recognitionRequest.endAudio()
        cameraEngine.stopRecordingVideo()
        hideDuration()
    }
    
    private func openReviewScreen() {
        reviewViewController.videoURL = videoURL
        reviewViewController.bestTranscription = bestTranscription
        present(reviewViewController, animated: true, completion: nil)
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
    
    private func addScreenshotBackgroundIfNeeded() {
        guard ApplicationMirror.isTakingSnapshot else { return }
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ScreenshotBackground"))
        imageView.frame = view.bounds
        imageView.contentMode = .scaleAspectFill
        view.insertSubview(imageView, at: 0)
    }
    
    private func lazy_durationTimeFormatter() -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    // MARK: - Dictation
    
    func foo() {
        let locale = selectedLocale
        guard let recognizer = SFSpeechRecognizer(locale: locale) else {
            // A recognizer is not supported for the current locale
            return
        }
        if !recognizer.isAvailable {
            // The recognizer is not available right now
            return
        }
        recognizer.recognitionTask(with: recognitionRequest) { (result, error) in
            guard let result = result else {
                print("🆘 \(error.debugDescription)")
                return
            }
            self.bestTranscription = result.bestTranscription.formattedString
        }
    }
    
    func recognizeSpeech(sampleBuffer: CMSampleBuffer) {
        recognitionRequest.appendAudioSampleBuffer(sampleBuffer)
    }
}
