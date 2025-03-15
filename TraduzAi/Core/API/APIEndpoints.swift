//
//  APIEndpoints.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import Foundation

enum APIEndpoint {
    case translateText
    case openAIChat
    
    var url: URL? {
        switch self {
        case .translateText:
            return URL(string: "http://3.145.141.213:1880/translate-text")
        case .openAIChat:
            return URL(string: "https://api.openai.com/v1/chat/completions")
        }
    }
    
    var method: String {
        switch self {
        case .translateText, .openAIChat:
            return "POST"
        }
    }
}
