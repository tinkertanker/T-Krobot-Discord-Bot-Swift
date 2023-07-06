//
//  ShortLinkResult.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 18/3/23.
//

import Foundation

struct ShortLinkResult: Codable {
    var originalURL: String
    var archived: Bool
    var lcpath: String
    var source: String
    var cloaking: Bool
    var createdAt: String
    var updatedAt: String
    var tags: [String]
    var path: String
    var idString: String
    var shortURL: String
    var secureShortURL: String
    var duplicate: Bool
}
