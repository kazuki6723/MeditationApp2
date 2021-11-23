//
//  WebViewController.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/21.
//

import UIKit
import WebKit
import Firebase

class WebViewController: UIViewController, WKUIDelegate {
    
    private var webView = WKWebView()
    var urlString = String()
    var imageString = String()
    private var favoriteButton = UIButton()
    
    private let db = Firestore.firestore()
    private var likeContents = [LikeContents]()
    private var likeFlag = 0
    private var documentID = String()
    private var loadFlag = 0
    private var webImageString: String? = nil
    
    private var userID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFlag = 1
        loadData()
        setUpWebView()
        configureToolBar()
        if UserDefaults.standard.object(forKey: "userID") != nil {
            userID = UserDefaults.standard.object(forKey: "userID") as! String
        }
    }
    
    private func loadData() {
        db.collection("favorite").order(by: "createdAt").addSnapshotListener { snapshot, error in
            if error != nil {
                print(error.debugDescription)
                return
            }
            if let snapshotDoc = snapshot?.documents {
                self.likeContents = []
                for doc in snapshotDoc {
                    let data = doc.data()
                    if self.userID == data["userName"] as! String {
                        if let url = data["url"] as? String, let likeFlag = data["likeFlag"] as? String {
                            let newLikeContent = LikeContents(url: url, documentID: doc.documentID, likeFlag: likeFlag)
                            self.likeContents.append(newLikeContent)
                            self.likeContents.reverse()
                            
                        }
                    }
                }
                if self.loadFlag == 1 {
                    let webUrl = self.webView.url?.absoluteString
                    for likeContent in self.likeContents {
                        if let webUrlString = webUrl {
                            if likeContent.url == webUrlString, likeContent.likeFlag == "1" {
                                self.favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                                break
                            }
                        }
                    }
                    self.loadFlag = 0
                }
            }
        }
    }

    private func setUpWebView() {
        self.view.backgroundColor = .white
        webView.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: self.view.frame.size.height - 20)
        self.view.addSubview(webView)
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        webView.load(request)
        webView.allowsBackForwardNavigationGestures = true
        
    }
    
    private func configureToolBar() {
        // ツールバーの高さ
        let footerBarHeight: CGFloat = 49
        
        // ツールバーのインスタンス化
        let toolbar = UIToolbar(frame: CGRect(
                                    x: 0,
                                    y: self.view.bounds.size.height - footerBarHeight,
                                    width: self.view.bounds.size.width,
                                    height: footerBarHeight)
        )
        
        toolbar.barStyle = .black
        
        //戻るボタンの実装
        let backButton = UIButton(frame: CGRect(x: 0, y:0, width: 49, height: 49))
        backButton.setTitle("←", for: .normal)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        
        //ボタンを左右に分けるためのスペースの実装
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                           target: nil, action: nil)
        
        //進むボタンの実装
        let nextButton = UIButton(frame: CGRect(x: 0, y:0, width: 49, height: 49))
        nextButton.setTitle("→", for: .normal)
        nextButton.addTarget(self, action: #selector(goToNext), for: .touchUpInside)
        let nextButtonItem = UIBarButtonItem(customView: nextButton)
        
        let returnButton = UIButton(frame: CGRect(x: 0, y:0, width: 49, height: 49))
        returnButton.setTitle("閉じる", for: .normal)
        returnButton.addTarget(self, action: #selector(returnAction), for: .touchUpInside)
        let returnButtonItem = UIBarButtonItem(customView: returnButton)
        
        favoriteButton.frame = CGRect(x: 0, y: 0, width: 49, height: 49)
        favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        favoriteButton.addTarget(self, action: #selector(favoriteItem(_:)), for: .touchUpInside)
        let favoriteButtonItem = UIBarButtonItem(customView: favoriteButton)
        
        // ツールバーにアイテムを追加する.
        toolbar.items = [backButtonItem,flexibleItem,returnButtonItem,flexibleItem,favoriteButtonItem,flexibleItem,nextButtonItem]
        
        self.view.addSubview(toolbar)
        
        NSLayoutConstraint.activate([
            toolbar.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 49)
        ])
    }
    
    @objc func back() {
        webView.goBack()
    }
    
    @objc func goToNext() {
        webView.goForward()
    }
    
    @objc func returnAction() {
        webView.removeFromSuperview()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func favoriteItem(_ sender: UIBarButtonItem) {
        let webTitle = webView.title
        let webUrl = webView.url
        let webUrlString = webUrl?.absoluteString
        likeFlag = 0
        documentID = ""
        
        guard var webU = webUrlString else {
            //アラートを出す
            return
        }
        
        if webU.contains("m.youtube.com") {
            webU = webU.replacingOccurrences(of: "m.youtube.com", with: "www.youtube.com")
        }
        
        for likeContent in likeContents {
            if webU == likeContent.url {
                likeFlag = 1
                documentID = likeContent.documentID
                break
            }
        }
        
        if webU == urlString {
            webImageString = imageString
        }

        if favoriteButton.imageView!.image == UIImage(systemName: "star") {
            favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            
            if likeFlag == 1 {
                db.collection("favorite").document(documentID).updateData(["likeFlag": "1"]) { error in
                    if error != nil {
                        print(error.debugDescription)
                        return
                    }
                }
                
            } else {
                db.collection("favorite").addDocument(data: ["userName": userID, "title": webTitle as Any, "url": webU as Any, "image": webImageString as Any, "likeFlag": "1", "createdAt": Date().timeIntervalSince1970]) { error in
                    if error != nil {
                        print(error.debugDescription)
                        return
                    }
                    self.db.collection("favorite").addSnapshotListener { snapShot, error in
                        if error != nil {
                            print(error.debugDescription)
                            return
                        }
                        if let snapShotDoc = snapShot?.documents {
                            self.likeContents = []
                            for doc in snapShotDoc {
                                let data = doc.data()
                                if self.userID == data["userName"] as? String {
                                    if let url = data["url"] as? String, let likeFlag = data["likeFlag"] as? String {
                                        let newLikeContent = LikeContents(url: url, documentID: doc.documentID, likeFlag: likeFlag)
                                        self.likeContents.append(newLikeContent)
                                        self.likeContents.reverse()
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
            
        } else {
            favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            db.collection("favorite").document(documentID).updateData(["likeFlag": "0"]) { error in
                if error != nil {
                    print(error.debugDescription)
                    return
                }
                self.db.collection("favorite").addSnapshotListener { snapShot, error in
                    if error != nil {
                        print(error.debugDescription)
                        return
                    }
                    if let snapShotDoc = snapShot?.documents {
                        self.likeContents = []
                        for doc in snapShotDoc {
                            let data = doc.data()
                            if self.userID == data["userName"] as? String {
                                if let url = data["url"] as? String, let likeFlag = data["likeFlag"] as? String {
                                    let newLikeContent = LikeContents(url: url, documentID: doc.documentID, likeFlag: likeFlag)
                                    self.likeContents.append(newLikeContent)
                                    self.likeContents.reverse()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}
