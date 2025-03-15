//
//  HistoryDetailView.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import SwiftUI

struct HistoryDetailView: View {
    let item: HistoryItem
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Cabeçalho com bandeiras e data/hora
                    HStack {
                        Image(item.sourceLanguage == "Português" ? "flag_pt" : "flag_en")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                            .accessibilityHidden(true) // Ícone decorativo
                        Image(systemName: "arrow.right")
                            .foregroundColor(.gray)
                            .accessibilityHidden(true) // Ícone decorativo
                        Image(item.targetLanguage == "Português" ? "flag_pt" : "flag_en")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                            .accessibilityHidden(true) // Ícone decorativo
                        Spacer()
                        Text(item.date)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .accessibilityLabel("Data: \(item.date)")
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Tradução de \(item.sourceLanguage) para \(item.targetLanguage), realizada em \(item.date)")
                    
                    // Texto original
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Texto (\(item.sourceLanguage)):")
                            .font(.headline)
                            .foregroundColor(.black)
                            .accessibilityLabel("Texto original em \(item.sourceLanguage)")
                        Text(item.originalText)
                            .font(.body)
                            .foregroundColor(.black.opacity(0.8))
                            .accessibilityLabel("Texto: \(item.originalText)")
                    }
                    .padding(.horizontal, 16)
                    
                    Divider()
                        .padding(.horizontal, 16)
                        .accessibilityHidden(true) // Divisor decorativo
                    
                    // Texto traduzido
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tradução (\(item.targetLanguage)):")
                            .font(.headline)
                            .foregroundColor(.black)
                            .accessibilityLabel("Tradução em \(item.targetLanguage)")
                        Text(item.translatedText)
                            .font(.body)
                            .foregroundColor(.black.opacity(0.8))
                            .accessibilityLabel("Tradução: \(item.translatedText)")
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
                .padding(.bottom, 20)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .accessibilityElement(children: .combine) // Combina o conteúdo em um único item acessível
            }
            .background(Color("BG").ignoresSafeArea())
            .navigationBarTitle("Detalhes", displayMode: .inline)
            .accessibilityLabel("Detalhes da tradução")
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Text("Fechar")
                    .foregroundColor(Color("ICON"))
            }
            .accessibilityLabel("Fechar")
            .accessibilityHint("Toque para fechar os detalhes da tradução")
            .accessibilityAddTraits(.isButton))
        }
    }
}

struct HistoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryDetailView(item: HistoryItem(
            id: "example",
            rev: nil,
            sourceLanguage: "Português",
            targetLanguage: "Inglês",
            originalText: "Oi, tudo bem?",
            translatedText: "Hi, how are you?",
            date: "2025-03-03 21:19"
        ))
    }
}
