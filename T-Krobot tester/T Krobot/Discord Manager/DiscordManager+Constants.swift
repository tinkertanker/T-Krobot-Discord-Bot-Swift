//
//  DiscordManager+Constants.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//  Edited by Triston Wong on 19/6/23
//

import Foundation
import DiscordBM

// input discord channel, role, and emoji, and catagory IDs here
// to find Discord IDs, right click on a channel (or specific discord object) and select "Copy ___ ID"

extension DiscordManager {
    enum Constant {
        enum Channel {
            static let holdingRoom: Snowflake<DiscordChannel> = ""
            static let verifications: Snowflake<DiscordChannel> = ""
            static let callForInstructor: Snowflake<DiscordChannel> = ""
            static let welcomeDiscord: Snowflake<DiscordChannel> = ""
            static let chat: Snowflake<DiscordChannel> = ""
            static let adminQuestions: Snowflake<DiscordChannel> = ""
        }
        
        enum Roles {
            static let verifiers = Snowflake<Role>("")
            static let trainer = Snowflake<Role>("")
            static let everyone = Snowflake<Role>("")
            static let tinkerTanker = Snowflake<Role>("")
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
        
        static let guildID = Snowflake<Guild>("")
        
        enum Category {
            static let classesCategory = AnySnowflake("")
            static let archivedCategory = AnySnowflake("")
            static let privateMsg = AnySnowflake("")
            static let privateMsg2 = AnySnowflake("")
        }
    }
}
