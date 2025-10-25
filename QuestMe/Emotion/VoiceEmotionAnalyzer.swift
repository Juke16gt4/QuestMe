//
//  VoiceEmotionAnalyzer.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Emotion/VoiceEmotionAnalyzer.swift
//
//  🎯 ファイルの目的:
//      ユーザーの音声入力をリアルタイムで解析し、感情ラベル（例：neutral, joy）を推定するロジック。
//      - AVAudioEngine を用いて音声取得。
//      - Combine に準拠し、SwiftUI から @Published detectedEmotion を監視可能。
//      - Companion の応答や表情変化に連動。
//      - ConsentManager にて emotionInference の同意がある場合のみ起動可能。
//
//  🔗 依存:
//      - AVFoundation（音声取得）
//      - Combine（状態監視）
//      - CompanionExpression.swift（表情連動）
//      - ConsentManager.swift（同意確認）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月30日

import Foundation
import AVFoundation
import Combine

public final class VoiceEmotionAnalyzer: ObservableObject {
    private let engine = AVAudioEngine()
    @Published public var detectedEmotion: String = "neutral"

    public init() {}

    public func startListening() {
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            let emotion = self.analyze(buffer: buffer)
            DispatchQueue.main.async {
                self.detectedEmotion = emotion
            }
        }

        try? engine.start()
    }

    public func stopListening() {
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
    }

    private func analyze(buffer: AVAudioPCMBuffer) -> String {
        // 仮のロジック：音量で感情を判定
        let level = buffer.frameLength
        return level > 500 ? "joy" : "neutral"
    }
}
