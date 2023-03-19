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
    
    var slashCommand: RequestBody.ApplicationCommandCreate { get }
    var bot: GatewayManager { get set }
    
    func handleInteraction(_ interaction: Interaction) async throws
    
    init(bot: GatewayManager)
}

extension SlashCommandable {
    var name: String {
        slashCommand.name
    }
}
