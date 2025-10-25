//
//  EmotionClassifierEngine.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Engines/EmotionClassifierEngine.swift
//
//  🎯 ファイルの目的:
//      - ユーザー発話から EmotionType を推定する。
//      - 言語別 JSON ファイルから感情語辞書を読み込む。
//      - CompanionExpandedView / LogEntry / AdviceEngine で使用。
//
//  🔗 依存:
//      - EmotionType.swift
//      - CompanionStyle.swift
//      - LanguageOption.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月16日
//

import Foundation

struct EmotionClassifierEngine {
    static let shared = EmotionClassifierEngine()

    /// 発話内容から EmotionType を推定（辞書ベース）
    func classifyEmotion(from text: String, style: CompanionStyle, lang: LanguageOption) -> EmotionType {
        let lowered = text.lowercased()
        let keywords = loadEmotionKeywords(for: lang.code)

        for (emotion, words) in keywords {
            if words.contains(where: { lowered.contains($0) }) {
                return emotion
            }
        }

        // キーワードが見つからない場合はスタイルに基づく感情を返す
        return style.toEmotion()
    }

    /// 言語別 JSON ファイルから感情語辞書を読み込む
    private func loadEmotionKeywords(for langCode: String) -> [EmotionType: [String]] {
        guard let url = Bundle.main.url(forResource: "emotion_keywords_\(langCode)", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let rawDict = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            print("⚠️ 感情語辞書の読み込み失敗: emotion_keywords_\(langCode).json")
            return [:]
        }

        var result: [EmotionType: [String]] = [:]
        for (key, words) in rawDict {
            if let emotion = EmotionType(rawValue: key) {
                result[emotion] = words.map { $0.lowercased() }
            }
        }
        return result
    }
}
