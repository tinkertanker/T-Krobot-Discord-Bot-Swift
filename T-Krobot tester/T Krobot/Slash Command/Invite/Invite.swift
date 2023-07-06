//
//  Invite.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 21/3/23.
//  Edited by Triston Wong on 20/6/23.
//

import Foundation
import DiscordBM

class Invite: SlashCommandable {
    var slashCommand: Payloads.ApplicationCommandCreate {
        // discord slash-command to call
        .init(name: "invite",
              description: "Invite someone into the channel",
              options: [
            .init(type: .user, name: "user1", description: "add user to channel",
                  required: true),
            .init(type: .user, name: "user2", description: "add user to channel"),
            .init(type: .user, name: "user3", description: "add user to channel"),
            .init(type: .user, name: "user4", description: "add user to channel"),
            .init(type: .user, name: "user5", description: "add user to channel"),
            .init(type: .user, name: "user6", description: "add user to channel"),
            .init(type: .user, name: "user7", description: "add user to channel"),
            .init(type: .user, name: "user8", description: "add user to channel"),
            .init(type: .user, name: "user9", description: "add user to channel"),
            .init(type: .user, name: "user10", description: "add user to channel")
                  ],
              default_member_permissions: [.sendMessages],
              type: .chatInput)
    }
    
    var bot: any GatewayManager
    
    func handleInteraction(_ interaction: Interaction) async throws {
        var users: [String] = []
        
        switch interaction.data {
        case .applicationCommand(let data):
            guard let options = data.options else { return }
            print(options)
            
            users = options.compactMap { option in
                if option.name.hasPrefix("user") {
                    return option.value?.asString
                } else {
                    return nil
                }
            }
        default: break
        }
        
        guard let channelId = interaction.channel_id else { return }
        
        // checks if slash-command is valid
        guard let classInfo = persistenceManager.classes.values.first(where: {
            Snowflake($0.channelId) == channelId
        }) else {
            let message = "`/invite` is not supported in this channel. Use it in a class channel."
            
            _ = try await bot.client.createInteractionResponse(id: interaction.id,
                                                               token: interaction.token,
                                                               payload: .channelMessageWithSource(
                                                                .init(content: message,
                                                                      flags: [.ephemeral]
                                                               )))
            
            return
        }
        
        // composes list of users to be added to channel
        users = Array(Set(users))
        
        var userAddMsg: String = ""
        
        // starts putting users into the text channel
        for userId in users {
            
            _ = try await bot.client.addGuildMemberRole(
                guildId: DiscordManager.Constant.guildID,
                userId: Snowflake<DiscordUser>(userId),
                roleId: Snowflake(classInfo.roleId))
            
            userAddMsg += "<@\(userId)> was added to this channel. \n"
        }
        
        // sends confirmation message in one single message
        _ = try await bot.client.createInteractionResponse(id: interaction.id,
                                                           token: interaction.token,
                                                           payload: .channelMessageWithSource(
                                                            .init(content: userAddMsg
                                                            )))
    }
    
    required init(bot: any GatewayManager) {
        self.bot = bot
    }
}
