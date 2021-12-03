//
//  VideoCustom.swift
//  MeditationApp2
//
//  Created by 千葉和貴 on 2021/06/20.
//

import Foundation

class VideoCustom: Decodable {
    let items: [Item]
}

class Item: Decodable {
    let id: Id
    let snippet: Snippet
}

class Id: Decodable {
    let videoId: String
}

class Snippet: Decodable {
    let title: String
    let thumbnails: Thumbnails
}

class Thumbnails: Decodable {
    let high: High
}

class High: Decodable {
    let url: String
}
