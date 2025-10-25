//
//  SpeechSynthesizerService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Speech/SpeechSynthesizerService.swift
//
//  🎯 ファイルの目的:
//      音声合成の最小責務に集中したサービス。
//      - AVSpeechSynthesizer による音声出力と即時停止のみを担う
//      - 言語コード・話速・音量・ピッチを指定可能
//      - 他のモジュール（SpeechSync, MedicationAdviceView）から再利用可能
//
//  🔗 関連/連動ファイル:
//      - SpeechSync.swift（統合ラッパー）
//      - VoiceProfile.swift（音声プロファイル）
//      - MedicationAdviceView.swift（音声案内）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月23日

import Foundation
import AVFoundation

public final class SpeechSynthesizerService {
    private let synthesizer = AVSpeechSynthesizer()

    public init() {}

    /// 音声合成を開始
    public func speak(text: String,
                      languageCode: String = "ja-JP",
                      rate: Float = 0.5,
                      pitch: Float = 1.0,
                      volume: Float = 1.0) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = volume
        utterance.prefersAssistiveTechnologySettings = true
        synthesizer.speak(utterance)
    }

    /// 即時停止
    public func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    /// 発話中かどうか
    public func isSpeaking() -> Bool {
        synthesizer.isSpeaking
    }
}
