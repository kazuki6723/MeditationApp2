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
    
    private var bgmAudioPlayer: AVAudioPlayer!
    private var alarmAudioPlayer: AVAudioPlayer!
    private var timer = Timer()
    private var minute = 0
    private var second = 0
    
    var originalM: OriginalMeditation!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgmAudioPlayer?.delegate = self
        alarmAudioPlayer?.delegate = self
        
        navigationController?.presentationController?.delegate = self
        self.presentationController?.delegate = self
                
        if Int(originalM.minutes) == 0, Int(originalM.seconds) == 0 {
            let alert = UIAlertController(title: "正確な時間が設定されていません", message: "設定された時間が0秒になっています", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        setUpAudioPlayer()
        setUpView()
        bgmAudioPlayer.prepareToPlay()
        alarmAudioPlayer.prepareToPlay()
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        timer.invalidate()
        bgmAudioPlayer.stop()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setUpAudioPlayer() {
        // 再生する audio ファイルのパスを取得
        let audioPath = Bundle.main.path(forResource: originalM.bgm, ofType:"mp3")!
        let audioUrl = URL(fileURLWithPath: audioPath)
        
        // auido を再生するプレイヤーを作成する
        do {
            bgmAudioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
        } catch let error as NSError {
            print("Error \(error.localizedDescription)")
            bgmAudioPlayer = nil
        }
        
        // 再生する audio ファイルのパスを取得
        let audioPath2 = Bundle.main.path(forResource: originalM.alarm, ofType:"mp3")!
        let audioUrl2 = URL(fileURLWithPath: audioPath2)
        
        // auido を再生するプレイヤーを作成する
        do {
            alarmAudioPlayer = try AVAudioPlayer(contentsOf: audioUrl2)
        } catch let error as NSError {
            print("Error \(error.localizedDescription)")
            alarmAudioPlayer = nil
        }
    }
    
    private func setUpView() {
        titleLabel.text = originalM.title
        timeLabel.font = .monospacedDigitSystemFont(ofSize: 80, weight: .regular)
        timeLabel.text = "\(originalM.minutes):\(originalM.seconds)"
        minute = Int(originalM.minutes) ?? 0
        second = Int(originalM.seconds) ?? 0
    }
    
    @IBAction func audioPlayerAction(_ sender: Any) {
        if bgmAudioPlayer.isPlaying {
            
            timer.invalidate()
            bgmAudioPlayer.pause()
            audioActionButton.image = UIImage(systemName: "play.fill")
            return
        } else if alarmAudioPlayer.isPlaying {
            timer.invalidate()
            alarmAudioPlayer.pause()
            audioActionButton.image = UIImage(systemName: "play.fill")
        } else {

            if timeLabel.text == "0:00" {
                timeLabel.text = "\(originalM.minutes):\(originalM.seconds)"
                minute = Int(originalM.minutes) ?? 0
                second = Int(originalM.seconds) ?? 0
            }
            timerSetUp()
            bgmAudioPlayer.play()
            bgmAudioPlayer.numberOfLoops = -1
            audioActionButton.image = UIImage(systemName: "pause.fill")
        }
    }
    
    private func timerSetUp() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    //画面への残り時間の表示
    @objc func timerAction() {
        
        if second == 0 {
            minute -= 1
            second = 59
        } else {
            second -= 1
        }
        let minuteString: String = String(minute)
        var secondString: String = String(second)
        if second < 10 {
            secondString = String(format: "%02d", second)
        }
        timeLabel.text = "\(minuteString):\(secondString)"
        
        if minute == 0, second == 0 {

            //audioPlayerをストップ
            bgmAudioPlayer.stop()
            
            alarmAudioPlayer.play()
            //タイマーを終了させる
            timer.invalidate()
        }
    }
    
    @IBAction func volumeSlider(_ sender: Any) {
        
        if bgmAudioPlayer.isPlaying {
            
            bgmAudioPlayer.volume = volumeSlider.value
        } else if alarmAudioPlayer.isPlaying {
            
            alarmAudioPlayer.volume = volumeSlider.value
        }
    }
}
