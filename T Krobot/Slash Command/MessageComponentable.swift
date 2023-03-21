//
//  MessageComponentable.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 21/3/23.
//

import Foundation
import DiscordBM

protocol MessageComponentable {
    var customIdPrefix: String { get }
    
    func handleMessageComponent(_ component: Interaction.MessageComponent, interaction: Interaction) async throws
}
