//
//  FirstViewSetUpViewController.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 6/28/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class FirstViewSetUpViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let cellSwitch = UISwitch()
    private var cellSwitchState = Bool()
    private var viewLoadFlag = 1
    
    private let db = Firestore.firestore()
    private var originalMeditation = [OriginalMeditation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.allowsSelection = true
        self.tabBarController?.tabBar.isHidden = true
        loadData()
        if UserDefaults.standard.object(forKey: "FirstVSetUpCell") != nil {
            cellSwitchState = UserDefaults.standard.object(forKey: "FirstVSetUpCell") as! Bool
        }
        cellSwitch.addTarget(self, action: #selector(switchAction), for: .touchUpInside)
    }
    
    private func loadData(){
//        投稿された物を受信する
        db.collection("original").order(by: "arrayNumber").addSnapshotListener { (snapShot, error) in
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            self.originalMeditation = []
            
            if let snapShotDoc = snapShot?.documents{
                
                for doc in snapShotDoc {
                    let data = doc.data()
                    
                    if let userName = data["userName"] as? String, let title = data["title"] as? String, let minutes = data["minutes"] as? String, let seconds = data["seconds"] as? String, let bgm = data["bgm"] as? String, let alarm = data["alarm"] as? String, let arrayNumber = data["arrayNumber"] as? String {
                        
                        if userName == Auth.auth().currentUser?.uid {
                            let newFeeds = OriginalMeditation(title: title, minutes: minutes, seconds: seconds, bgm: bgm, alarm: alarm, documentID: doc.documentID, arrayNumber: arrayNumber)
                            self.originalMeditation.append(newFeeds)
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func switchAction() {
        originalMeditationSet()
        self.tableView.reloadData()
        UserDefaults.standard.setValue(cellSwitch.isOn, forKey: "FirstVSetUpCell")
    }
    
    private func originalMeditationSet() {
        if cellSwitch.isOn {
            let originalPath = originalMeditation[self.tableView.indexPathForSelectedRow!.row]
            let encoder = JSONEncoder()
            if let encodedData = try? encoder.encode(originalPath) {
                UserDefaults.standard.setValue(encodedData, forKey: "OriginalMeditation")
            }
        } else {
            if UserDefaults.standard.object(forKey: "OriginalMeditation") == nil {
                return
            }
            UserDefaults.standard.removeObject(forKey: "OriginalMeditation")
        }
    }
    
}

extension FirstViewSetUpViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return originalMeditation.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "FirstSUCell", for: indexPath)
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            cell.selectionStyle = .none
            cell.textLabel?.text = "アプリ起動時の画面設定"
            if viewLoadFlag == 1 {
                cellSwitch.isOn = cellSwitchState
                viewLoadFlag = 0
            }
            cell.accessoryView = cellSwitch
            return cell
        } else {
            cell.accessoryType = .none
            if indexPath.row == 0 {
                self.tableView.selectRow(at: IndexPath(row: 0, section: 1), animated: false, scrollPosition: .none)
                cell.accessoryType = .checkmark
            }
            cell.textLabel?.text = originalMeditation[indexPath.row].title
            cell.detailTextLabel?.text = "\(originalMeditation[indexPath.row].minutes):\(originalMeditation[indexPath.row].seconds)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 40
        } else {
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 43.5
        } else {
            if cellSwitch.isOn {
                return 43.5
            } else {
                return 0
            }
        }
    }
    
}
