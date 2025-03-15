//
//  OpenAIModels.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import Foundation

struct OpenAIResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
    let error: OpenAIError?
}

struct OpenAIError: Decodable {
    let message: String
    let type: String
}

struct RefineResponse: Codable {
    let refinedText: String
    let error: String?
}
