//
//  DiscordManager+SlashCommands.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//

import Foundation
import DiscordBM

extension DiscordManager {
    func configureCommands() async {
        for manager in slashCommandManagers {
            let slashCommand = manager.slashCommand
            
            let result = try? await bot.client.createApplicationCommand(payload: slashCommand)
                
//          command-slash the code below if you accidentally create "fake commands" and run. Unslash and run again.
//          this "resets" commands 
//            do {
//                try await bot.client
//                    .bulkSetApplicationCommands(payload: [slashCommand])
//                    .guardSuccess() /// Throw an error if not successful
//            } catch {
//                print("oop")
//            }
            print(result?.httpResponse as Any)
        }
    }
    
    func handleIncomingSlashCommand(_ command: Interaction.ApplicationCommand,
                                    interaction: Interaction) {
        Task {
            if let targetManager = slashCommandManagers.first(where: { $0.name == command.name }) {
                try await targetManager.handleInteraction(interaction)
            }
        }
    }
    
    func purgeAllCommands() async throws {
        let commands = try await bot.client.listApplicationCommands(appId: "1118484363412254722").decode()
        for command in commands {
            _ = try await bot.client.deleteApplicationCommand(commandId: command.id)
        }
    }
}
