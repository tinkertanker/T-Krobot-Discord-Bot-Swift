//
//  ClassCreator+Notion.swift
//  T Krobot
//
//  Created by Jia Chen Yee on 19/3/23.
//  Edited by Triston Wong on 20/3/23
//

import Foundation

extension ClassCreator {
    func createNotionPage(name: String) async throws -> NotionPageCreationResult {
        
        let currentDate = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        let dateGiven: String = formatter.string(from: currentDate)
        
        let databaseId = "dfd62a763df045dc82d05a37f35349ae"
        let url = URL(string: "https://api.notion.com/v1/pages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.addValue("Bearer secret_3tUGhkguByzGdYOZmxmT4dQB23GIPhfidyY9JPXIszS",
                         forHTTPHeaderField: "Authorization")
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
                "Date Created": [
                    "rich_text": [
                        [
                            "text": [
                                "content": dateGiven
                            ]
                        ]
                    ]
                ] as [String: Any]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
    
        guard let response = response as? HTTPURLResponse,
              200...299 ~= response.statusCode else {
            _ = response as? HTTPURLResponse
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
