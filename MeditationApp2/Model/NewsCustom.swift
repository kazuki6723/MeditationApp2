//
//  NewsCustom.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/21.
//

import Foundation

class NewsCustom: Decodable {
    let articles: [Articles]
}

class Articles: Decodable {
    let title: String?
    let url: String?
    let urlToImage: String?
}
