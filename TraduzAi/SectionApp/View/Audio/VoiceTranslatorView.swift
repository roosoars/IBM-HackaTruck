//
//  VoiceTranslatorView.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import SwiftUI
import Speech
import Combine
import AVFoundation

struct VoiceTranslatorView: View {
    @StateObject private var viewModel = VoiceTranslatorViewModel()
    @State private var showCounter: Bool = false

    var body: some View {
        ZStack {
            Color(.blue)
                .ignoresSafeArea()
                .onTapGesture { hideKeyboard() }
                .accessibilityLabel("Fundo azul") // Descrição básica do fundo

            VStack(spacing: 20) {
                VoiceTranslatorHeaderView(viewModel: viewModel, showCounter: $showCounter)
                TranslatorView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.requestSpeechRecognitionPermission()
        }
        .onChange(of: viewModel.isRecording) {
            if viewModel.isRecording {
                withAnimation(.easeInOut(duration: 1)) {
                    showCounter = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showCounter = true
                    }
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showCounter = false
                }
            }
        }
    }
}

// MARK: - Voice Translator Header View
struct VoiceTranslatorHeaderView: View {
    @ObservedObject var viewModel: VoiceTranslatorViewModel
    @Binding var showCounter: Bool

    var body: some View {
        VStack {
            Text("Tradutor de Voz")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 40)
                .padding(.bottom, 40)
                .foregroundStyle(.white)
                .accessibilityLabel("Tradutor de Voz") // Rótulo simples e claro

            HStack {
                Spacer()
                RecordingIndicatorView(showCounter: showCounter, recordingTime: viewModel.recordingTimeString)
                microphoneButton
            }
        }
        .padding()
    }

    private var microphoneButton: some View {
        Button {
            withAnimation(.easeInOut) {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            }
        } label: {
            Image("MICROPHONE2")
                .padding(.trailing)
        }
        .accessibilityLabel(viewModel.isRecording ? "Parar gravação" : "Iniciar gravação")
        .accessibilityHint(viewModel.isRecording ? "Toca para parar a gravação de áudio" : "Toca para começar a gravar áudio")
        .accessibilityAddTraits(.isButton)
        .animation(.easeInOut, value: viewModel.isRecording)
    }
}

// MARK: - Translator View
struct TranslatorView: View {
    @ObservedObject var viewModel: VoiceTranslatorViewModel

    var body: some View {
        ZStack {
            Color("BG")
                .ignoresSafeArea(edges: .bottom)
                .accessibilityLabel("Fundo da área de tradução") // Descrição do fundo

            VStack(spacing: 35) {
                LanguageSelectionView(viewModel: viewModel)
                TranslationSectionView(viewModel: viewModel)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

// MARK: - Language Selection View
struct LanguageSelectionView: View {
    @ObservedObject var viewModel: VoiceTranslatorViewModel

    var body: some View {
        VStack {
            Text("Língua usada para gravação:")
                .font(.headline)
                .fontWeight(.regular)
                .accessibilityLabel("Língua usada para gravação") // Rótulo claro

            Menu {
                Button {
                    viewModel.selectedSourceLanguage = "Português"
                    viewModel.selectedLanguage = "Português"
                    viewModel.selectedTargetLanguage = "Inglês"
                    viewModel.translatedText = ""
                    viewModel.recognizedText = ""
                } label: {
                    Label("Português", image: "flag_pt")
                }
                Button {
                    viewModel.selectedSourceLanguage = "Inglês"
                    viewModel.selectedLanguage = "Inglês"
                    viewModel.selectedTargetLanguage = "Português"
                    viewModel.translatedText = ""
                    viewModel.recognizedText = ""
                } label: {
                    Label("Inglês", image: "flag_en")
                }
            } label: {
                HStack(spacing: 4) {
                    Image(viewModel.languageFlag)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                    Text(viewModel.selectedLanguage)
                        .foregroundColor(.black)
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
            }
            .accessibilityLabel("Selecionar idioma de gravação: \(viewModel.selectedLanguage)")
            .accessibilityHint("Toque para escolher entre Português e Inglês")
            .accessibilityAddTraits(.isButton)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

// MARK: - Translation Section View
struct TranslationSectionView: View {
    @ObservedObject var viewModel: VoiceTranslatorViewModel

    var body: some View {
        VStack(spacing: 8) {
            TranslationHeaderView(viewModel: viewModel)

            CustomTextEditor(
                text: $viewModel.translatedText,
                placeholder: "Tradução aparecerá aqui...",
                textColor: UIColor(named: "GRAY_COLOR") ?? .gray,
                font: UIFont.systemFont(ofSize: 14)
            )
            .disabled(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 10)
            .accessibilityLabel("Texto traduzido")
            .accessibilityValue(viewModel.translatedText.isEmpty ? "Nenhuma tradução disponível" : viewModel.translatedText)
            .accessibilityHint("Exibe o texto traduzido após a gravação")
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color("Stroke"), lineWidth: 1)
        )
        .padding()
    }
}

// MARK: - Translation Header View
struct TranslationHeaderView: View {
    @ObservedObject var viewModel: VoiceTranslatorViewModel

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(viewModel.targetFlag)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                Text(viewModel.selectedTargetLanguage)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .padding(.leading)
            .accessibilityLabel("Idioma de destino: \(viewModel.selectedTargetLanguage)")
            .accessibilityHint("Idioma para o qual o texto será traduzido")

            Spacer()

            Button {
                viewModel.speakText(viewModel.translatedText, language: viewModel.selectedTargetLanguage)
            } label: {
                Image(systemName: "speaker.wave.2.fill")
                    .renderingMode(.template)
                    .foregroundStyle(Color("ICON"))
                    .padding()
            }
            .accessibilityLabel("Reproduzir tradução")
            .accessibilityHint("Toca para ouvir o texto traduzido em voz alta")
            .accessibilityAddTraits(.isButton)
            .disabled(viewModel.translatedText.isEmpty)
        }
        .padding(.horizontal)
    }
}

// MARK: - Recording Indicator View
struct RecordingIndicatorView: View {
    let showCounter: Bool
    let recordingTime: String

    var body: some View {
        ZStack {
            if showCounter {
                Text("Tempo Gravado: \(recordingTime)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .transition(.opacity)
                    .accessibilityLabel("Tempo gravado: \(recordingTime)")
                    .accessibilityHint("Mostra o tempo decorrido da gravação atual")
            } else {
                Image("Ballon")
                    .transition(.opacity)
                Text("Grave seu áudio")
                    .font(.subheadline)
                    .foregroundStyle(.black)
                    .padding(.trailing)
                    .transition(.opacity)
                    .accessibilityLabel("Grave seu áudio")
                    .accessibilityHint("Indica que você pode iniciar uma gravação")
            }
        }
        .frame(width: 200, height: 40, alignment: .center)
    }
}

#Preview {
    VoiceTranslatorView()
}
