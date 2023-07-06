//
//  CFI.swift
//  T Krobot
//
//  Created by Triston Wong on 27/6/23.
//

import Foundation
import DiscordBM

class CallingInstructors: SlashCommandable {
    
    var bot: any GatewayManager
    
    var slashCommand: Payloads.ApplicationCommandCreate {
        // discord slash-command call
        .init(name: "call-instructors",
              description: "Trainers Assemble!",
              options: [
                .init(type: .string,
                      name: "title",
                      description: "Main Caption",
                      required: true),
                .init(type: .string,
                      name: "what",
                      description: "insert details",
                      required: true),
                .init(type: .string,
                      name: "when",
                      description: "Time & Date",
                      required: true),
                .init(type: .string,
                      name: "where",
                      description: "Location",
                      required: true),
                .init(type: .string,
                      name: "who",
                      description: "Manpower Required",
                      required: true),
                .init(type: .string,
                      name: "other",
                      description: "insert comments here",
                      required: false)
              ],
              default_member_permissions: [.administrator],
              type: .chatInput)
    }
    
    func handleInteraction(_ interaction: Interaction) async throws {
        var titleContent: String = ""
        var whatContent: String = ""
        var whenContent: String = ""
        var whereContent: String = ""
        var whoContent: String = ""
        var otherContent: String = ""
        
        // isolate each value inputed from the slash command (title, who, etc)  
        switch interaction.data {
        case .applicationCommand(let data):
            guard let options = data.options else { return }
            
            let optionValue = options.compactMap {option in
                return option.value?.asString
            }
            
            titleContent = optionValue[0]
            whatContent = optionValue[1]
            whenContent = optionValue[2]
            whereContent = optionValue[3]
            whoContent = optionValue[4]
            
            if optionValue.count == 6 {
                otherContent = optionValue[5]
            } else {
                otherContent = "Nill"
            }
            
        default: break
        }
        
        // message response for user (ephemeral)
        let callMsg = """
# \(titleContent)
**What:** \(whatContent)
**When:** \(whenContent)
**Where:** \(whereContent)
**Who:** \(whoContent)
**Other Comments:** \(otherContent)
"""

        // sends messge response
        _ = try await bot.client.createInteractionResponse(id: interaction.id,
                                                            token: interaction.token,
                                                           payload: .channelMessageWithSource(
                                                            .init(
                                                                content: "Creating Call on CFI channel: ",
                                                                flags: [.ephemeral]
                                                            )))
        
        let messageId = try await bot.client.createMessage(channelId: DiscordManager.Constant.Channel.callForInstructor,
                                               payload: Payloads.CreateMessage.init(
                                                content: callMsg
                                               ))
        
        _ = try await bot.client.createThreadFromMessage(channelId: DiscordManager.Constant.Channel.callForInstructor,
                                                         messageId: messageId.decode().id,
                                                         payload: Payloads.CreateThreadFromMessage.init(
                                                            name: titleContent))
    }
    
    required init(bot: any GatewayManager) {
        self.bot = bot
    }
}
