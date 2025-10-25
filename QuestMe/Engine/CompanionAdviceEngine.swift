//
//  CompanionAdviceEngine.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Engine/CompanionAdviceEngine.swift
//
//  🎯 ファイルの目的:
//      - 検査データ（LabResult）と感情ログ（EmotionLog）を分析し、コンパニオンによる助言を生成する。
//      - EmotionType × CompanionStyle × LanguageOption に応じたリアルタイム助言も生成。
//      - CompanionOverlay を通じて音声案内を提供。
//      - PDFや履歴保存にも応用可能なテキスト出力を提供する。
//
//  🔗 依存:
//      - Models/EmotionLog.swift（emotion, date）
//      - Models/LabResult.swift（testName, value, date）
//      - Models/EmotionType.swift
//      - Models/CompanionStyle.swift
//      - Models/LanguageOption.swift
//      - UI/CompanionOverlay.swift（音声案内）
//

import Foundation

final class CompanionAdviceEngine {
    static let shared = CompanionAdviceEngine()

    private init() {}

    // MARK: - 検査データ・感情ログに基づく助言

    func generateEmotionAdvice(from logs: [EmotionLog]) -> String {
        guard !logs.isEmpty else {
            return "感情ログが見つかりませんでした。"
        }

        let recent = logs.suffix(7)
        let counts = Dictionary(grouping: recent.map { $0.emotion }, by: { $0 }).mapValues { $0.count }
        let dominant = counts.max(by: { $0.value < $1.value })?.key ?? .neutral

        switch dominant {
        case .happy:
            return "最近はポジティブな感情が多く記録されています。良い流れですね。"
        case .sad:
            return "最近は悲しい感情が目立ちます。無理せず休息を取りましょう。"
        case .angry:
            return "怒りの感情が増えています。ストレスの原因を見直してみましょう。"
        case .neutral:
            return "感情は安定しています。穏やかな日々が続いているようです。"
        default:
            return "感情の傾向が読み取りづらいですが、体調と気分の変化に注意しましょう。"
        }
    }

    func generateLabAdvice(from labs: [LabResult]) -> String {
        guard !labs.isEmpty else {
            return "検査データが見つかりませんでした。"
        }

        let latest = labs.sorted { $0.date > $1.date }.first!
        return "最新の検査結果は「\(latest.testName): \(latest.value)」です。体調管理に役立てましょう。"
    }

    func generateCorrelationAdvice(labs: [LabResult], emotions: [EmotionLog]) -> String {
        guard !labs.isEmpty, !emotions.isEmpty else {
            return "検査データまたは感情ログが不足しています。"
        }

        let labComment = generateLabAdvice(from: labs)
        let emotionComment = generateEmotionAdvice(from: emotions)
        return "\(labComment)\n\(emotionComment)"
    }

    func speakCorrelationAdvice(labs: [LabResult], emotions: [EmotionLog]) {
        let message = generateCorrelationAdvice(labs: labs, emotions: emotions)
        CompanionOverlay.shared.speak(message, emotion: .thinking)
    }

    // MARK: - リアルタイム助言生成（Emotion × Style × Language）

    func generateAdvice(emotion: EmotionType, style: CompanionStyle, lang: LanguageOption) -> String {
        let key = "\(lang.code)_\(style.rawValue)_\(emotion.rawValue)"
        return adviceDictionary[key] ?? fallbackAdvice(for: emotion, lang: lang)
    }

    private func fallbackAdvice(for emotion: EmotionType, lang: LanguageOption) -> String {
        switch (lang.code, emotion) {
        case ("ja", .sad): return "つらいときは、無理せず休んでくださいね。"
        case ("ja", .happy): return "その気持ち、大切にしてください！"
        case ("ja", .angry): return "深呼吸して、少し距離を置いてみましょう。"
        case ("en", .sad): return "It's okay to take a break when things feel heavy."
        case ("en", .happy): return "Hold on to that joy!"
        case ("en", .angry): return "Try taking a deep breath and stepping back for a moment."
        default: return "I'm here for you."
        }
    }

    private let adviceDictionary: [String: String] = [
        // 日本語例
        "ja_gentle_sad": "大丈夫ですよ。ゆっくり進めましょう。",
        "ja_playful_happy": "やったね！今日も楽しくいこう！",
        "ja_philosophical_confused": "その迷いも、きっと何かの気づきにつながりますよ。",
        // 英語例
        "en_gentle_sad": "It's okay. Let's take it slow together.",
        "en_playful_happy": "You did it! Let's keep the fun going!",
        "en_philosophical_confused": "Even confusion can lead to insight."
    ]
}
