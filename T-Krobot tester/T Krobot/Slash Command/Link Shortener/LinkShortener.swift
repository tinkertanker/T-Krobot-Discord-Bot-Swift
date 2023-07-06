//
//  LinkShortener.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 18/3/23.
//

import Foundation
import DiscordBM

class LinkShortener: SlashCommandable {
    var bot: any GatewayManager
    
    required init(bot: any GatewayManager) {
        self.bot = bot
    }
    
    func shorten(originalLink: String, short: String) async -> ShortLinkResult? {
        // Create URL
        guard let url = URL(string: "https://api.short.io/links") else {
            fatalError("Invalid URL")
        }
        
        // Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers
        request.setValue("pk_duUyVxCvKSJo1l0Y", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        // Set request body
        let requestBody = """
{
  "tags": [
    "tktrainers"
  ],
  "domain": "tk.sg",
  "originalURL": "\(originalLink)",
  "path": "\(short)"
}
"""
        
        request.httpBody = requestBody.data(using: .utf8)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            
            let shortLinkResult = try JSONDecoder().decode(ShortLinkResult.self, from: data)
            
            return shortLinkResult
        } catch {
            return nil
        }
    }
}
