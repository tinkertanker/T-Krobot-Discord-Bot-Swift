//
//  findPrivateChannel.swift
//  T Krobot
//
//  Created by Triston Wong on 28/6/23.
//

import Foundation
import DiscordBM

class FindPrivateChannel: SlashCommandable {
    
    var slashCommand: Payloads.ApplicationCommandCreate {
        // discord slash-command call
        .init(name: "find-priv-channel",
              description: "obtain quick link of private channel based on user",
              options: [
                .init(type: .user, name: "user", description: "find priv channel of user", required: true)
              ],
              default_member_permissions: [.administrator],
              type: .chatInput
        )
    }
    
    func handleInteraction(_ interaction: DiscordModels.Interaction) async throws {
        
        // isolates user variable from slash command
        var user: String?
        
        switch interaction.data {
        case .applicationCommand(let command):
            user = command.options?.first?.value!.asString
        default:
            break
        }
        
        guard let user = user else { return }
        
        let name = try await bot.client.getUser(id: UserSnowflake(user)).decode().username
            
        let allChannels = try await bot.client.listGuildChannels(
            guildId: DiscordManager.Constant.guildID).decode()
        
        var channelNeeded: DiscordChannel = allChannels[0]
        
        for channel in allChannels where channel.parent_id == DiscordManager.Constant.Category.privateMsg {
            if channel.topic?.contains(name) != nil {
                let isolatedName: String = (channel.topic?.substring(from: channel.topic!.count - name.count))!
                if isolatedName.contains(name) {
                    channelNeeded = channel
                }
            }
        }
        
        for channel in allChannels where channel.parent_id == DiscordManager.Constant.Category.privateMsg2 {
            if (channel.topic?.contains(name)) != nil {
                let isolatedName: String = (channel.topic?.substring(from: channel.topic!.count - name.count))!
                if isolatedName.contains(name) {
                    channelNeeded = channel
                }

            }
        }
        
        _ = try await bot.client.createInteractionResponse(
            id: interaction.id,
            token: interaction.token,
            payload: .channelMessageWithSource(
                .init(content: "<#\(channelNeeded.id.rawValue)>",
                      flags: [.ephemeral]
                     )))
        
    }
    
    var bot: any GatewayManager
    
    required init(bot: any GatewayManager) {
        self.bot = bot
    }
}
