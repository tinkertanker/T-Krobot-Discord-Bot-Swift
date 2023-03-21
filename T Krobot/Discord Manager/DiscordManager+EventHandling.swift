//
//  DiscordManager+EventHandling.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//

import Foundation
import DiscordBM

extension DiscordManager {
    func configureEventHandler() async {
        await bot.addEventHandler { [self] event in
            switch event.data {
            case .interactionCreate(let interaction):
                guard let data = interaction.data else { return }
                switch data {
                case .applicationCommand(let command):
                    handleIncomingSlashCommand(command,
                                               interaction: interaction)
                case .messageComponent(let component):
                    handleIncomingMessageComponent(component,
                                                   interaction: interaction)
                case .modalSubmit:
                    break
                }
            default: break
            }
        }
    }
    
    func handleIncomingMessageComponent(_ component: Interaction.MessageComponent, interaction: Interaction) {
        let id = component.custom_id.split(separator: ".").first!
        
        let manager = slashCommandManagers.first {
            ($0 as? MessageComponentable)?.customIdPrefix ?? "" == id
        } as? MessageComponentable
        
        Task {
            try await manager?.handleMessageComponent(component, interaction: interaction)
        }
    }
}
