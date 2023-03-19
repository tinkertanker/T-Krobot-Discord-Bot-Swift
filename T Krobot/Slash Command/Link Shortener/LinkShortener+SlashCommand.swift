//
//  LinkShortener+SlashCommand.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//

import Foundation
import DiscordBM

extension LinkShortener {
    func createSlashCommand() -> RequestBody.ApplicationCommandCreate {
        RequestBody.ApplicationCommandCreate(name: command,
                                             description: "Create tk.sg links.",
                                             options: [
                                                .init(type: .string, name: "suffix", description: "tk.sg/what?", required: true, min_length: 1, max_length: 100, autocomplete: false),
                                                .init(type: .string, name: "link", description: "Long link", required: true, min_length: 1, max_length: 1000, autocomplete: false)
                                             ],
                                             default_member_permissions: [.administrator],
                                             type: .chatInput)
    }
    
    func handleInteraction(_ interaction: Interaction) async throws {
        var shortLinkResult: ShortLinkResult?
        
        switch (interaction.data) {
        case .applicationCommand(let data):
            guard let options = data.options,
                  options.count == 2,
                  let suffix = options[0].value?.asString,
                  let longURL = options[1].value?.asString else { return }
            
            shortLinkResult = await shorten(originalLink: longURL, short: suffix)
        default: break
        }
        
        if let shortLinkResult {
            _ = try await bot.client.createInteractionResponse(id: interaction.id,
                                                               token: interaction.token,
                                                               payload: .init(type: .channelMessageWithSource,
                                                                              data: .init(content: "Successfully shortened link: \(shortLinkResult.shortURL)")))
        } else {
            _ = try await bot.client.createInteractionResponse(id: interaction.id,
                                                               token: interaction.token,
                                                               payload: .init(type: .channelMessageWithSource,
                                                                              data: .init(content: "Could not shorten link", flags: [.ephemeral])))
        }
    }
}
