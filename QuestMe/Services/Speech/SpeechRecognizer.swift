//
//  SpeechRecognizer.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/Speech/SpeechRecognizer.swift
//
//  🎯 ファイルの目的:
//      音声入力をテキストに変換するサービス。
//      - start(handler:) で音声認識を開始し、結果をクロージャで返す。
//      - stop() で音声認識を停止。
//      - iOS Speech Framework を利用し、選択言語に応じて認識。
//      - CompanionOverlay や UserProfileView から利用される。
//
//  🔗 依存:
//      - AVFoundation
//      - Speech
//
//  👤 製作者: 津村 淳一
//  📅 最終更新: 2025年10月17日
//

import Foundation
import Speech
import AVFoundation

final class SpeechRecognizer: NSObject, ObservableObject {
    static let shared = SpeechRecognizer()
    private override init() {}

    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechRecognizer: SFSpeechRecognizer?

    @Published var transcript: String = ""

    /// 音声認識の権限をリクエスト
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }

    /// 音声認識を開始
    /// - Parameters:
    ///   - locale: 言語コード（例: "ja-JP", "en-US"）
    ///   - handler: 認識結果を返すクロージャ
    func start(locale: String = "ja-JP", handler: @escaping (String) -> Void) throws {
        stop() // 前回のセッションを停止

        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: locale))
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            throw NSError(domain: "SpeechRecognizer", code: -1, userInfo: [NSLocalizedDescriptionKey: "音声認識が利用できません"])
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let best = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.transcript = best
                    handler(best)
                }
            }
            if error != nil {
                self.stop()
            }
        }
    }

    /// 音声認識を停止
    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}
