//
//  CFIClose.swift
//  T Krobot
//
//  Created by Triston Wong on 28/6/23.
//
import Foundation
import DiscordBM

class CFIclose: SlashCommandable {

    var slashCommand: Payloads.ApplicationCommandCreate {
        // discord slash-command call
        .init(name: "close-call",
              description: "close CFI call",
              options: [
                .init(type: .string, name: "message-id", description: "copy paste message id of CFI", required: true)
              ],
              default_member_permissions: [.administrator],
              type: .chatInput
        )
    }

    func handleInteraction(_ interaction: DiscordModels.Interaction) async throws {
        
        // isolates messageId from call
        
        let messageIdGiven: String?
        
        switch interaction.data {
        case .applicationCommand(let command):
            messageIdGiven = command.options?.first?.value!.asString
        default:
            messageIdGiven = ""
        }
        
        // do {} to ensure that messageId given is avaliable for CFI text channel. Otherwise, print errors
        do {
    
            let msgContent = try await bot.client.getMessage(
                channelId: DiscordManager.Constant.Channel.callForInstructor,
                messageId: MessageSnowflake(messageIdGiven!)
                                                            ).decode()
            
            // intakes the content of message based on ID and outputs the new message to replace it
            let msgToPrint = updateMessage(msgContent: msgContent.content)
            
            _ = try await bot.client.updateMessage(channelId: DiscordManager.Constant.Channel.callForInstructor,
                                                   messageId: MessageSnowflake(messageIdGiven!),
                                                   payload: Payloads.EditMessage(
                                                    content: msgToPrint))
            
            _ = try await bot.client.createInteractionResponse(id: interaction.id,
                                                               token: interaction.token,
                                                               payload: .channelMessageWithSource(
                                                                .init(content: "CFI closed",
                                                                      flags: [.ephemeral]
                                                                )))
            
        } catch {
            print("msg failure ")
            
            let errorMsg = "Failure in input / code. Ensure message ID is properly copied"
            
            _ = try await bot.client.createInteractionResponse(id: interaction.id,
                                                               token: interaction.token,
                                                               payload: .channelMessageWithSource(
                                                                .init(content: errorMsg,
                                                                      flags: [.ephemeral]
                                                                )))
        }
        
    }
    
    func updateMessage(msgContent: String) -> String {
        // isolates content values from message
        let msgArray = msgContent.split { $0 == "\n" || $0 == "\r\n" }.map(String.init)
        
        let titleContent = msgArray[0].substring(from: 2)
        let whatContent = msgArray[1].substring(from: 9)
        let whenContent = msgArray[2].substring(from: 9)
        let whereContent = msgArray[3].substring(from: 10)
        let whoContent = msgArray[4].substring(from: 8)
        let otherContent = msgArray[5].substring(from: 19)
        
        // creates new message
        let newMsg = """
```diff
- CFI Closed
\(titleContent)
What: \(whatContent)
When: \(whenContent)
Where: \(whereContent)
Who: \(whoContent)
Other Comments: \(otherContent)
```
"""
        return newMsg
        
    }

    var bot: any GatewayManager

    required init(bot: any GatewayManager) {
        self.bot = bot
    }
}
