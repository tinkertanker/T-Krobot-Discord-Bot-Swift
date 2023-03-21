//
//  ClassCreator.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//

import Foundation
import DiscordBM

class ClassCreator: SlashCommandable {
    var bot: DiscordGateway.GatewayManager
    
    var slashCommand: RequestBody.ApplicationCommandCreate {
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
        _ = try await bot.client.editInteractionResponse(token: interaction.token,
                                                         payload: .init(content: "🎉 Successfully created class: <#\(newClass.channelId)>!"))
        
        let welcomeMessage = "<@&\(newClass.roleId)>\n👋 Welcome to the channel for **\(newClass.name)**.\n\nNotion Page: \(newClass.notionURL)"
        
        _ = try await bot.client.createMessage(channelId: newClass.channelId,
                                               payload: .init(content: welcomeMessage))
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
                                                           payload: .init(type: .deferredChannelMessageWithSource))
        
        trainerUserIDs.append(creatorUserId)
        
        trainerUserIDs = Array(Set(trainerUserIDs))
        
        let newClass = try await setUpClass(name: className, trainerUserIDs: trainerUserIDs)
        
        persistenceManager.classes[newClass.roleId] = newClass
        
        try await sendCompletionMessages(withInteraction: interaction, newClass: newClass)
    }
    
    func setUpClass(name: String, trainerUserIDs: [String]) async throws -> ClassInfo {
        let role = try await createClassDiscordRole(name: name)
        
        let channel = try await createClassDiscordChannel(name: name, roleId: role.id)
        
        try await assignRoles(roleId: role.id, userIds: trainerUserIDs)
        
        let notionPage = try await createNotionPage(name: name, discordInfo: channel.id)
        
        return ClassInfo(name: name, channelId: channel.id, roleId: role.id, notionURL: notionPage.url, archived: false)
    }
    
    func createClassDiscordChannel(name: String, roleId: String) async throws -> DiscordChannel {
        let payload = RequestBody.CreateGuildChannel(name: name,
                                                     type: 0,
                                                     topic: "Channel for \(name)",
                                                     position: 0,
                                                     parent_id: DiscordManager.Constant.Category.classesCategory,
                                                     nsfw: false,
                                                     permission_overwrites: [
                                                        .init(id: roleId, type: 0, allow: "\(1 << 10)"),
                                                        .init(id: DiscordManager.Constant.Role.everyone,
                                                              type: 0, deny: "\(1 << 10)")
                                                     ])
        let channel = try await bot.client.createGuildChannel(guildId: DiscordManager.Constant.guildId,
                                                              payload: payload)
        
        return try channel.decode()
    }
    
    func createClassDiscordRole(name: String) async throws -> Role {
        let payload = RequestBody.CreateGuildRole(name: name, permissions: [], mentionable: true)
        
        let result = try await bot.client.createGuildRole(guildId: DiscordManager.Constant.guildId,
                                                          payload: payload)
        
        return try result.decode()
    }
    
    func assignRoles(roleId: String, userIds: [String]) async throws {
        for userId in userIds {
            _ = try await bot.client.addGuildMemberRole(guildId: DiscordManager.Constant.guildId,
                                                        userId: userId,
                                                        roleId: roleId)
        }
    }
    
    required init(bot: GatewayManager) {
        self.bot = bot
    }
}
