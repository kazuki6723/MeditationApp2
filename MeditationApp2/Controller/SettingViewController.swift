//
//  SettingViewController.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/19.
//

import UIKit
import Firebase

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    private let StringArray = ["起動時の画面設定","お気に入り","アカウント削除"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        if (self.tabBarController?.tabBar.isHidden)! {
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SettingVCCell", for: indexPath)
        cell.textLabel?.text = StringArray[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            //初期画面でplayerViewを表示させるかの設定画面に行く
            let firstVVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstVSUVC") as! FirstViewSetUpViewController
            self.navigationController?.pushViewController(firstVVC, animated: true)
        } else if indexPath.row == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            //お気に入りが表示される画面にいく
            let favVC = self.storyboard?.instantiateViewController(withIdentifier: "FavVC") as! FavoriteViewController
            self.navigationController?.pushViewController(favVC, animated: true)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            //アカウント削除するのか確認のアラートを出す
            let alert = UIAlertController(title: "アカウント削除しますか？", message: "アカウントを削除すれば二度と復活させることはできません", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { action in
                do {
                    //サインアウトする
                    try Auth.auth().signOut()
                    //LoginVCに戻る
                    self.dismiss(animated: true, completion: nil)
                } catch {
                    print(error)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}
