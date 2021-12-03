//
//  OpeningViewController.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/13.
//

import UIKit
import Lottie

class OpeningViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var onboardArray = ["0","1","2","3","4"]
    private var onboardStringArray = ["このアプリでは手軽に瞑想に取り組むことができます","ストレスを軽減することができます","集中力や記憶能力の向上にも効果的です","成功者の多くが習慣にしています。","今日から成功に向かって歩み出そう！！"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGradient()
        setUpScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationBarを隠す
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //背景のグラデーションを設定
    func setUpGradient() {
        //グラデーションの開始色
        let topColor = UIColor(red:0.07, green:0.87, blue:0.26, alpha:0.7)
        //グラデーションの終了色
        let bottomColor = UIColor(red:0.54, green:0.74, blue:0.74, alpha:0.7)
        //グラデーションの色を配列で管理
        let gradientColors: [CGColor] = [topColor.cgColor, bottomColor.cgColor]
        //グラデーションレイヤーを作成
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        //グラデーションの色をレイヤーに割り当てる
        gradientLayer.colors = gradientColors
        //グラデーションレイヤーをスクリーンサイズにする
        gradientLayer.frame = self.view.bounds
        //グラデーションレイヤーをビューの一番下に配置
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}

extension OpeningViewController: UIScrollViewDelegate {
    
    func setUpScrollView() {
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: view.frame.size.width * 5, height: view.frame.size.height)
        
        for i in 0...4 {
            let onboardLabel = UILabel(frame: CGRect(x: CGFloat(i) * view.frame.size.width, y: view.frame.size.height / 3, width: view.frame.size.width, height: scrollView.frame.size.height))
            onboardLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
            onboardLabel.textAlignment = .center
            onboardLabel.text = onboardStringArray[i]
            scrollView.addSubview(onboardLabel)
            
            let animationView = AnimationView()
            let animation = Animation.named(onboardArray[i])
            animationView.frame = CGRect(x: CGFloat(i) * view.frame.size.width, y: 0, width: view.frame.size.width, height: view.frame.size.height)
            animationView.animation = animation
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.play()
            scrollView.addSubview(animationView)
        }
    }
    
}
