//
//  HomeView.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("BG").opacity(0.95), Color("BG")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .onTapGesture { hideKeyboard() }
            .accessibilityLabel("Fundo da tela inicial")
            
            VStack(spacing: 20) {
                HomeHeaderView()
                
                ContentContainerView(viewModel: viewModel)
                    .padding(.horizontal)
                
                Spacer(minLength: 5)
            }
            .padding(.bottom, 10)
        }
    }
}

// MARK: - Home Header

struct HomeHeaderView: View {
    var body: some View {
        HStack(spacing: 0) {
            Lottie(animationFileName: "TraduzAi", loopMode: .loop)
                .frame(width: 100, height: 100)
                .clipped()
                .padding(-25)
                .accessibilityLabel("Logo animada")
            
            Text("TraduzAi")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .accessibilityLabel("TraduzAi Titulo")
        }
        .padding(.top, 35)
        .padding(.bottom, 15)
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Content Container

struct ContentContainerView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            SourceTextSection(viewModel: viewModel)
            DividerView()
            TranslatedTextSection(viewModel: viewModel)
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("Stroke"), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Source Text

struct SourceTextSection: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Image(viewModel.sourceFlag)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                        .accessibilityHidden(true)
                    Text(viewModel.sourceLanguage)
                        .foregroundColor(.black)
                        .font(.headline)
                        .accessibilityLabel("Idioma de origem: \(viewModel.sourceLanguage)")
                }
                .padding(.leading)
                
                Spacer()
                
                Button {
                    viewModel.sourceText = ""
                } label: {
                    Image("X")
                        .padding()
                }
                .accessibilityLabel("Limpar texto de origem")
                .accessibilityHint("Toque para apagar o texto digitado")
                .accessibilityAddTraits(.isButton)
            }
            
            CustomTextEditor(
                text: $viewModel.sourceText,
                placeholder: "Digite seu texto aqui...",
                textColor: UIColor(named: "GRAY_COLOR") ?? .gray,
                font: UIFont.systemFont(ofSize: 14)
            )
            .frame(maxHeight: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .accessibilityLabel("Texto de origem")
            .accessibilityHint("Digite o texto que deseja traduzir")
            .accessibilityValue(viewModel.sourceText.isEmpty ? "Vazio" : viewModel.sourceText)
        }
    }
}

// MARK: - Translated Text

struct TranslatedTextSection: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Image(viewModel.targetFlag)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                        .accessibilityHidden(true)
                    Text(viewModel.targetLanguage)
                        .foregroundColor(.black)
                        .font(.headline)
                        .accessibilityLabel("Idioma de destino: \(viewModel.targetLanguage)")
                }
                .padding(.leading)
                
                Spacer()
                
                Button {
                    UIPasteboard.general.string = viewModel.translatedText
                } label: {
                    Image("COPY")
                        .padding()
                }
                .accessibilityLabel("Copiar tradução")
                .accessibilityHint("Toque para copiar o texto traduzido para a área de transferência")
                .accessibilityAddTraits(.isButton)
                .disabled(viewModel.translatedText.isEmpty)
                
                Button {
                    viewModel.speakText(viewModel.translatedText, language: viewModel.targetLanguage)
                } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .renderingMode(.template)
                        .foregroundColor(Color("ICON"))
                        .padding()
                }
                .accessibilityLabel("Reproduzir tradução")
                .accessibilityHint("Toque para ouvir o texto traduzido em voz alta")
                .accessibilityAddTraits(.isButton)
                .disabled(viewModel.translatedText.isEmpty)
                
                Button {
                    viewModel.swapLanguages()
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .renderingMode(.template)
                        .foregroundColor(Color("ICON"))
                        .padding()
                }
                .accessibilityLabel("Trocar idiomas")
                .accessibilityHint("Toque para inverter os idiomas de origem e destino")
                .accessibilityAddTraits(.isButton)
            }
            
            CustomTextEditor(
                text: $viewModel.translatedText,
                placeholder: "Tradução aparecerá aqui...",
                textColor: UIColor(named: "GRAY_COLOR") ?? .gray,
                font: UIFont.systemFont(ofSize: 14)
            )
            .disabled(true)
            .frame(maxHeight: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .accessibilityLabel("Texto traduzido")
            .accessibilityHint("Exibe a tradução do texto digitado")
            .accessibilityValue(viewModel.translatedText.isEmpty ? "Nenhuma tradução disponível" : viewModel.translatedText)
        }
    }
}

// MARK: - Divider

struct DividerView: View {
    var body: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(Color("BAR"))
            .padding(.vertical, 8)
            .padding(.horizontal)
            .accessibilityHidden(true)
    }
}
