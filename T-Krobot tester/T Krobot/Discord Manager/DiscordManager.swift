//
//  DiscordManager.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//  Edited by Triston Wong on 25/6/23
//

import Foundation
import DiscordBM
import AsyncHTTPClient

class DiscordManager {
    let httpClient: HTTPClient = HTTPClient(eventLoopGroupProvider: .createNew)
    
    let bot: BotGatewayManager
    
    let slashCommandManagers: [SlashCommandable]
    
    init() async {
        
        bot = await BotGatewayManager(
            eventLoopGroup: httpClient.eventLoopGroup,
            httpClient: httpClient,
            token: "MTExODA3MTMyNzQxNzQ1MDUzNg.GMK0Wb.E2obWkK3IBoLDQ1aYlMcd27t6gfBD0uTNQuhy0",
            appId: "1118071327417450536",
            presence: .init(
                activities: [.init(name: "for CFIs", type: .watching)],
                status: .online,
                afk: false
            ),
            intents: Gateway.Intent.allCases
        )
        
        slashCommandManagers = [
            LinkShortener(bot: bot),
            ClassCreator(bot: bot),
//            JoinChannels(bot: bot),
            Verification(bot: bot),
            Archive(bot: bot),
            Invite(bot: bot),
            CallingInstructors(bot: bot),
            CFIclose(bot: bot),
            FindPrivateChannel(bot: bot)
        ]
    }
    
    func initialize() {
        Task {
            await configureCommands()
            await bot.connect()

            let stream = await bot.makeEventsStream()
                for await event in stream {
                    EventHandler(event: event).handle()
                }
        }
    
        while true {        }
    }
}
