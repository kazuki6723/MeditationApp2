//
//  NewsViewController.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/21.
//

import UIKit
import SegementSlide
import Alamofire
import SDWebImage

class NewsViewController: UITableViewController, SegementSlideContentScrollViewDelegate {

    private var newsItems = [Articles]()
    private var userID = String()
                
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
        let urlString = "https://newsapi.org/v2/everything?q=%E7%9E%91%E6%83%B3&sortBy=popularity&apiKey=62eb4219560e4952b2bb3b31c7c5e4a6"
        let request = AF.request(urlString)
        request.responseJSON { response in
            do {
                guard let data = response.data else {
                    return
                }
                let decoder = JSONDecoder()
                let news = try decoder.decode(NewsCustom.self, from: data)
                self.newsItems = news.articles
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("news:", error)
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
        return newsItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCustom", for: indexPath) as! MediaCustomCell
        cell.titleLabel.text = newsItems[indexPath.row].title
        cell.detailLabel.text = newsItems[indexPath.row].url
        if let urlToImage = newsItems[indexPath.row].urlToImage {
            cell.thumbnailsImageView.sd_setImage(with: URL(string: urlToImage), completed: nil)
        }
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let webView = WebViewController()
        webView.modalPresentationStyle = .fullScreen
        if let urlString = newsItems[indexPath.row].url {
            webView.urlString = urlString
        }
        if let imageString = newsItems[indexPath.row].urlToImage {
            webView.imageString = imageString
        }
        present(webView, animated: true, completion: nil)
    }
    
}
