//
//  JoinChannels.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 20/3/23.
//

import Foundation
import DiscordBM

class JoinChannels: SlashCommandable, MessageComponentable {
    var customIdPrefix: String = "join"
    
    func handleMessageComponent(_ component: Interaction.MessageComponent,
                                interaction: Interaction) async throws {
        guard let userId = component.custom_id.split(separator: ".").last,
              let roleId = component.values?.first,
              let classInfo = persistenceManager.classes[roleId] else { return }
        
        _ = try await bot.client.addGuildMemberRole(guildId: DiscordManager.Constant.guildId,
                                                    userId: String(userId),
                                                    roleId: roleId)
        
        _ = try await bot.client.createInteractionResponse(id: interaction.id,
                                                           token: interaction.token,
                                                           payload: .init(type: .deferredUpdateMessage))
        
        _ = try await bot.client.createMessage(channelId: classInfo.channelId,
                                               payload: .init(content: "👋 <@\(userId)> joined the channel"))
    }
    
    var bot: DiscordGateway.GatewayManager
    
    var slashCommand: RequestBody.ApplicationCommandCreate {
        .init(name: "join",
              description: "Join a class.",
              default_member_permissions: [.sendMessages],
              type: .chatInput)
    }
    
    func handleInteraction(_ interaction: DiscordModels.Interaction) async throws {
        
        guard let user = interaction.member?.user else { return }
        
        let nonArchivedClasses = persistenceManager.classes.values.compactMap { classInfo in
            classInfo.archived ? nil : Interaction.ActionRow.SelectMenu.Option(label: classInfo.name,
                                                                               value: classInfo.roleId)
        }
        
        let component = [
            Interaction.ActionRow.Component.stringSelect(.init(custom_id: "join.\(user.id)",
                                                               options: nonArchivedClasses,
                                                               placeholder: "Select a class"))
        ]
        
        let payload = RequestBody.InteractionResponse(type: .channelMessageWithSource,
                                                      data: .init(content: "Which channel would you like to join?",
                                                                  flags: [.ephemeral],
                                                                  components: [
                                                                    .init(components: component)
                                                                  ]))
        
        _ = try? await bot.client.createInteractionResponse(id: interaction.id,
                                                            token: interaction.token,
                                                            payload: payload)
    }
    
    required init(bot: GatewayManager) {
        self.bot = bot
    }
}
