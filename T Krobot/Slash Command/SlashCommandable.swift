//
//  SlashCommandable.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 18/3/23.
//

import Foundation
import DiscordBM

protocol SlashCommandable {
    var command: String { get }
    var bot: GatewayManager { get set }
    
    func handleInteraction(_ interaction: Interaction) async throws
    func createSlashCommand() -> RequestBody.ApplicationCommandCreate
    
    init(bot: GatewayManager)
}
