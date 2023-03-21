//
//  Verification.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 20/3/23.
//

import Foundation
import DiscordBM

class Verification: SlashCommandable, MessageComponentable {
    var customIdPrefix = "verify"
    
    var bot: DiscordGateway.GatewayManager
    
    var slashCommand: RequestBody.ApplicationCommandCreate {
        .init(name: "welcome",
              description: "Submit a verification request",
              options: [
                .init(type: .string,
                      name: "name",
                      description: "Your name",
                      required: true,
                      min_length: 1,
                      max_length: 32)
              ],
              default_member_permissions: [.sendMessages],
              type: .chatInput)
    }
    
    func handleInteraction(_ interaction: DiscordModels.Interaction) async throws {
        guard let user = interaction.member?.user else { return }
        var name: String?
        
        switch interaction.data {
        case .applicationCommand(let command):
            name = command.options?.first?.value?.asString
        default: break
        }
        
        guard let name = name else { return }
        
        let message = "<@\(user.id)> just joined the server. If you recognise the user as a trainer, select **verify** and they will be let in."
        _ = try await bot.client.createMessage(channelId: DiscordManager.Constant.Channel.verifications,
                                               payload: .init(content: "<@&\(DiscordManager.Constant.Role.verifiers)>",
                                                              embeds: [
                                                                Embed(title: "\(name) Joined",
                                                                      description: message)
                                                              ],
                                                              components: [
                                                                .init(components: [
                                                                    .button(.init(style: .primary, label: "Verify", custom_id: "verify.\(user.id)"))
                                                                ])
                                                              ]))
        
        _ = try await bot.client.modifyGuildMember(guildId: DiscordManager.Constant.guildId,
                                                   userId: user.id,
                                                   payload: .init(nick: name))
        
        let payload = RequestBody.InteractionResponse(type: .channelMessageWithSource,
                                                      data: .init(content: "A verification request has been submitted. Someone from the team will approve it soon.", flags: [.ephemeral]))
        
        _ = try? await bot.client.createInteractionResponse(id: interaction.id,
                                                            token: interaction.token,
                                                            payload: payload)
    }
    
    func handleMessageComponent(_ component: DiscordModels.Interaction.MessageComponent,
                                interaction: DiscordModels.Interaction) async throws {
        let customId = component.custom_id
        guard let userId = customId.split(separator: ".").last else { return }
        
        try await addVerificationRole(userId: String(userId))
        try await deleteVerificationMessage(interaction: interaction)
        
        _ = try await self.bot.client.createInteractionResponse(id: interaction.id,
                                                                token: interaction.token,
                                                                payload: .init(type: .deferredUpdateMessage))
    }
    
    required init(bot: GatewayManager) {
        self.bot = bot
    }
    
    func addVerificationRole(userId: String) async throws {
        _ = try await bot.client.addGuildMemberRole(guildId: DiscordManager.Constant.guildId,
                                                    userId: userId,
                                                    roleId: DiscordManager.Constant.Role.trainer,
                                                    reason: "verification")
    }
    
    func deleteVerificationMessage(interaction: Interaction) async throws {
        guard let message = interaction.message else { return }
        
        _ = try await bot.client.deleteMessage(channelId: message.channel_id, messageId: message.id)
    }
}
