//
//  DiscordManager+Verification.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//

import Foundation
import DiscordBM

extension DiscordManager {
    func sendWelcomeMesssage() async throws {
        
        let welcomeMessage = """
Welcome to the TKTrainers Discord Server!

This is the waiting room. Someone from the team will verify you soon.
"""
        
        _ = try await bot.client.createMessage(channelId: Constant.Channel.holdingRoom,
                                               payload: .init(content: Constant.Emoji.tcLockup))
        _ = try await bot.client.createMessage(channelId: Constant.Channel.holdingRoom,
                                               payload: .init(content: welcomeMessage))
    }
    
}
