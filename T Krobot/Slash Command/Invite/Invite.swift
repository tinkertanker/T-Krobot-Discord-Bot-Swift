//
//  Invite.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 21/3/23.
//

import Foundation
import DiscordBM

class Invite: SlashCommandable {
    var slashCommand: RequestBody.ApplicationCommandCreate {
        .init(name: "invite",
              description: "Invite someone into the channel",
              options: [
                .init(type: .user,
                      name: "who",
                      description: "Who do you want to invite to this channel?",
                      required: true)
              ])
    }
    
    var bot: GatewayManager
    
    func handleInteraction(_ interaction: Interaction) async throws {
        var user: String?
        
        switch interaction.data {
        case .applicationCommand(let data):
            user = data.options?.first?.value?.asString
        default: break
        }
        
        guard let user = user,
              let channelId = interaction.channel_id else { return }
        
        guard let classInfo = persistenceManager.classes.values.first(where: {
            $0.channelId == channelId
        }) else {
            let message = "`/invite` is not supported in this channel. Use it in a class channel."
            
            let response = RequestBody.InteractionResponse(type: .channelMessageWithSource,
                                                           data: .init(content: message,
                                                                       flags: [.ephemeral]))
            
            _ = try await bot.client.createInteractionResponse(id: interaction.id,
                                                               token: interaction.token,
                                                               payload: response)
            
            return
        }
        
        _ = try await bot.client.addGuildMemberRole(guildId: DiscordManager.Constant.guildId,
                                                    userId: user,
                                                    roleId: classInfo.roleId)
        
        let response = RequestBody.InteractionResponse(type: .channelMessageWithSource,
                                                       data: .init(content: "<@\(user)> was added to this channel."))
        
        _ = try await bot.client.createInteractionResponse(id: interaction.id,
                                                           token: interaction.token,
                                                           payload: response)
        
    }
    
    required init(bot: GatewayManager) {
        self.bot = bot
    }
}
