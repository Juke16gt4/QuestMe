//
//  VoiceGuide.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/Speech/VoiceGuide.swift
//
//  🎯 ファイルの目的:
//      - Companion が音声でユーザーをガイドするための TTS ラッパー
//      - AVSpeechSynthesizer を利用
//
//  👤 製作者: 津村 淳一
//  📅 作成日: 2025年10月17日
//

import Foundation
import AVFoundation

struct VoiceGuide {
    private static let synthesizer = AVSpeechSynthesizer()

    /// 指定したテキストを音声で読み上げる
    static func speak(_ text: String, languageCode: String = "ja-JP") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}
