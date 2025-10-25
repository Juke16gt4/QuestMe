//
//  SpeechPhraseTracker.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Speech/SpeechPhraseTracker.swift
//
//  🎯 ファイルの目的:
//      音声合成中の発話フレーズを抽出し、UI（吹き出しなど）と連動する。
//      - AVSpeechSynthesizerDelegate の willSpeakRange を利用
//      - CompanionSpeechBubbleView.swift などに currentPhrase を公開
//      - onPhraseSpoken によりリアルタイム通知も可能
//
//  🔗 関連/連動ファイル:
//      - SpeechSync.swift（統合ラッパー）
//      - CompanionSpeechBubbleView.swift（吹き出し表示）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月23日

import Foundation
import AVFoundation
import Combine

public final class SpeechPhraseTracker: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published public var currentPhrase: String = ""
    public var onPhraseSpoken: ((String) -> Void)?

    public override init() {
        super.init()
    }

    /// フレーズ抽出を開始（SpeechSynthesizerService に delegate 設定）
    public func attach(to synthesizer: AVSpeechSynthesizer) {
        synthesizer.delegate = self
    }

    // MARK: - AVSpeechSynthesizerDelegate

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                                  willSpeakRangeOfSpeechString characterRange: NSRange,
                                  utterance: AVSpeechUtterance) {
        let ns = utterance.speechString as NSString
        let phrase = ns.substring(with: characterRange)
        let refined = refinePhrase(phrase)
        DispatchQueue.main.async {
            self.currentPhrase = refined
            self.onPhraseSpoken?(refined)
        }
    }

    // MARK: - 表示用に整形
    private func refinePhrase(_ phrase: String) -> String {
        if phrase.contains("。") || phrase.contains("、") {
            return phrase.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return phrase
    }
}
