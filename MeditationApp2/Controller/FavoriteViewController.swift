//
//  FavoriteViewController.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/22.
//

import UIKit
import Firebase
import SDWebImage

class FavoriteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var favCon = [FavoriteContents]()
    private let db = Firestore.firestore()
    private var userID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.object(forKey: "userID") != nil {
            userID = UserDefaults.standard.object(forKey: "userID") as! String
        }
        loadData()
        self.tableView.register(UINib(nibName: "MediaCustomCell", bundle: nil), forCellReuseIdentifier: "MediaCustom")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    private func loadData() {
        db.collection("favorite").order(by: "createdAt").addSnapshotListener { snapshot, error in
            if error != nil {
                print(error.debugDescription)
                return
            }
            if let snapshotDoc = snapshot?.documents {
                self.favCon = []
                for doc in snapshotDoc {
                    let data = doc.data()
                    if self.userID == data["userName"] as! String, data["likeFlag"] as! String == "1", let title = data["title"] as? String, let url = data["url"] as? String, let image = data["image"] as? String {
                        let newFavCon = FavoriteContents(title: title, url: url, image: image, documentID: doc.documentID)
                        self.favCon.append(newFavCon)
                        self.favCon.reverse()
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
}

extension FavoriteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favCon.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCustom", for: indexPath) as! MediaCustomCell
        cell.accessoryType = .disclosureIndicator
        cell.titleLabel.text = favCon[indexPath.row].title
        cell.detailLabel.text = favCon[indexPath.row].url
        cell.thumbnailsImageView.sd_setImage(with: URL(string: favCon[indexPath.row].image), completed: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let webView = WebViewController()
        webView.modalPresentationStyle = .fullScreen
        webView.urlString = favCon[indexPath.row].url
        webView.imageString = favCon[indexPath.row].image
        present(webView, animated: true, completion: nil)
    }
    
}
