//
//  SpeechManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/System/Voice/SpeechManager.swift
//
//  🎯 ファイルの目的:
//      言語選択時に音声で「これで良いですか？」を再生するユーティリティ。
//      - AVSpeechSynthesizer をラップして簡潔に利用可能にする。
//      - LanguageOption の speechCode に基づき音声を切り替え。
//      - LanguagePickerView から呼び出される。
//
//  🔗 依存:
//      - AVFoundation（音声合成）
//      - LanguageOption.swift（言語定義）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import Foundation
import AVFoundation
import Combine

final class SpeechManager {
    static let shared = SpeechManager()
    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    func speakConfirmation(for language: LanguageOption) {
        let phrase: String
        switch language.code {
        case "ja":
            phrase = "母国語は\(language.name)で、これで良いですか？"
        default:
            phrase = "\(language.welcome)! Is \(language.name) your language? Is this okay?"
        }

        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = AVSpeechSynthesisVoice(language: language.speechCode)
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}
