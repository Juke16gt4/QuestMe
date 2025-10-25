//
//  SpeechInputView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Medication/SpeechInputView.swift
//
//  🎯 ファイルの目的:
//      マイクから音声を取得し、Speech Framework で文字起こしするビュー。
//      - 薬剤名と容量を抽出して Medication.sqlite3 に保存するためのテキストを返す。
//      - 音声認識中はリアルタイムで文字列を更新。
//      - 保存時に completion で結果を返す。
//
//  🔗 依存:
//      - Speech（音声認識）
//      - MedicationDialog.swift（呼び出し元）
//      - MedicationManager.swift（保存）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI
import Speech

struct SpeechInputView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var recognizedText = "話してください…"
    @State private var isRecording = false

    var completion: (Result<String, Error>) -> Void

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private let audioEngine = AVAudioEngine()
    private var request = SFSpeechAudioBufferRecognitionRequest()
    private var recognitionTask: SFSpeechRecognitionTask?

    var body: some View {
        VStack(spacing: 20) {
            Text("音声入力")
                .font(.headline)

            Text(recognizedText)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Button(isRecording ? "停止" : "録音開始") {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }
            .padding()
            .background(Color.blue.opacity(0.8))
            .foregroundColor(.white)
            .clipShape(Capsule())

            Button("保存") {
                completion(.success(recognizedText))
                dismiss()
            }
        }
        .padding()
        .onDisappear {
            stopRecording()
        }
    }

    private func startRecording() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else {
                completion(.failure(NSError(domain: "SpeechAuth", code: -1)))
                return
            }

            do {
                let node = audioEngine.inputNode
                let recordingFormat = node.outputFormat(forBus: 0)
                node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                    self.request.append(buffer)
                }

                audioEngine.prepare()
                try audioEngine.start()

                recognitionTask = recognizer?.recognitionTask(with: request) { result, error in
                    if let result = result {
                        DispatchQueue.main.async {
                            self.recognizedText = result.bestTranscription.formattedString
                        }
                    } else if let error = error {
                        self.completion(.failure(error))
                    }
                }

                DispatchQueue.main.async {
                    self.isRecording = true
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request.endAudio()
        recognitionTask?.cancel()
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
}
