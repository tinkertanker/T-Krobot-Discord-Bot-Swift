//
//  DatabaseModifier+Notion.swift
//  T Krobot
//
//  Created by Triston Wong on 27/6/23.
//

import Foundation

extension Archive {
    func updateNotionPageActiveStatus(pageKey: String) async throws -> NotionPageModificationResult {
        
        let url = URL(string: "https://api.notion.com/v1/pages/\(pageKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        
        request.addValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.addValue("Bearer secret_3tUGhkguByzGdYOZmxmT4dQB23GIPhfidyY9JPXIszS",
                         forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "properties": [
                "Active": [
                    "checkbox": false
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
                
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse,
              200...299 ~= response.statusCode else {
            _ = response as? HTTPURLResponse
            throw NotionError.httpError
        }
        
        print("Successfully updated Notion page")
        
        return try JSONDecoder().decode(NotionPageModificationResult.self, from: data)
    }
}

struct NotionPageModificationResult: Codable {
    var url: String
}
