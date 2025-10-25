//
//  MLAdvisor.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Protocols/MLAdvisor.swift
//
//  🎯 ファイルの目的:
//      ドメイン別の ML 推論インターフェースを定義し、差し替え可能にする。
//      - 栄養/運動/感情/意図/会話/変更履歴の各推論を抽象化。
//      - 既存のマネージャから依存注入で利用。
//      - ルールベース実装と ML 実装を並存可能にする。
//
//  🔗 依存:
//      - Foundation
//      - Models/VoiceIntent.swift（音声意図モデル）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import Foundation

// MARK: - 栄養アドバイス
public protocol NutritionAdvisor {
    func advice(for summary: NutritionSummaryInput) -> String
}

public struct NutritionSummaryInput {
    public let days: Int
    public let calories: Double
    public let protein: Double
    public let fat: Double
    public let carbs: Double

    public init(days: Int, calories: Double, protein: Double, fat: Double, carbs: Double) {
        self.days = days
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
    }
}

// MARK: - 運動アドバイス
public protocol ExerciseAdvisor {
    func advice(for summary: ExerciseSummaryInput) -> String
}

public struct ExerciseSummaryInput {
    public let days: Int
    public let totalCalories: Double
    public let sessionsCount: Int
    public let avgMets: Double

    public init(days: Int, totalCalories: Double, sessionsCount: Int, avgMets: Double) {
        self.days = days
        self.totalCalories = totalCalories
        self.sessionsCount = sessionsCount
        self.avgMets = avgMets
    }
}

// MARK: - 感情ナラティブ
public protocol EmotionNarrativeAdvisor {
    func narrative(for entries: [EmotionEntryInput], style: String) -> String
}

public struct EmotionEntryInput {
    public let dateString: String
    public let feeling: String

    public init(dateString: String, feeling: String) {
        self.dateString = dateString
        self.feeling = feeling
    }
}

// MARK: - 音声意図分類
public protocol IntentClassifier {
    func classify(command: String) -> VoiceIntent
}
// ✅ VoiceIntent の定義はここには置かない
// Models/VoiceIntent.swift の正本を利用する

// MARK: - 会話アドバイス（将来拡張）
public protocol ConversationAdvisor {
    func reply(to userMessage: String, with context: [String]) -> String
}

// MARK: - 変更履歴の異常検知（将来拡張）
public protocol ChangeLogAnomalyAdvisor {
    func detectAnomaly(from logs: [[String: String]]) -> Bool
}
