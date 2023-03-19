//
//  DiscordManager+Verification.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//

import Foundation
import DiscordBM

extension DiscordManager {
    func handleVerificationApproval(customId: String, interaction: Interaction) async throws {
        guard let userId = customId.split(separator: ".").last else { return }
        
        try await addVerificationRole(userId: String(userId))
        try await deleteVerificationMessage(interaction: interaction)
        
        _ = try await self.bot.client.createInteractionResponse(id: interaction.id,
                                                                token: interaction.token,
                                                                payload: .init(type: .deferredUpdateMessage))
    }
    
    func addVerificationRole(userId: String) async throws {
        _ = try await bot.client.addGuildMemberRole(guildId: Constant.guildId,
                                                    userId: userId,
                                                    roleId: Constant.Role.trainer,
                                                    reason: "verification")
    }
    
    func deleteVerificationMessage(interaction: Interaction) async throws {
        guard let message = interaction.message else { return }
        
        _ = try await bot.client.deleteMessage(channelId: message.channel_id, messageId: message.id)
    }
    
    func handleNewMember(member: Gateway.GuildMemberAdd) {
        Task {
            try await bot.client.createMessage(channelId: Constant.Channel.verifications,
                                               payload: .init(content: "<@&\(Constant.Role.verifiers)>",
                                                              embeds: [Embed(title: "Someone Joined", description: "<@\(member.user.id)> just joined the server. If you recognise the user as a trainer, select **verify** and they will be let in.")], components: [
                                                                .init(components: [
                                                                    .button(.init(style: .primary, label: "Verify", custom_id: "verify.\(member.user.id)"))
                                                                ])
                                                              ]))
        }
    }
    
    func sendWelcomeMesssage() async throws {
        _ = try await bot.client.createMessage(channelId: Constant.Channel.holdingRoom,
                                               payload: .init(content: Constant.Emoji.tcLockup))
        _ = try await bot.client.createMessage(channelId: Constant.Channel.holdingRoom,
                                               payload: .init(content: "Welcome to the TKTrainers Discord Server!\n\nThis is the waiting room. Someone from the team will verify you soon."))
    }
    
}
