//
//  SlashCommandable.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 18/3/23.
//

import Foundation
import DiscordBM

protocol SlashCommandable {
    var name: String { get }
    
    var slashCommand: Payloads.ApplicationCommandCreate { get }
    var bot: any GatewayManager { get set }
    
    func handleInteraction(_ interaction: Interaction) async throws
    
    init(bot: any GatewayManager)
}

extension SlashCommandable {
    var name: String {
        slashCommand.name
    }
}
