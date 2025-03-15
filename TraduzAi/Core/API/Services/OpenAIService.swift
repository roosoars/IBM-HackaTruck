//
//  OpenAIService.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import Foundation
import Combine

class OpenAIService {
    static let shared = OpenAIService()
    private let apiKey = "YOUR API"
    
    func dictionaryDefinition(prompt: String) -> AnyPublisher<DictionaryResponse, Error> {
        let parameters: [String: Any] = [
            "model": "gpt-4o",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 1000,
            "temperature": 0.2
        ]
        
        let headers = ["Authorization": "Bearer \(apiKey)"]
        
        return NetworkService.shared.performRequest(endpoint: .openAIChat, parameters: parameters, headers: headers)
            .map { (response: OpenAIResponse) in
                if let error = response.error {
                    return DictionaryResponse(word: "", definition: "", error: error.message)
                }
                let definition = response.choices.first?.message.content ?? "No response"
                return DictionaryResponse(word: "", definition: definition, error: nil)
            }
            .eraseToAnyPublisher()
    }
    
    func refineText(language: String, text: String) -> AnyPublisher<RefineResponse, Error> {
        let prompt = "Reescreva a seguinte frase em \(language) usando a pontuação e conserte caso precise de corrigimentos gramaticais e de ortografia, mas somente me volte o texto finalizado, nunca VOLTE sua opinião ou dúvida e tente entender se o texo é uma pergunta ou uma resposta: \(text)"
        
        let parameters: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 1000,
            "temperature": 0.2
        ]
        
        let headers = ["Authorization": "Bearer \(apiKey)"]
        
        return NetworkService.shared.performRequest(endpoint: .openAIChat, parameters: parameters, headers: headers)
            .map { (response: OpenAIResponse) in
                if let error = response.error {
                    return RefineResponse(refinedText: "", error: error.message)
                }
                let refined = response.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return RefineResponse(refinedText: refined, error: nil)
            }
            .eraseToAnyPublisher()
    }
}
