//
//  HomeViewModel.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import AVFoundation
import Foundation
import Combine


class HomeViewModel: ObservableObject {

    // MARK: - Properties

    @Published var sourceLanguage: String = "Português"
    @Published var targetLanguage: String = "Inglês"
    @Published var sourceText: String = "" {
        didSet {
            // Exibe o placeholder se estiver vazio, senão aciona a tradução
            if sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                translatedText = ""
            } else {
                triggerTranslation()
            }
        }
    }
    @Published var translatedText: String = ""
    
    private var debounceTimer: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    // Instância do sintetizador de voz
    private let synthesizer = AVSpeechSynthesizer()
    
    // MARK: - Computed Properties

    /// Retorna a bandeira correspondente ao idioma de origem
    var sourceFlag: String {
        switch sourceLanguage {
        case "Português": return "flag_pt"
        case "Inglês":    return "flag_en"
        default:          return "flag_pt"
        }
    }
    
    /// Retorna a bandeira correspondente ao idioma de destino
    var targetFlag: String {
        switch targetLanguage {
        case "Português": return "flag_pt"
        case "Inglês":    return "flag_en"
        default:          return "flag_pt"
        }
    }
    
    // MARK: - Translation Methods

    /// Aciona a tradução com debounce de 500ms.
    func triggerTranslation() {
        debounceTimer?.cancel()
        debounceTimer = Just(())
            .delay(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.translateText()
            }
    }
    
    /// Realiza a chamada de tradução utilizando o NetworkManager.
    func translateText() {
        TranslationService.shared.translateText(
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            text: sourceText
        )
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Erro na tradução: \(error)")
            }
        }, receiveValue: { [weak self] response in
            if let translation = response.translatedText {
                self?.translatedText = translation
            } else if let errorMessage = response.error {
                self?.translatedText = errorMessage
            }
        })
        .store(in: &cancellables)
    }
    
    // MARK: - Utility Methods

    /// Troca os idiomas e inverte os textos para retradução.
    func swapLanguages() {
        let tempLanguage = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = tempLanguage
        
        let tempText = sourceText
        sourceText = translatedText
        translatedText = tempText
        
        triggerTranslation()
    }
    
    /// Fala os textos.
    func speakText(_ text: String, language: String) {
        guard !text.isEmpty else { return }
        
        let utterance = AVSpeechUtterance(string: text)
        
        if language == "Português" {
            utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
            utterance.volume = 1.0
        } else if language == "Inglês" {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.volume = 1.0
        } else {
            // Padrão para português
            utterance.voice = AVSpeechSynthesisVoice(language: "pt-BR")
            utterance.volume = 1.0
        }
        
        synthesizer.speak(utterance)
    }
}
