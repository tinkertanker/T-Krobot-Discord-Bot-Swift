//
//  DiscordManager+EventHandling.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//  Edited by Triston Wong on 21/6/23

import Foundation
import DiscordBM
import Logging

extension DiscordManager {
    func handleIncomingMessageComponent(_ component: Interaction.MessageComponent, interaction: Interaction) {
        let id = component.custom_id.split(separator: ".").first!
        
        // "manager" variable is to find what class the command is from
        
        let manager = slashCommandManagers.first { item in
            if let messageComponentable = item as? MessageComponentable {
                return messageComponentable.customIdPrefix.contains(String(id))
            }
            return false
        } as? MessageComponentable
        
        print("ID recieved: \(id) from \(String(describing: manager))")
        
        Task {
            try await manager?.handleMessageComponent(component, interaction: interaction)
        }
    }
}
