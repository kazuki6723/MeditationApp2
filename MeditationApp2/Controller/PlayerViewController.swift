//
//  PlayerViewController.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/13.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController, AVAudioPlayerDelegate, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var audioActionButton: UIImageView!
    @IBOutlet weak var volumeSlider: UISlider!
    
    private var audioPlayer: AVAudioPlayer!
    private var timer = Timer()
    private var minute: Int?
    private var second: Int?
    
    var originalM: OriginalMeditation!

    override func viewDidLoad() {
        super.viewDidLoad()
        audioPlayer?.delegate = self
        navigationController?.presentationController?.delegate = self
        self.presentationController?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        setUpAudioPlayer()
        setUpView()
        audioPlayer.prepareToPlay()
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        timer.invalidate()
        audioPlayer.stop()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setUpAudioPlayer() {
        // 再生する audio ファイルのパスを取得
        let audioPath = Bundle.main.path(forResource: originalM.bgm, ofType:"mp3")!
        let audioUrl = URL(fileURLWithPath: audioPath)
        
        // auido を再生するプレイヤーを作成する
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
        } catch let error as NSError {
            print("Error \(error.localizedDescription)")
            audioPlayer = nil
        }
    }
    
    private func setUpView() {
        titleLabel.text = originalM.title
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 80, weight: .regular)
        timeLabel.text = "\(originalM.minutes):\(originalM.seconds)"
    }
    
    @IBAction func audioPlayerAction(_ sender: Any) {
        if audioPlayer.isPlaying {
            timer.invalidate()
            audioPlayer.pause()
            audioActionButton.image = UIImage(systemName: "play.fill")
            return
        } else {
            minute = Int(originalM.minutes)
            second = Int(originalM.seconds)
            if minute == 0, second == 0 {
                return
            }
            audioPlayer.play()
            audioPlayer.numberOfLoops = -1
            audioActionButton.image = UIImage(systemName: "pause.fill")
        }
        timerSetUp()
    }
    
    private func timerSetUp() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    //画面への残り時間の表示
    @objc func timerAction() {
        if minute == 0, second == 0 {
            //タイマーを終了させる
            timer.invalidate()
            //audioPlayerをストップ
            audioPlayer.stop()
            return
        }
        if second! == 0 {
            minute! -= 1
            second = 59
        } else {
            second! -= 1
        }
        let minuteString: String = String(minute!)
        var secondString: String = String(second!)
        if second! < 10 {
            secondString = String(format: "%02d", second!)
        }
        timeLabel.text = "\(minuteString):\(secondString)"
    }
    
    @IBAction func volumeSlider(_ sender: Any) {
        audioPlayer.volume = volumeSlider.value
    }
}
