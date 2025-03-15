//
//  HistoryViewModel.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import SwiftUI
import Combine

class HistoryViewModel: ObservableObject {
    @Published var historyItems: [HistoryItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    /// URL base do seu Node-RED (ajuste conforme necessário)
    private let baseURL = "http://3.145.141.213:1880"
    
    /// Endpoint para obter o histórico de traduções
    private let historyEndpoint = "/translate-history"
    
    /// Função que faz a requisição GET ao endpoint e atualiza `historyItems`.
    func fetchHistory() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: baseURL + historyEndpoint) else {
            self.errorMessage = "URL inválida."
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [HistoryItem].self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .sink { completion in
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    self.errorMessage = "Erro ao carregar histórico: \(error.localizedDescription)"
                case .finished:
                    break
                }
            } receiveValue: { items in
                // Ordena os itens para que os mais recentes fiquem primeiro (formato "yyyy-MM-dd HH:mm" é lexicograficamente ordenável)
                self.historyItems = items.sorted { $0.date > $1.date }
            }
            .store(in: &cancellables)
    }
    
    /// Retorna o nome da imagem de bandeira para o idioma fornecido.
    func flagImage(for language: String) -> String {
        switch language {
        case "Português":
            return "flag_pt"
        case "Inglês":
            return "flag_en"
        default:
            return "flag_pt"
        }
    }
}
