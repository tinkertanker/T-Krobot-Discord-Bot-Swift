//
//  ClassCreator+Notion.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//

import Foundation

extension ClassCreator {
    func createNotionPage(name: String, discordInfo: String) async throws -> NotionPageCreationResult {
        let databaseId = "64ec0317d92c47ecb19fec1e78a8a6c7"
        let url = URL(string: "https://api.notion.com/v1/pages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.addValue("Bearer \(keys.notionKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "parent": [
                "database_id": databaseId
            ],
            "properties": [
                "Name": [
                    "title": [
                        [
                            "text": [
                                "content": name
                            ]
                        ]
                    ]
                ],
                "Active": [
                    "checkbox": true
                ],
                "DiscordInfo": [
                    "rich_text": [
                        [
                            "text": [
                                "content": discordInfo
                            ]
                        ]
                    ]
                ]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse,
              200...299 ~= response.statusCode else {
            throw NotionError.httpError
        }
        
        print("Successfully created Notion page")
        
        return try JSONDecoder().decode(NotionPageCreationResult.self, from: data)
    }
}

struct NotionPageCreationResult: Codable {
    var url: String
}

enum NotionError: Error {
    case httpError
}
