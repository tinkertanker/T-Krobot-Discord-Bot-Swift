//
//  GatewayEventHandler.swift
//  T Krobot
//
//  Created by Triston Wong on 22/6/23.
//

import DiscordBM
import Logging
struct EventHandler: GatewayEventHandler {
    let event: Gateway.Event
    
    func onInteractionCreate(_ interaction: Interaction) async {
        await interactionHandler(event: interaction)
    }
}

func interactionHandler(event: Interaction) async {
    guard let data = event.data else { return }
    
    switch data {
    case .applicationCommand(let command) where event.type == .applicationCommand:
        discordManager.handleIncomingSlashCommand(command, interaction: event)

    case .messageComponent(let component) where event.type == .messageComponent:
        discordManager.handleIncomingMessageComponent(component, interaction: event)

    case .modalSubmit:
        break
    default:
        print("yup no")
    }
}
