//
//  EmotionType+Localization.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Extension/EmotionType+Localization.swift
//
//  🎯 ファイルの目的:
//      EmotionType に12言語対応ラベル表示機能を追加する。
//      - UI表示責務を EmotionType 側に持たせ、返り値なしの副作用型関数で統一。
//      - 各言語の感情ラベルを明示的に定義し、EmotionType の拡張性を確保する。
//      - Companion の発話と吹き出し表示に連動可能な構造とする。
//
//  🔗 連動ファイル:
//      - EmotionType.swift（定義元）
//      - CertificationView.swift（表示）
//      - CompanionSpeechBubble.swift（吹き出し表示）
//      - SpeechSync.swift（音声合成）
//
//  👤 制作者: 津村 淳一
//  📅 製作日: 2025年10月17日
//

import SwiftUI

extension EmotionType {
    /// 言語コードに応じたラベルを Text に副作用的に適用する
    func applyLocalizedLabel(to text: inout Text, in language: String) {
        let localized: String
        switch language {
        case "ja": localized = self.label
        case "en":
            switch self {
            case .happy: localized = "Happy"
            case .sad: localized = "Sad"
            case .angry: localized = "Angry"
            case .neutral: localized = "Neutral"
            default: localized = self.rawValue.capitalized
            }
        case "pt":
            switch self {
            case .happy: localized = "Feliz"
            case .sad: localized = "Triste"
            case .angry: localized = "Bravo"
            case .neutral: localized = "Normal"
            default: localized = self.rawValue
            }
        case "fr":
            switch self {
            case .happy: localized = "Heureux"
            case .sad: localized = "Triste"
            case .angry: localized = "Fâché"
            case .neutral: localized = "Neutre"
            default: localized = self.rawValue
            }
        case "de":
            switch self {
            case .happy: localized = "Glücklich"
            case .sad: localized = "Traurig"
            case .angry: localized = "Wütend"
            case .neutral: localized = "Neutral"
            default: localized = self.rawValue
            }
        case "es":
            switch self {
            case .happy: localized = "Feliz"
            case .sad: localized = "Triste"
            case .angry: localized = "Enojado"
            case .neutral: localized = "Neutral"
            default: localized = self.rawValue
            }
        case "zh":
            switch self {
            case .happy: localized = "开心"
            case .sad: localized = "伤心"
            case .angry: localized = "生气"
            case .neutral: localized = "中性"
            default: localized = self.rawValue
            }
        case "ko":
            switch self {
            case .happy: localized = "행복"
            case .sad: localized = "슬픔"
            case .angry: localized = "화남"
            case .neutral: localized = "중립"
            default: localized = self.rawValue
            }
        case "it":
            switch self {
            case .happy: localized = "Felice"
            case .sad: localized = "Triste"
            case .angry: localized = "Arrabbiato"
            case .neutral: localized = "Neutrale"
            default: localized = self.rawValue
            }
        case "hi":
            switch self {
            case .happy: localized = "खुश"
            case .sad: localized = "उदास"
            case .angry: localized = "गुस्सा"
            case .neutral: localized = "तटस्थ"
            default: localized = self.rawValue
            }
        case "sv":
            switch self {
            case .happy: localized = "Glad"
            case .sad: localized = "Ledsen"
            case .angry: localized = "Arg"
            case .neutral: localized = "Neutral"
            default: localized = self.rawValue
            }
        case "no":
            switch self {
            case .happy: localized = "Glad"
            case .sad: localized = "Trist"
            case .angry: localized = "Sint"
            case .neutral: localized = "Nøytral"
            default: localized = self.rawValue
            }
        default:
            localized = self.label
        }

        text = Text(localized)
            .foregroundColor(self.color)
            .font(.headline)
    }
}
