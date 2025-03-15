//
//  HistoryView.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var currentPage: Int = 0
    @State private var selectedHistoryItem: HistoryItem? = nil
    
    let minCardHeight: CGFloat = 150
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    Color("BG")
                        .ignoresSafeArea()
                        .accessibilityLabel("Fundo da tela de histórico")
                    
                    if viewModel.isLoading {
                        ProgressView("Carregando histórico")
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("ICON")))
                            .padding()
                            .accessibilityLabel("Carregando histórico")
                            .accessibilityHint("Aguarde enquanto o histórico está sendo carregado")
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.body)
                            .padding()
                            .accessibilityLabel("Erro: \(errorMessage)")
                            .accessibilityHint("Ocorreu um problema ao carregar o histórico")
                    } else {
                        VStack(spacing: 20) {
                            let availableHeight = geo.size.height - 150
                            let cardsPerPage = max(1, Int(floor(availableHeight / minCardHeight)))
                            let totalPages = Int(ceil(Double(viewModel.historyItems.count) / Double(cardsPerPage)))
                            let currentPageClamped = max(0, min(currentPage, totalPages - 1))
                            
                            let startIndex = currentPageClamped * cardsPerPage
                            let endIndex = min(viewModel.historyItems.count, startIndex + cardsPerPage)
                            let itemsForPage = Array(viewModel.historyItems[startIndex..<endIndex])
                            
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(itemsForPage) { item in
                                        HistoryRow(
                                            item: item,
                                            sourceFlag: viewModel.flagImage(for: item.sourceLanguage),
                                            targetFlag: viewModel.flagImage(for: item.targetLanguage),
                                            cardHeight: minCardHeight
                                        )
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            selectedHistoryItem = item
                                        }
                                        .accessibilityElement(children: .combine)
                                        .accessibilityLabel("Tradução de \(item.sourceLanguage) para \(item.targetLanguage), realizada em \(item.date)")
                                        .accessibilityHint("Toque para ver detalhes da tradução")
                                        .accessibilityAddTraits(.isButton)
                                    }
                                }
                                .padding(.top, 10)
                            }
                            
                            // Navegação com botões estilizados
                            HStack(spacing: 12) {
                                if currentPageClamped > 0 {
                                    Button(action: {
                                        withAnimation(.easeInOut) {
                                            currentPage -= 1
                                        }
                                    }) {
                                        Text("Anterior")
                                            .font(.footnote)
                                            .foregroundColor(Color("ICON"))
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(Color("ICON").opacity(0.15))
                                            .cornerRadius(8)
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    }
                                    .accessibilityLabel("Página anterior")
                                    .accessibilityHint("Toque para ir à página anterior do histórico")
                                    .accessibilityAddTraits(.isButton)
                                } else {
                                    Spacer().frame(width: 80)
                                        .accessibilityHidden(true)
                                }
                                
                                Text("Página \(currentPageClamped + 1) de \(totalPages)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .accessibilityLabel("Página atual: \(currentPageClamped + 1) de \(totalPages)")
                                
                                if currentPageClamped < totalPages - 1 {
                                    Button(action: {
                                        withAnimation(.easeInOut) {
                                            currentPage += 1
                                        }
                                    }) {
                                        Text("Próxima")
                                            .font(.footnote)
                                            .foregroundColor(Color("ICON"))
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(Color("ICON").opacity(0.15))
                                            .cornerRadius(8)
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    }
                                    .accessibilityLabel("Próxima página")
                                    .accessibilityHint("Toque para ir à próxima página do histórico")
                                    .accessibilityAddTraits(.isButton)
                                } else {
                                    Spacer().frame(width: 80)
                                        .accessibilityHidden(true)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .onAppear {
                    viewModel.fetchHistory()
                }
            }
            .navigationBarTitle("Histórico", displayMode: .large)
            .accessibilityLabel("Tela de histórico")
        }
        .sheet(item: $selectedHistoryItem, onDismiss: {
            selectedHistoryItem = nil
        }) { item in
            HistoryDetailView(item: item)
        }
    }
}

// MARK: - History Row
struct HistoryRow: View {
    let item: HistoryItem
    let sourceFlag: String
    let targetFlag: String
    let cardHeight: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(sourceFlag)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                    .accessibilityHidden(true) // Ícone decorativo
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                    .accessibilityHidden(true) // Ícone decorativo
                Image(targetFlag)
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.sourceLanguage)
                    .font(.headline)
                    .accessibilityLabel("Idioma original: \(item.sourceLanguage)")
                Text(item.originalText)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(2)
                    .accessibilityLabel("Texto original: \(item.originalText)")
            }
            .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.targetLanguage)
                    .font(.headline)
                    .accessibilityLabel("Idioma traduzido: \(item.targetLanguage)")
                Text(item.translatedText)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(2)
                    .accessibilityLabel("Texto traduzido: \(item.translatedText)")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(height: cardHeight)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
    }
}
