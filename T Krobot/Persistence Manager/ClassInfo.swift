//
//  ClassInfo.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 20/3/23.
//

import Foundation

struct ClassInfo: Codable {
    var name: String
    
    var channelId: String
    var roleId: String
    var notionURL: String
    
    var archived: Bool
}
