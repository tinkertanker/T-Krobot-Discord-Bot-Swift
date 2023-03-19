//
//  DiscordManager+Constants.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//

import Foundation

extension DiscordManager {
    enum Constant {
        enum Channel {
            static let holdingRoom = "1086944083920048129"
            static let verifications = "1086943862796333118"
        }
        
        enum Role {
            static let verifiers = "1086946406989828236"
            static let trainer = "1086943974004113481"
        }
        
        enum Emoji {
            static let tclogo1 = "<:tclogo1:1086958864450207755>"
            static let tclogo2 = "<:tclogo2:1086958866635440218>"
            static let tclogo3 = "<:tclogo3:1086958869902807172>"
            static let tclogo4 = "<:tclogo4:1086958873065291917>"
            static let tclogo5 = "<:tclogo5:1086958877033111692>"
            static let tclogo6 = "<:tclogo6:1086958879147049000>"
            static let tclogo7 = "<:tclogo7:1086958882598948894>"
            
            static let tcLockup = tclogo1 + tclogo2 + tclogo3 + tclogo4 + tclogo5 + tclogo6 + tclogo7
        }
        
        static let guildId = "1055369990435516447"
    }
}
