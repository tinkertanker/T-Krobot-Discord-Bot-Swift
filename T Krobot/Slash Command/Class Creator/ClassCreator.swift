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
                .init(type: .string, name: "name", description: "Class name, e.g. Swift Accelerator", required: true, min_length: 1, max_length: 5, autocomplete: false)
              ],
              default_member_permissions: [.administrator],
              type: .chatInput)
    }
    
    func handleInteraction(_ interaction: DiscordModels.Interaction) async throws {
        
//        let notionPage = try await createNotionPage(name: <#String#>, discordInfo: <#String#>)
    }
    
    required init(bot: GatewayManager) {
        self.bot = bot
    }
}
