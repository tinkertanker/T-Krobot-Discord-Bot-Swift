//
//  Verification.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 20/3/23.
//  Edited by Triston Wong on 21/3/23

import Foundation
import DiscordBM

class Verification: SlashCommandable, MessageComponentable {
    var customIdPrefix = ["trainer", "tinker", "eject"]
    
    var nameTemp: String = "temp"
    
    var bot: any DiscordGateway.GatewayManager
    
    var slashCommand: Payloads.ApplicationCommandCreate {
        // discord slash-command call
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
        nameTemp = name
     
        // creates a verification message on the verificaiton discord text channel
        let message = "<@\(user.id.rawValue)> just joined the server. \n If you recognise the user, select **Trainer** or **Tinkertanker** and they will be let in."
        
        _ = try await bot.client.createMessage(
            channelId: DiscordManager.Constant.Channel.verifications,
            payload: .init(content: "<@&\(DiscordManager.Constant.Roles.verifiers.rawValue)>",
                    embeds: [Embed(title: "\(name) Joined", description: message)],
                    components: [.init(components: [
                        .button(.init(
                            style: .primary,
                            label: "Verify Trainer",
                            custom_id: "trainer.\(user.id)")),

                        .button(.init(
                            style: .success,
                            label: "Verify Tinkertanker",
                            custom_id: "tinker.\(user.id)")),

                        .button(.init(
                            style: .danger,
                            label: "Eject",
                            custom_id: "eject.\(user.id)"))
                            ])]
                          ))
        
        // modifies user's name from /welcome slash-command
        _ = try await bot.client.updateGuildMember(guildId: DiscordManager.Constant.guildID,
                                                   userId: user.id,
                                                   payload: .init(nick: name))
        
        // message response for user (ephemeral)
        let verificationMsg = "A verification request has been submitted. Someone from the team will approve it soon."
 
        // sends messge response
        _ = try await bot.client.createInteractionResponse(id: interaction.id,
                                                            token: interaction.token,
                                                           payload: .channelMessageWithSource(.init(
                                                                content: verificationMsg,
                                                                flags: [.ephemeral]
                                                           )))
        
    }
    
    func handleMessageComponent(_ component: DiscordModels.Interaction.MessageComponent,
                                interaction: DiscordModels.Interaction) async throws {
        let customId = component.custom_id
        guard let buttonInput = customId.split(separator: ".").first,
              let userId = customId.split(separator: ".").last else { return }
        
        var role: Snowflake<Role> = ""
        
        if String(buttonInput) == "trainer" {
            role = DiscordManager.Constant.Roles.trainer
        } else if String(buttonInput) == "tinker" {
            role = DiscordManager.Constant.Roles.tinkerTanker
        }
        
        print("Role: \(role)")
        print("Discord User: \(String(userId))")
        
        if role != "" {
            try await addVerificationRole(userId: UserSnowflake(String(userId).substring(with: 24..<43)), roleId: role)
            try await newPrivateChannel(userId: AnySnowflake(String(userId).substring(with: 24..<43)))
            try await deleteVerificationMessage(interaction: interaction)
            
            _ = try await self.bot.client.createInteractionResponse(id: interaction.id,
                                                                    token: interaction.token,
                                                                    payload: .deferredUpdateMessage())
        } else {
            try await deleteVerificationMessage(interaction: interaction)
            
            _ = try await self.bot.client.createInteractionResponse(id: interaction.id,
                                                                    token: interaction.token,
                                                                    payload: .deferredUpdateMessage())
        }
    }
    
    required init(bot: any GatewayManager) {
        self.bot = bot
    }
    
    func addVerificationRole(userId: Snowflake<DiscordUser>, roleId: Snowflake<Role>) async throws {
        // assigns user role based on verfication input
        _ = try await bot.client.addGuildMemberRole(
            guildId: DiscordManager.Constant.guildID,
            userId: userId,
            roleId: roleId
        )
    }
    
    func newPrivateChannel(userId: AnySnowflake) async throws {
        
        let userName: String = try await bot.client.getUser(id: UserSnowflake(userId)).decode().username

        // creates text channel with them under "private messages" catagory
        let channel = try await bot.client.createGuildChannel(
            guildId: DiscordManager.Constant.guildID,
            payload: Payloads.CreateGuildChannel(
                name: nameTemp,
                type: DiscordChannel.Kind.guildText,
                position: 0, topic: "Do not remove me ! (／°ロ°)／ Private Channel for \(nameTemp), created by T Krobot. Username: \(String(userName))",
                nsfw: false, permission_overwrites: [
                    .init(id: userId,
                          type: DiscordChannel.Overwrite.Kind.member,
                          allow: StringBitField(rawValue: 0x0000000000000400)),
                    .init(id: AnySnowflake(DiscordManager.Constant.Roles.everyone),
                          type: DiscordChannel.Overwrite.Kind.role,
                          deny: StringBitField(rawValue: 0x0000000000000400))
                    ],
                parent_id: DiscordManager.Constant.Category.privateMsg))
        
        let channelLocation = try channel.decode()
        
        _ = try await bot.client.createMessage(
            channelId: channelLocation.id,
            payload: .init(content: "<@\(userId.rawValue)>",
                            embeds: [Embed(title: "Hello! This is automated message ᕕ( ᐛ )ᕗ",
                            description: message)]))
    }
    
    func deleteVerificationMessage(interaction: Interaction) async throws {
        // removes verification msg
        guard let message = interaction.message else { return }
        _ = try await bot.client.deleteMessage(channelId: message.channel_id, messageId: message.id)
    }
    
    // creates a really long welcome message (info dump) on private text channel with user
    let message = """
Please note: Do not change the channel topic. It is essential for T Krobot and our admins.

* To get started, just keep an eye out on ⁠<#\(DiscordManager.Constant.Channel.callForInstructor.rawValue)> for classes. When interested, just reply in a thread that you can make it and we'll endeavour to confirm ASAP.
* This channel is private to you and the admins (anyone in red in the sidebar — usually Tinkertanker staff).

* Send questions here, or if really private, can WhatsApp YJ / whoever you know.
* If you're new to Discord, we have some tips for managing things in ⁠<#\(DiscordManager.Constant.Channel.welcomeDiscord.rawValue)>
* Feel free to chat with us or anyone in <#\(DiscordManager.Constant.Channel.chat.rawValue)>
* When we confirm a class, we set up chat channels for them.
* There are topics channels you can wander in to as well to discuss, and questions channels (like ⁠<#\(DiscordManager.Constant.Channel.adminQuestions.rawValue)>) to ask and answer questions.

* Do note the requirements for each class. In particular, school classes need MOE registration, which takes 6-8 weeks (it’s a security clearance).
* If you’d like to learn something new from our curriculum, we can get you access to our slides.
* Otherwise, you can learn a lot using Udemy Business! See https://nlbsg.udemy.com/.
* You’re also welcome to learn something new by assisting for it — but please make sure to go in prepared!

On payment (see ⁠<#\(DiscordManager.Constant.Channel.adminQuestions.rawValue)> for more details)

* Once an engagement is confirmed, we’ll add you to our calendaring system, which will send you a schedule invite.
* Do take note that the dates, times, and durations are correct, as these will then auto-populate your pay for the following pay cycle."
* Pay comes in around the end of the following month, by bank transfer. As a contractor, you should generate an invoice; we’re just automating things through our payroll system.

* Once you run your first class with us, please provide YJ the following information to get started:
(a) Full name
(b) NRIC number (or, if you’d rather not provide, just confirm that you are eligible to work in Singapore, i.e. being a citizen, PR, or your student pass allows for it)
(c) Email for payroll system to reach you

* We will set something up, then ask you to fill in a particulars form with your bank account info
* From there on, pay will be sent after the 30th of the following month, together with a “payslip” detailing the name of the class.
For other claims, please use https://tk.sg/timesheet.

Let us know if you have any questions at all!

From: T Krobot (message written by YJ)
"""
}
