//
//  ClassCreator.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//

import Foundation
import DiscordBM

class ClassCreator: SlashCommandable {
    let command = "create"
    
    var bot: DiscordGateway.GatewayManager
    
    func createSlashCommand() -> RequestBody.ApplicationCommandCreate {
        .init(name: command,
              description: "Create new class channel and Notion page.",
              options: [
                .init(type: .string, name: "name", description: "Class name, e.g. Swift Accelerator", required: true, min_length: 1, max_length: 5, autocomplete: false)
              ],
              default_member_permissions: [.administrator],
              type: .chatInput)
    }
    
    func handleInteraction(_ interaction: DiscordModels.Interaction) async throws {
        
    }
    
    required init(bot: GatewayManager) {
        self.bot = bot
    }
}
