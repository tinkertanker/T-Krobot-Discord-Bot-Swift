//
//  DiscordManager.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//

import Foundation
import DiscordBM
import AsyncHTTPClient

class DiscordManager {
    let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
    
    let bot: BotGatewayManager
    
    let slashCommandManagers: [SlashCommandable]
    
    init() {
        bot = BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            token: keys.discordToken,
            appId: keys.discordAppID,
            presence: .init(
                activities: [.init(name: "for CFIs", type: .watching)],
                status: .online,
                afk: false
            ),
            intents: [.guildMessages]
        )
        
        slashCommandManagers = [
            LinkShortener(bot: bot),
            ClassCreator(bot: bot)
        ]
    }
    
    func initialize() {
        Task {
            await configureEventHandler()
            await configureCommands()
            
            await bot.connect()
        }
        
        while true {}
    }
}
