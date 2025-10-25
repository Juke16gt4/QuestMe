//
//  SpeechSync.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Speech/SpeechSync.swift
//
//  🎯 ファイルの目的:
//      音声合成・フレーズ抽出・発話終了保存・トピック推定を統合するラッパー。
//      - 各責務は分離されたサービスとして注入・再利用可能
//      - 吹き出し表示・会話保存・12言語対応のトピック分類を一括管理
//
//  🔗 連動ファイル:
//      - SpeechSynthesizerService.swift（音声合成）
//      - SpeechPhraseTracker.swift（フレーズ抽出）
//      - SpeechCompletionLogger.swift（発話終了保存）
//      - SpeechTopicInferencer.swift（トピック推定）
//      - CompanionSpeechBubbleView.swift（UI連動）
//      - CalendarSyncService.swift（保存）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月23日

import Foundation
import AVFoundation
import Combine

final class SpeechSync: ObservableObject {
    private let voice: VoiceProfile
    private let synthesizer = AVSpeechSynthesizer()

    init(voice: VoiceProfile) {
        self.voice = voice
    }

    func speak(_ text: String, emotion: EmotionType = .neutral) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: voice.identifier)

        // 感情に応じたトーン調整
        switch emotion {
        case .happy, .playful:
            utterance.pitchMultiplier = 1.2
            utterance.rate = 0.45
        case .sad, .lonely:
            utterance.pitchMultiplier = 0.8
            utterance.rate = 0.35
        case .gentle, .elderly:
            utterance.pitchMultiplier = 1.0
            utterance.rate = 0.4
        case .robotic:
            utterance.pitchMultiplier = 1.0
            utterance.rate = 0.5
        case .romantic:
            utterance.pitchMultiplier = 1.1
            utterance.rate = 0.42
        case .philosophical:
            utterance.pitchMultiplier = 0.95
            utterance.rate = 0.38
        case .confused:
            utterance.pitchMultiplier = 1.0
            utterance.rate = 0.48
        default:
            utterance.pitchMultiplier = 1.0
            utterance.rate = 0.43
        }

        synthesizer.speak(utterance)
    }
}
