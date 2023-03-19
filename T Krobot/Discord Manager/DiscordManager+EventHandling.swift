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
                case .messageComponent(_):
                    break
                case .modalSubmit(_):
                    break
                }
            default: break
            }
        }
    }
}
