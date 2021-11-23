//
//  IndicatorSetUp.swift
//  MeditationApp2
//
//  Created by ChibaKazuki on 8/31/21.
//

import Foundation
import UIKit

class IndicatorSetUp {
    
    func startIndicator(view: UIView) {
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        
        let grayOutView = UIView(frame: view.frame)
        grayOutView.backgroundColor = .black
        grayOutView.alpha = 0.6
        grayOutView.tag = 999
        
        grayOutView.addSubview(loadingIndicator)
        view.addSubview(grayOutView)
        view.bringSubviewToFront(grayOutView)
        
        loadingIndicator.startAnimating()
    }
    
    func dismiss(view: UIView) {
        view.subviews.first(where: { $0.tag == 999})?.removeFromSuperview()
    }
    
}
