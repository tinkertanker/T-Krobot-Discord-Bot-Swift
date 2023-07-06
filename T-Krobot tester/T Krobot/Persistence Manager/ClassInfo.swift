//
//  ClassInfo.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 20/3/23.
//

import Foundation
import DiscordBM

struct ClassInfo: Codable, Hashable {
    
    // used for ClassCreator & PersistenceManager (leave blank)
    
    var name: String
    
    var channelId: String
    var roleId: String
    
    var notionURL: String
    
    var archived: Bool
}
