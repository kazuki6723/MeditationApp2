//
//  HomeViewController.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/13.
//

import UIKit
import Firebase
import FirebaseFirestore

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    private let db = Firestore.firestore()
    var originalM: [OriginalMeditation] = []
    
    var arrayNumber = Int() {
        //変更があった後に実行
        didSet {
            //arrayNumberをセット
            UserDefaults.standard.setValue(self.arrayNumber, forKey: "arrayNumber")
        }
    }
    
    private let indicatorSetUp = IndicatorSetUp()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        if let arrayN = UserDefaults.standard.object(forKey: "arrayNumber") {
            self.arrayNumber = arrayN as! Int
        } else {
            self.arrayNumber = 1
        }
        
        if let savedData = UserDefaults.standard.object(forKey: "OriginalMeditation") {
            let decoder = JSONDecoder()
            if let data = try? decoder.decode(OriginalMeditation.self, from: savedData as! Data) {
                originalM.append(data)
                let playerVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayerVC") as! PlayerViewController
                playerVC.originalM = self.originalM[0]
                self.present(playerVC, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        indicatorSetUp.startIndicator(view: self.view)
        loadData()
    }
    
    private func loadData(){
//        投稿された物を受信する
        db.collection("original").order(by: "arrayNumber").addSnapshotListener { (snapShot, error) in
            if error != nil {
                self.indicatorSetUp.dismiss(view: self.view)
                print(error.debugDescription)
                return
            }
            
            self.originalM = []
            
            if let snapShotDoc = snapShot?.documents{
                
                for doc in snapShotDoc {
                    let data = doc.data()
                    
                    if let userName = data["userName"] as? String, let title = data["title"] as? String, let minutes = data["minutes"] as? String, let seconds = data["seconds"] as? String, let bgm = data["bgm"] as? String, let alarm = data["alarm"] as? String, let arrayNumber = data["arrayNumber"] as? String {
                        
                        if userName == Auth.auth().currentUser?.uid {
                            let newFeeds = OriginalMeditation(title: title, minutes: minutes, seconds: seconds, bgm: bgm, alarm: alarm, documentID: doc.documentID, arrayNumber: arrayNumber)
                            self.originalM.append(newFeeds)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
            self.indicatorSetUp.dismiss(view: self.view)
        }
    }
    
    
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        tableView.allowsSelectionDuringEditing = true
        if sender.title == "編集" {
            tableView.isEditing = true
            tableView.allowsSelectionDuringEditing = true
            sender.title = "完了"
        } else {
            tableView.isEditing = false
            tableView.allowsSelectionDuringEditing = false
            sender.title = "編集"
        }
    }
    
    @IBAction func goOriginalVC(_ sender: Any) {
        if editButton.title == "完了" {
            editButton.title = "編集"
            tableView.isEditing = false
            tableView.allowsSelectionDuringEditing = false
        }
        goOriginalVC()
    }
        
    //originalVCに遷移する
    func goOriginalVC() {
        let originalVC = self.storyboard?.instantiateViewController(withIdentifier: "OriginalVC") as! OriginalViewController
        originalVC.arrayNumber = arrayNumber
        //遷移先のクロージャを飛び出す
        originalVC.giveArrayNumber = { (arrayNumber) in
            self.arrayNumber = arrayNumber
        }
        self.present(originalVC, animated: true, completion: nil)
    }
    
    //arrayNumberを変更
    private func changeArrayNumber() {
        for i in 0...self.originalM.count - 1 {
            let arrayNumber = Int(self.originalM[i].arrayNumber)
            if arrayNumber != i {
                self.originalM[i].arrayNumber = String(i)
                //Firebaseの情報をアップデート
                let batch = self.db.batch()
                let sfRef = self.db.collection("original").document(self.originalM[i].documentID)
                batch.updateData(["arrayNumber": String(i) as String ], forDocument: sfRef)
                batch.commit() { err in
                    if let err = err {
                        print("Error writing batch \(err)")
                    } else {
                        print("Batch write succeeded.")
                    }
                }
            }
        }

    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return originalM.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let homeCell = UITableViewCell(style: .subtitle, reuseIdentifier: "HomeCell")
        homeCell.textLabel?.numberOfLines = 0
        homeCell.textLabel?.text = originalM[indexPath.row].title
        homeCell.detailTextLabel?.text = "\(originalM[indexPath.row].minutes)分\(originalM[indexPath.row].seconds)秒"
        homeCell.accessoryType = .disclosureIndicator
        homeCell.editingAccessoryType = .disclosureIndicator
        return homeCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.allowsSelectionDuringEditing {
            editButton.title = "編集"
            tableView.isEditing = false
            tableView.allowsSelectionDuringEditing = false
            let originalVC = self.storyboard?.instantiateViewController(withIdentifier: "OriginalVC") as! OriginalViewController
            originalVC.originalM.append(self.originalM[indexPath.row])
            self.present(originalVC, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            let playerVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayerVC") as! PlayerViewController
            playerVC.originalM = self.originalM[indexPath.row]
            self.present(playerVC, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    //TableViewCellを動かした時の処理
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //TableViewCellの並び替え
        //sourceIndexPath にデータの元の位置、destinationIndexPath に移動先の位置
        if sourceIndexPath.row != destinationIndexPath.row {
            let originalMSourceIndex = originalM[sourceIndexPath.row]
            //元の位置のデータを配列から削除
            self.originalM.remove(at: sourceIndexPath.row)
            
            //移動先の位置にデータを配列に挿入
            self.originalM.insert(originalMSourceIndex, at: destinationIndexPath.row)
            
            changeArrayNumber()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(
            style: .destructive,
            title: "削除"
        ) { (action, sourceView, completionHandler) in
            
            completionHandler(true)
            
            //削除
            let batch = self.db.batch()
            let laRef = self.db.collection("original").document(self.originalM[indexPath.row].documentID)
            batch.deleteDocument(laRef)
            // Commit the batch
            batch.commit() { err in
                if let err = err {
                    print("Error writing batch \(err)")
                } else {
                    print("Batch write succeeded.")
                }
            }
//            self.db.collection("original").document(self.originalM[indexPath.row].documentID).delete { error in
//                if let error = error {
//                    print(error)
//                }
//            }
            
            self.originalM.remove(at: indexPath.row)
            self.changeArrayNumber()
            self.arrayNumber -= 1
        }
        let actions = [editAction]
        let configulation = UISwipeActionsConfiguration(actions: actions)
        return configulation
    }
    
}
