//
//  OriginalViewController.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/13.
//

import UIKit
import Firebase
import FirebaseFirestore

class OriginalViewController: UIViewController, UITextFieldDelegate, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    private var selectArray: [String] = ["タイトル","3分00秒","雨音","黒電話",]
    private var dismissFlag = 0
    
    private var pickerViewFlag = 0
    private let timesPickerView: UIPickerView = UIPickerView()
    private let bgmPickerView: UIPickerView = UIPickerView()
    private let alarmPickerView: UIPickerView = UIPickerView()
    private let pickerViewHeight: CGFloat = 200
    private var pickerIndexPath: IndexPath!
    private var minutes: String = "3"
    private var seconds: String = "00"
    
    private let toolbar: UIToolbar = UIToolbar()
    private let toolbarHeight: CGFloat = 40.0
    
    private let mStr = UILabel()
    private let sStr = UILabel()
    private let timesStringArray = ["00","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59"]
    private let bgmStringArray = ["雨音","川のせせらぎ","鳥のさえずり","浜辺","森",]
    private let alarmStringArray = ["アラーム","黒電話"]
    
    private let db = Firestore.firestore()
    var arrayNumber = Int()
    
    var originalM: [OriginalMeditation] = []
    private var originalDetailFlag = 0
    
    var giveArrayNumber: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        navigationController?.presentationController?.delegate = self
        self.presentationController?.delegate = self
        timesPickerView.delegate = self
        timesPickerView.dataSource = self
        bgmPickerView.delegate = self
        bgmPickerView.dataSource = self
        alarmPickerView.delegate = self
        alarmPickerView.dataSource = self
        if !originalM.isEmpty {
            originalDetailFlag = 1
            addButton.title = "完了"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if dismissFlag == 1 {
            return false
        } else {
            return true
        }
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        cancelAlert()
    }
    
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        //FireStoreへ値を保存する
        if (Auth.auth().currentUser?.uid) != nil {
            
            if originalDetailFlag == 1 {
                //Firebaseの情報をアップデート
                db.collection("original").document(originalM[0].documentID).updateData(["title": originalM[0].title as String, "minutes": originalM[0].minutes as String, "seconds": originalM[0].seconds as String, "bgm": originalM[0].bgm as String, "alarm": originalM[0].alarm as String])
                db.batch().commit() { err in
                    if let err = err {
                        print("Error writing batch \(err)")
                    } else {
                        print("Batch write succeeded.")
                    }
                }

            } else {
                print(seconds)
                db.collection("original").addDocument(data: ["userName": Auth.auth().currentUser?.uid as Any, "title": selectArray[0], "minutes": minutes, "seconds": seconds, "bgm": selectArray[2], "alarm": selectArray[3], "createdAt": Date().timeIntervalSince1970, "arrayNumber": String(arrayNumber)]) { (error) in
                    if error != nil {
                        print(error.debugDescription)
                        return
                    }
                }
            }
        }
        
        //値を渡して、遷移元に遷移する
        self.arrayNumber += 1
        self.dismiss(animated: true) {
            self.giveArrayNumber?(self.arrayNumber)
        }
    }

    @IBAction func returnButton(_ sender: Any) {
        if dismissFlag == 1 {
            cancelAlert()
        } else {
            dismiss(animated: true)
        }
    }
    
    // MARK: - AlertAction
    func titleAlert() {
        let titleAlert = UIAlertController(title: "タイトル", message: "タイトルを記入してください。", preferredStyle: .alert)
        titleAlert.addTextField { textField in
            textField.delegate = self
            textField.placeholder = "タイトル"
        }
        //キャンセルボタン
        titleAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        //追加ボタン
        titleAlert.addAction(UIAlertAction(title: "追加", style: .default, handler: { action in
            let titleLabel = titleAlert.textFields?.last?.text?.trimmingCharacters(in: .whitespaces)
            if ((titleLabel!.isEmpty) == true) {
                let alert = UIAlertController(title: "文字が入力されていません。", message: "文字を入力してください。", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
                
                if self.originalDetailFlag == 1 {
                    self.originalM[0].title = titleLabel!
                } else {
                    self.selectArray[0] = titleLabel!
                }
                
                self.dismissFlag = 1
                self.tableView.reloadData()
            }
        }))
        present(titleAlert, animated: true)
    }
    
    func cancelAlert() {
        let cancelAlert = UIAlertController(title: "この画面を閉じてもよろしいですか？", message: "変更した内容は削除されます。", preferredStyle: .actionSheet)
        cancelAlert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        cancelAlert.addAction(UIAlertAction(title: "閉じる", style: .destructive) { _ in
            self.dismiss(animated: true)
        })
        present(cancelAlert, animated: true)
    }
    
}

// MARK: - TableView
extension OriginalViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let stringArray = ["タイトル","時間","BGM","アラーム音"]
        let originalCell = UITableViewCell(style: .value1, reuseIdentifier: "OriginalCell")
        originalCell.textLabel!.text = stringArray[indexPath.row]
        
        if originalDetailFlag == 1 {
            
            switch indexPath.row {
            case 0:
                originalCell.detailTextLabel?.text = originalM[0].title
            case 1:
                originalCell.detailTextLabel?.text = "\(originalM[0].minutes)分\(originalM[0].seconds)秒"
            case 2:
                originalCell.detailTextLabel?.text = originalM[0].bgm
            default:
                originalCell.detailTextLabel?.text = originalM[0].alarm
            }
            
        } else {
            originalCell.detailTextLabel?.text = selectArray[indexPath.row]

        }
        
        originalCell.accessoryType = .disclosureIndicator
        return originalCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        pickerIndexPath = indexPath
        
        switch pickerIndexPath.row {
        case 0:
            if pickerViewFlag == 1 {
                pickerViewClose(pickerView: timesPickerView)
                pickerViewClose(pickerView: bgmPickerView)
                pickerViewClose(pickerView: alarmPickerView)
            }
            titleAlert()
        case 1:
            pickerViewOpen(pickerView: timesPickerView)
            createPickerViewLabel()
            if pickerViewFlag != 1 {
                pickerViewFlag = 1
            }
        case 2:
            pickerViewOpen(pickerView: bgmPickerView)
            if pickerViewFlag != 1 {
                pickerViewFlag = 1
            }
        case 3:
            pickerViewOpen(pickerView: alarmPickerView)
            if pickerViewFlag != 1 {
                pickerViewFlag = 1
            }
        default:
            break
        }

    }
    
}


// MARK: - PickerView
extension OriginalViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerIndexPath.row {
        case 1:
            return 2
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerIndexPath.row {
        case 1:
            return 60
        case 2:
            return 5
        default:
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch pickerIndexPath.row {
        case 1:
            return pickerView.bounds.width / 4
        default:
            return pickerView.bounds.width
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        switch pickerIndexPath.row {
        case 1:
            let timesLabel = UILabel()
            timesLabel.textAlignment = .left
            timesLabel.text = timesStringArray[row]
            timesLabel.font = .systemFont(ofSize: 30)
            return timesLabel
        case 2:
            let bgmLabel = UILabel()
            bgmLabel.textAlignment = .center
            bgmLabel.text = bgmStringArray[row]
            bgmLabel.font = .systemFont(ofSize: 30)
            return bgmLabel
        default:
            let alarmLabel = UILabel()
            alarmLabel.textAlignment = .center
            alarmLabel.text = alarmStringArray[row]
            alarmLabel.font = .systemFont(ofSize: 30)
            return alarmLabel
        }
    }
    
    func pickerViewOpen(pickerView: UIPickerView) {
        if pickerViewFlag == 1 {
            switch pickerView {
            case timesPickerView:
                pickerViewClose(pickerView: bgmPickerView)
                pickerViewClose(pickerView: alarmPickerView)
                break
            case bgmPickerView:
                pickerViewClose(pickerView: timesPickerView)
                pickerViewClose(pickerView: alarmPickerView)
            default:
                pickerViewClose(pickerView: timesPickerView)
                pickerViewClose(pickerView: bgmPickerView)
            }
        }
        pickerView.reloadAllComponents()
        createPickerView(pickerView: pickerView)
        createToolbar()
        UIView.animate(withDuration: 0.2) {
            self.toolbar.frame = CGRect(x: 0, y: self.view.frame.size.height - self.pickerViewHeight - self.toolbarHeight, width: self.view.frame.size.width, height: self.toolbarHeight)
            pickerView.frame = CGRect(x: 0, y: self.view.frame.size.height - self.pickerViewHeight, width: self.view.frame.size.width, height: self.pickerViewHeight)
        }
    }
    
    
    func pickerViewClose(pickerView: UIPickerView) {
        UIView.animate(withDuration: 0.2){
            self.toolbar.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: self.toolbarHeight)
            pickerView.frame = CGRect(x: 0, y: self.view.frame.size.height + self.toolbarHeight, width: self.view.frame.size.width, height: self.pickerViewHeight)
        }
    }
    
    func createPickerView(pickerView: UIPickerView) {
        pickerView.frame = CGRect(x: 0, y: toolbarHeight + self.view.frame.size.height, width: self.view.frame.size.width, height: pickerViewHeight)
        pickerView.backgroundColor = .lightGray
        self.view.addSubview(pickerView)
    }
    
    func createToolbar() {
        // 決定バーの生成
        toolbar.frame = CGRect(x: 0, y: self.view.frame.size.height, width: view.frame.size.width, height: toolbarHeight)
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "決定", style: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        self.view.addSubview(toolbar)
    }
    
    // 決定ボタン押下
    @objc func done() {
        dismissFlag = 1
        switch pickerIndexPath.row {
        case 1:
            
            if originalDetailFlag == 1 {
                var minutesLabel = timesStringArray[timesPickerView.selectedRow(inComponent: 0)]
                let startIndex = timesStringArray[timesPickerView.selectedRow(inComponent: 0)].startIndex
                if minutesLabel[startIndex] == "0" {
                    minutesLabel = String(minutesLabel.dropFirst())
                }
                let secondsLabel = timesStringArray[timesPickerView.selectedRow(inComponent: 1)]
                selectArray[1] = "\(minutesLabel)分\(secondsLabel)秒"
                originalM[0].minutes = minutesLabel
                originalM[0].seconds = secondsLabel

            } else {
                var minutesLabel = timesStringArray[timesPickerView.selectedRow(inComponent: 0)]
                let startIndex = timesStringArray[timesPickerView.selectedRow(inComponent: 0)].startIndex
                if minutesLabel[startIndex] == "0" {
                    minutesLabel = String(minutesLabel.dropFirst())
                }
                let secondsLabel = timesStringArray[timesPickerView.selectedRow(inComponent: 1)]

                selectArray[1] = "\(minutesLabel)分\(secondsLabel)秒"
                self.minutes = minutesLabel
                self.seconds = secondsLabel
            }
            
            pickerViewClose(pickerView: timesPickerView)
        case 2:
            
            if originalDetailFlag == 1 {
                originalM[0].bgm = "\(bgmStringArray[bgmPickerView.selectedRow(inComponent: 0)])"
            } else {
                selectArray[2] = "\(bgmStringArray[bgmPickerView.selectedRow(inComponent: 0)])"
            }
            
            pickerViewClose(pickerView: bgmPickerView)
        default:
            
            if originalDetailFlag == 1 {
                originalM[0].alarm = "\(alarmStringArray[alarmPickerView.selectedRow(inComponent: 0)])"

            } else {
                selectArray[3] = "\(alarmStringArray[alarmPickerView.selectedRow(inComponent: 0)])"
            }
            pickerViewClose(pickerView: alarmPickerView)
        }
        
        tableView.reloadData()
    }
    
    func createPickerViewLabel() {
        //「分」のラベルを追加
        mStr.text = "分"
        mStr.font = .systemFont(ofSize: 30)
        mStr.sizeToFit()
        mStr.frame = CGRect(x: timesPickerView.bounds.width / 3 + mStr.bounds.width / 2, y: timesPickerView.bounds.height / 2 - mStr.bounds.height / 2, width: mStr.bounds.width, height: mStr.bounds.height)
        timesPickerView.addSubview(mStr)
        //「秒」のラベルを追加
        sStr.text = "秒"
        sStr.font = .systemFont(ofSize: 30)
        sStr.sizeToFit()
        sStr.frame = CGRect(x: timesPickerView.bounds.width * 2 / 3 - sStr.bounds.width / 2, y: timesPickerView.bounds.height / 2 - sStr.bounds.height / 2, width: sStr.bounds.width, height: sStr.bounds.height)
        timesPickerView.addSubview(sStr)
    }
    
}
