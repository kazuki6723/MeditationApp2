//
//  CustomNavigationBar.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/13.
//

import UIKit

class CustomNavigationBar: UINavigationBar {

    //NavigationBarの高さ
    let barHeight: CGFloat = 66
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: barHeight)
    }
    
}
