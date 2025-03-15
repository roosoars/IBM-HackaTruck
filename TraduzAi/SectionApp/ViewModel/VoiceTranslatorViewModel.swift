//
//  VoiceTranslatorViewModel.swift
//  TraduzAi
//
//  Created by Turma02-25 on 10/03/25.
//

import SwiftUI
import Speech
import Combine
import AVFoundation

class VoiceTranslatorViewModel: ObservableObject {
    @Published var selectedLanguage: String = "Português"
    @Published var selectedSourceLanguage: String = "Português"
    @Published var selectedTargetLanguage: String = "Inglês"
    
    @Published var recognizedText: String = ""
    @Published var translatedText: String = ""
    
    @Published var isRecording: Bool = false
    let supportedLanguages: [String] = ["Português", "Inglês"]
    
    @Published private var recordingStartTime: Date?
    private var timer: Timer?
    @Published var recordingTimeString: String = "00:00"
    
    private let speechToTextManager = SpeechToTextManager()
    private var cancellables = Set<AnyCancellable>()
    
    // Instância persistente do sintetizador para manter a reprodução
    private let synthesizer = AVSpeechSynthesizer()
    
    var languageFlag: String {
        switch selectedLanguage {
        case "Português": return "flag_pt"
        case "Inglês": return "flag_en"
        default: return "flag_pt"
        }
    }
    
    var targetFlag: String {
        switch selectedTargetLanguage {
        case "Português": return "flag_pt"
        case "Inglês": return "flag_en"
        default: return "flag_pt"
        }
    }
    
    init() {
        speechToTextManager.transcribedText
            .receive(on: RunLoop.main)
            .sink { [weak self] newText in
                self?.recognizedText = newText
            }
            .store(in: &cancellables)
    }
    
    func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Permissão concedida para reconhecimento de fala.")
            case .denied, .restricted, .notDetermined:
                print("Permissão negada ou indisponível.")
            @unknown default:
                break
            }
        }
    }
    
    func startRecording() {
        isRecording = true
        recognizedText = ""
        speechToTextManager.startTranscribing(language: mapLanguage(selectedSourceLanguage))
        
        recordingStartTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateRecordingTime()
        }
    }
    
    func stopRecording() {
        isRecording = false
        speechToTextManager.stopTranscribing()
        
        timer?.invalidate()
        timer = nil
        recordingTimeString = "00:00"
        
        refineAndTranslateText()
    }
    
    private func updateRecordingTime() {
        guard let start = recordingStartTime else { return }
        let elapsed = Date().timeIntervalSince(start)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        recordingTimeString = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func refineAndTranslateText() {
        OpenAIService.shared.refineText(language: selectedSourceLanguage, text: recognizedText)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Erro ao refinar texto: \(error)")
                    self.translateText(refinedText: self.recognizedText)
                }
            }, receiveValue: { [weak self] refineResponse in
                guard let self = self else { return }
                let textToTranslate = refineResponse.refinedText.isEmpty ? self.recognizedText : refineResponse.refinedText
                self.translateText(refinedText: textToTranslate)
            })
            .store(in: &cancellables)
    }
    
    private func translateText(refinedText: String) {
        guard !refinedText.isEmpty else {
            translatedText = ""
            return
        }
        
        TranslationService.shared.translateText(
            sourceLanguage: selectedSourceLanguage,
            targetLanguage: selectedTargetLanguage,
            text: refinedText
        )
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Erro na tradução: \(error)")
            }
        }, receiveValue: { [weak self] response in
            DispatchQueue.main.async {
                if let translation = response.translatedText {
                    self?.translatedText = translation
                } else if let errorMessage = response.error {
                    self?.translatedText = errorMessage
                }
            }
        })
        .store(in: &cancellables)
    }
    
    func speakText(_ text: String, language: String) {
        guard !text.isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        let voiceIdentifier = mapLanguage(language)
        utterance.voice = AVSpeechSynthesisVoice(language: voiceIdentifier)
        utterance.volume = 1.0
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Erro ao configurar a sessão de áudio para reprodução: \(error)")
        }
        
        synthesizer.speak(utterance)
    }
    
    private func mapLanguage(_ language: String) -> String {
        switch language {
        case "Português": return "pt-BR"
        case "Inglês": return "en-US"
        default: return "pt-BR"
        }
    }
}

// MARK: - SpeechToTextManager
class SpeechToTextManager {
    private let audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    let transcribedText = PassthroughSubject<String, Never>()
    
    func startTranscribing(language: String) {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))
        
        if audioEngine.isRunning {
            stopTranscribing()
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Erro ao configurar sessão de áudio: \(error.localizedDescription)")
            return
        }
        
        request = SFSpeechAudioBufferRecognitionRequest()
        guard let inputNode = audioEngine.inputNode as AVAudioInputNode? else {
            fatalError("Erro ao obter inputNode do áudio.")
        }
        guard let request = request else {
            fatalError("Não foi possível criar a requisição de áudio.")
        }
        
        request.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.transcribedText.send(bestString)
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stopTranscribing()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Erro ao iniciar audioEngine: \(error.localizedDescription)")
        }
    }
    
    func stopTranscribing() {
        recognitionTask?.cancel()
        recognitionTask = nil
        
        request?.endAudio()
        request = nil
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}
