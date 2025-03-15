//
//  TranslationModels.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import Foundation

struct HistoryItem: Identifiable, Codable {
    let id: String
    let rev: String?
    let sourceLanguage: String
    let targetLanguage: String
    let originalText: String
    let translatedText: String
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case rev = "_rev"
        case sourceLanguage
        case targetLanguage
        case originalText
        case translatedText
        case date
    }
}

struct TranslationResponse: Codable {
    let translatedText: String?
    let originalText: String?
    let date: String?
    let sourceLanguage: String?
    let targetLanguage: String?
    let error: String?
}

struct DictionaryResponse: Codable {
    let word: String
    let definition: String
    let error: String?
}
