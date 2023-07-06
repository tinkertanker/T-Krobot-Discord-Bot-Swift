//
//  ClassCreator.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//  Updated by Triston Wong on 24/3/23
//

import Foundation
import DiscordBM

class ClassCreator: SlashCommandable {
    var bot: any GatewayManager
    
    var slashCommand: Payloads.ApplicationCommandCreate {
        .init(name: "create",
              description: "Create new class channel and Notion page.",
              options: [
                .init(type: .string,
                      name: "name",
                      description: "Class name, e.g. Swift Accelerator",
                      required: true,
                      min_length: 1,
                      max_length: 1000,
                      autocomplete: false),
                .init(type: .user, name: "trainer1", description: "Add trainer for the class"),
                .init(type: .user, name: "trainer2", description: "Add trainer for the class"),
                .init(type: .user, name: "trainer3", description: "Add trainer for the class"),
                .init(type: .user, name: "trainer4", description: "Add trainer for the class"),
                .init(type: .user, name: "trainer5", description: "Add trainer for the class"),
                .init(type: .user, name: "trainer6", description: "Add trainer for the class"),
                .init(type: .user, name: "trainer7", description: "Add trainer for the class"),
                .init(type: .user, name: "trainer8", description: "Add trainer for the class"),
                .init(type: .user, name: "trainer9", description: "Add trainer for the class"),
                .init(type: .user, name: "trainer10", description: "Add trainer for the class"),
                .init(type: .user, name: "trainer11", description: "Add trainer for the class"),
                .init(type: .user, name: "trainer12", description: "Add trainer for the class"),
                .init(type: .user, name: "trainer13", description: "Add trainer for the class"),
                .init(type: .user, name: "trainer14", description: "Add trainer for the class"),
                .init(type: .user, name: "trainer15", description: "Add trainer for the class")
              ],
              default_member_permissions: [.administrator],
              type: .chatInput)
    }
    
    func sendCompletionMessages(withInteraction interaction: Interaction,
                                newClass: ClassInfo) async throws {
        
        _ = try await bot.client.updateOriginalInteractionResponse(token: interaction.token,
                                                         payload: .init(content: "🎉 Successfully created class: <#\(newClass.channelId)>!"))
        
        let welcomeMessage = "<@&\(newClass.roleId)>\n👋 Welcome to the channel for **\(newClass.name)**.\n\nNotion Page: \(newClass.notionURL)"
        
        let messageId = try await bot.client.createMessage(
                                            channelId: Snowflake(newClass.channelId),
                                            payload: .init(
                                                content: welcomeMessage
                                            ))
        
        _ = try await bot.client.pinMessage(channelId: Snowflake(newClass.channelId), messageId: messageId.decode().id)
    }
    
    func handleInteraction(_ interaction: DiscordModels.Interaction) async throws {
        var className: String?
        var trainerUserIDs: [String] = []
        
        switch interaction.data {
        case .applicationCommand(let data):
            guard let options = data.options,
                  let name = options[0].value?.asString else { return }
            
            className = name
            
            trainerUserIDs = options.compactMap { option in
                if option.name.hasPrefix("trainer") {
                    return option.value?.asString
                } else {
                    return nil
                }
            }
        default: break
        }
        
        guard let className,
              let creatorUserId = interaction.member?.user?.id else { return }
        
        _ = try await bot.client.createInteractionResponse(id: interaction.id,
                                                           token: interaction.token,
                                                           payload: .deferredChannelMessageWithSource())
        
        // converts trainnerUserIDs from String type to Snowflake Type to append creatorUserID
        var snowflakedTrainers: [Snowflake<DiscordUser>] = []
        for trainer in trainerUserIDs {
            snowflakedTrainers.append(Snowflake(trainer))
        }
        
        snowflakedTrainers.append(creatorUserId)
        
        trainerUserIDs = Array(Set(trainerUserIDs))
        
        let newClass = try await setUpClass(name: className, trainerUserIDs: snowflakedTrainers)
        
        persistenceManager.classes[newClass.roleId] = newClass
        
        try await sendCompletionMessages(withInteraction: interaction, newClass: newClass)
    }
    
    func setUpClass(name: String, trainerUserIDs: [Snowflake<DiscordUser>]) async throws -> ClassInfo {
        let role = try await createClassDiscordRole(name: name)
        
        let channel = try await createClassDiscordChannel(name: name, roleId: AnySnowflake(role.id))
        
        try await assignRoles(roleId: role.id, userIds: trainerUserIDs)
        
        let notionPage = try await createNotionPage(name: name)
        
        return ClassInfo(name: name,
                         channelId: channel.id.rawValue,
                         roleId: role.id.rawValue,
                         notionURL: notionPage.url,
                         archived: false)
    }
    
    // creates a text-channel under catagory: "classes" with specific perms to roles
    // StringBitField(rawValue: 0x0000000000000400) --> allow members to view chanel (perms)
    func createClassDiscordChannel(name: String, roleId: AnySnowflake) async throws -> DiscordChannel {
        let payload = Payloads.CreateGuildChannel(name: name,
                                                  type: DiscordChannel.Kind.guildText,
                                                  position: 0, topic: "Channel for \(name), created by T Krobot",
                                                  nsfw: false,
                                                  permission_overwrites: [
                                                    .init(id: roleId,
                                                          type: DiscordChannel.Overwrite.Kind.role,
                                                          allow: StringBitField(rawValue: 0x0000000000000400)),
                                                    .init(id: AnySnowflake(DiscordManager.Constant.Roles.everyone),
                                                          type: DiscordChannel.Overwrite.Kind.role,
                                                          deny: StringBitField(rawValue: 0x0000000000000400))
                                                  ],
                                                  parent_id: DiscordManager.Constant.Category.classesCategory)
        
        let channel = try await bot.client.createGuildChannel(guildId: DiscordManager.Constant.guildID,
            payload: payload)
        
        return try channel.decode()
    }
    
    func createClassDiscordRole(name: String) async throws -> Role {
        let rolePayload = Payloads.GuildRole(
            name: name,
            permissions: [],
            mentionable: true
        )
        let result = try await bot.client.createGuildRole(
            guildId: DiscordManager.Constant.guildID,
            payload: rolePayload)
        
        return try result.decode()
    }
    
    func assignRoles(roleId: Snowflake<Role>, userIds: [Snowflake<DiscordUser>]) async throws {
        for userId in userIds {
            _ = try await bot.client.addGuildMemberRole(guildId: DiscordManager.Constant.guildID,
                                                        userId: userId,
                                                        roleId: roleId)
        }
    }
    
    required init(bot: any GatewayManager) {
        self.bot = bot
    }
}
