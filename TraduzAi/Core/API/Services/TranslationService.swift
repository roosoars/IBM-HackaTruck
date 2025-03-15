//
//  TranslationService.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import Foundation
import Combine

class TranslationService {
    static let shared = TranslationService()
    
    func translateText(sourceLanguage: String, targetLanguage: String, text: String) -> AnyPublisher<TranslationResponse, Error> {
        let parameters: [String: String] = [
            "sourceLanguage": sourceLanguage,
            "targetLanguage": targetLanguage,
            "text": text
        ]
        
        return NetworkService.shared.performRequest(endpoint: .translateText, parameters: parameters)
    }
}
