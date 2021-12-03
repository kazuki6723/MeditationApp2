//
//  BaseViewController.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/17.
//

import UIKit
import SegementSlide

class BaseViewController: SegementSlideDefaultViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultSelectedIndex = 0
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func segementSlideHeaderView() -> UIView {
        let headerView = UIImageView()
        headerView.contentMode = .scaleAspectFill
        headerView.image = UIImage(named: "header")
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let headerHeight: CGFloat
        
        if #available(iOS 11.0, *) {
            headerHeight = view.bounds.height/4+view.safeAreaInsets.top
        } else {
            headerHeight = view.bounds.height/4+topLayoutGuide.length
        }
        headerView.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true
        return headerView
    }
    
    override var titlesInSwitcher: [String] {
        return ["記事","動画"]
    }
    
    override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        switch index {
        case 0:
            return NewsViewController()
        case 1:
            return VideoViewController()
        default:
            return NewsViewController()
        }
    }
    
}
