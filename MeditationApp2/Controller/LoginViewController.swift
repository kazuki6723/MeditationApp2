//
//  LoginViewController.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/13.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {

    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    @IBAction func loginAction(_ sender: Any) {
        //匿名ログインを試みる
        Auth.auth().signInAnonymously { (result, error) in
//            if error != nil{
//                //アラートを表示
//                let alert = UIAlertController(title: "ログインできません", message: "ネットワーク環境をご確認の上、時間をおいてから再度行ってください", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
//                print(error.debugDescription)
//                return
//            }
//            
            //自分のIDをアプリ内に保持しておく
            UserDefaults.standard.setValue(result?.user.uid, forKey: "userID")
            
            //デフォルトの瞑想を登録する
            self.db.collection("original").addDocument(data: ["userName": result?.user.uid as Any, "title": "デフォルト", "minutes": "3", "seconds": "00", "bgm": "雨音", "alarm": "黒電話", "createdAt": Date().timeIntervalSince1970, "arrayNumber": "0"]) { error in
                if error != nil {
                    //アラートを表示
                    let alert = UIAlertController(title: "ログインできません", message: "ネットワーク環境をご確認の上、時間をおいてから再度行ってください", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print(error.debugDescription)
                    return
                }
                
                //画面遷移
                let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabVC") as! UITabBarController
                homeVC.modalPresentationStyle = .fullScreen
                self.present(homeVC, animated: true, completion: nil)
                
            }
        }
    }
    
}
