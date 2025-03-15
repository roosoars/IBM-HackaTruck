//
//  DictionaryViewModel.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import SwiftUI
import Combine

class DictionaryViewModel: ObservableObject {
    @Published var selectedLanguage: String = "Português"
    @Published var searchWord: String = ""
    @Published var definition: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Retorna a bandeira conforme o idioma selecionado
    var languageFlag: String {
        switch selectedLanguage {
        case "Português":
            return "flag_pt"
        case "Inglês":
            return "flag_en"
        default:
            return "flag_pt"
        }
    }
    
    /// Consulta a definição da palavra usando a API da OpenAI
    func fetchDefinition() {
        guard !searchWord.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        let prompt: String
        if selectedLanguage == "Português" {
            prompt = "Me responda como no discionário português, para a palavra \"\(searchWord)\"."
        } else {
            prompt = "Answer me as in the english discionarium, for the word \"\(searchWord)\"."
        }
        
        OpenAIService.shared.dictionaryDefinition(prompt: prompt)
            .sink { completion in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if case .failure(let error) = completion {
                        self.errorMessage = error.localizedDescription
                    }
                }
            } receiveValue: { response in
                DispatchQueue.main.async {
                    if !response.definition.isEmpty {
                        self.definition = response.definition
                    } else {
                        self.definition = "Definição não encontrada."
                    }
                }
            }
            .store(in: &cancellables)
    }
}
