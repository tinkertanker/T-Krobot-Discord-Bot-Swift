////
////  JoinChannels.swift
////  T Krobot
////
////  Created by Jia Chen Yee on 20/3/23.
////
//
// This command is currently uninstalled and not avalible
//
// import Foundation
// import DiscordBM
//
// class JoinChannels: SlashCommandable, MessageComponentable {
//    var customIdPrefix: [String] = ["join"]
//
//    func handleMessageComponent(_ component: Interaction.MessageComponent,
//                                interaction: Interaction) async throws {
//        guard let userId = component.custom_id.split(separator: ".").last,
//              let roleId = component.values?.first,
//              let classInfo = persistenceManager.classes[roleId] else { return }
//
//        _ = try await bot.client.addGuildMemberRole(guildId: DiscordManager.Constant.guildID,
//                                                    userId: Snowflake<DiscordUser>(String(userId)),
//                                                    roleId: Snowflake<Role>(roleId))
//
//        _ = try await bot.client.createInteractionResponse(id: interaction.id,
//                                                           token: interaction.token,
//                                                           payload: .deferredUpdateMessage())
//
//        _ = try await bot.client.createMessage(channelId: Snowflake<DiscordChannel>(classInfo.channelId),
//                                               payload: .init(content: "👋 <@\(userId)> joined the channel"))
//    }
//
//    var bot: any GatewayManager
//
//    var slashCommand: Payloads.ApplicationCommandCreate {
//        .init(name: "join",
//              description: "Join a class.",
//              default_member_permissions: [.sendMessages],
//              type: .chatInput)
//    }
//
//    func handleInteraction(_ interaction: DiscordModels.Interaction) async throws {
//
//        guard let user = interaction.member?.user else { return }
//
//        // work in progress
////        let nonArchivedClasses = persistenceManager.classes.values.compactMap { classInfo in
////            classInfo.archived ? nil : Interaction.ActionRow.SelectMenu.Option(label: classInfo.name,
////                                                                               value: classInfo.roleId)
////        }
////
////        let component = [
////            Interaction.ActionRow.Component.stringSelect(.init(custom_id: "join.\(user.id)",
////                                                               options: nonArchivedClasses,
////                                                               placeholder: "Select a class"))
////        ]
////
////        _ = try? await bot.client.createInteractionResponse(id: interaction.id,
////                                                            token: interaction.token,
////                                                            payload: .channelMessageWithSource(
////                                                                .init(content: "Channel to join: ",
////                                                                      flags: [.ephemeral],
////                                                                      components: [
////                                                                              .init(components: component)
////                                                                            ]))
////                                                            )
//    }
//
//    required init(bot: any GatewayManager) {
//        self.bot = bot
//    }
// }
