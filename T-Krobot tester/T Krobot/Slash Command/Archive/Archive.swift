//
//  Archive.swift
//  T Krobot
//
//  Created by Triston Wong on 20/6/23.
//

import Foundation
import DiscordBM

class Archive: SlashCommandable, MessageComponentable {
    var customIdPrefix = ["confirm", "cancel"]
    
    var bot: any GatewayManager
    
    var slashCommand: Payloads.ApplicationCommandCreate {
        // discord slash-command to call
        .init(name: "archive",
              description: "Archive an active class.",
              default_member_permissions: [.administrator],
              type: .chatInput)
    }
    
    func handleInteraction(_ interaction: Interaction) async throws {
        guard let channelId = interaction.channel_id else { return }
        
        // checks if the class is under the "Active Classes" Catagory
        guard let classInfo = persistenceManager.classes.values.first(where: {
            Snowflake($0.channelId) == channelId
        }),
              classInfo.archived == false
        else {
            
            let message = "`/archive` is not supported in this channel. Use it in a class channel."
        
            _ = try await bot.client.createInteractionResponse(id: interaction.id,
                                                                       token: interaction.token,
                                                               payload: .channelMessageWithSource(.init(
                                                                content: message,
                                                                flags: [.ephemeral]))
                                                               )
            return
        }
        
        let confirmation = "Are you sure you want to archive this active class?"
 
        // sends messge response
        _ = try await bot.client.createMessage(channelId: channelId,
                                               payload: .init(
            content: confirmation,
            components: [.init(components: [
                .button(.init(
                    style: .primary,
                    label: "Confirm",
                    custom_id: "confirm.\(classInfo.roleId)")),
                
                    .button(.init(
                        style: .danger,
                        label: "Cancel",
                        custom_id: "cancel.\(classInfo.roleId)"))
            ])]
       ))
        
    // message response for user (ephemeral)
    let verificationMsg = "Please read the below: "

    // sends messge response
    _ = try await bot.client.createInteractionResponse(id: interaction.id,
                                                        token: interaction.token,
                                                       payload: .channelMessageWithSource(.init(
                                                        content: verificationMsg,
                                                        flags: [.ephemeral])))
    
    }
    
    func handleMessageComponent(_ component: Interaction.MessageComponent,
                                interaction: Interaction) async throws {
        let customId = component.custom_id
        guard let input = customId.split(separator: ".").first,
              let roleId = customId.split(separator: ".").last,
              let channel = persistenceManager.classes[String(roleId)],
              let msgId = interaction.channel?.last_message_id
        else { return }
        
        if String(input) == "confirm" {
            _ = try await bot.client.updateGuildChannel(
                id: ChannelSnowflake(channel.channelId),
                payload: DiscordModels.Payloads.ModifyGuildChannel(
                    permission_overwrites: [
                        .init(id: AnySnowflake(String(roleId)),
                              type: DiscordChannel.Overwrite.Kind.role,
                              allow: StringBitField(rawValue: 0x0000000000000400)),
                        .init(id: AnySnowflake(DiscordManager.Constant.Roles.everyone),
                              type: DiscordChannel.Overwrite.Kind.role,
                              deny: StringBitField(rawValue: 0x0000000000000400))
                    ],
                    parent_id: DiscordManager.Constant.Category.archivedCategory))
            
            _ = try await bot.client.createMessage(
                channelId: ChannelSnowflake(channel.channelId),
                payload: .init(
                    content: "<@&\(String(roleId))>",
                    embeds: [Embed(title: "Automated Message: ",
                                   description: "This channel is archived! Thank you all for your work! (/◕ヮ◕)/")]
                ))

            persistenceManager.classes[String(roleId)]?.archived = true
            
            print(channel.notionURL)

            let notionPageKey = channel.notionURL.substring(from: (channel.notionURL.count - 32))
            
            do {
                let updateResult = try await updateNotionPageActiveStatus(pageKey: notionPageKey)
                print("Notion page updated successfully. URL: \(updateResult.url)")
            } catch {
                print("Error updating Notion page: \(error)")
            }
        }
        
        // deletes interactive message
        _ = try await bot.client.deleteMessage(channelId: ChannelSnowflake(channel.channelId), messageId: msgId)
        
        _ = try await self.bot.client.createInteractionResponse(id: interaction.id,
                                                                token: interaction.token,
                                                                payload: .deferredUpdateMessage())

    }
    
    required init(bot: any GatewayManager) {
        self.bot = bot
    }
}
