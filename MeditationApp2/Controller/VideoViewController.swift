//
//  VideoViewController.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/20.
//

import UIKit
import SegementSlide
import Alamofire
import SDWebImage

class VideoViewController: UITableViewController, SegementSlideContentScrollViewDelegate {

    private var videoItems = [Item]()
    private var userID = String()
    private var videoUrl = [String]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "MediaCustomCell", bundle: nil), forCellReuseIdentifier: "MediaCustom")
        tableView.tableFooterView = UIView()
        if UserDefaults.standard.object(forKey: "userID") != nil {
            userID = UserDefaults.standard.object(forKey: "userID") as! String
        }
        urlRequest()
    }

    
    private func urlRequest() {
        let urlString = "https://www.googleapis.com/youtube/v3/search?key=AIzaSyDF_D472GAKG5UkkvmAe6SWuINLhwvmIbQ&q=%E7%9E%91%E6%83%B3&part=snippet&maxResults=20"
        let repuest = AF.request(urlString)
        repuest.responseJSON { response in
            do {
                guard let data = response.data else { return }
                let decoder = JSONDecoder()
                let video = try decoder.decode(VideoCustom.self, from: data)
                self.videoItems = video.items
                self.tableView.reloadData()
            } catch {
                print("エラー", error)
            }
        }
    }
    
    @objc var scrollView: UIScrollView {
        return tableView
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCustom", for: indexPath) as! MediaCustomCell
        cell.titleLabel.text = videoItems[indexPath.row].snippet.title
        self.videoUrl.append("https://www.youtube.com/watch?v=\(videoItems[indexPath.row].id.videoId)")
        cell.detailLabel.text = videoUrl[indexPath.row]
        cell.thumbnailsImageView.sd_setImage(with: URL(string: videoItems[indexPath.row].snippet.thumbnails.high.url), completed: nil)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let webView = WebViewController()
        webView.modalPresentationStyle = .fullScreen
        webView.urlString = videoUrl[indexPath.row]
        webView.imageString = videoItems[indexPath.row].snippet.thumbnails.high.url
        present(webView, animated: true, completion: nil)
    }
        
}
