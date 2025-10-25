//
//  SQLExportManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/ML/SQLExportManager.swift
//
//  🎯 ファイルの目的:
//      append-only の SQL を CSV/JSON にエクスポートしてモデル学習に供する。
//      - 栄養/運動/感情/会話/変更履歴の各テーブルから抽出。
//      - Create ML 用のスキーマで出力（列名・型を固定化）。
//
//  🔗 依存:
//      - Foundation
//      - 各 StorageManager（読み出し）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import Foundation

final class SQLExportManager {
    static let shared = SQLExportManager()
    private init() {}

    // 例: 栄養サマリのエクスポート（JSON）
    func exportNutritionSummary(days: Int) -> [String: Any] {
        let calories = NutritionStorageManager.shared.getCalories(forDays: days)
        let adviceProbe = NutritionStorageManager.shared.generatePFCSummary(forDays: days)
        return [
            "days": days,
            "calories": calories,
            "protein": adviceProbe.protein,
            "fat": adviceProbe.fat,
            "carbs": adviceProbe.carbs
        ]
    }

    // 例: 運動サマリのエクスポート（JSON）
    func exportExerciseSummary(days: Int) -> [String: Any] {
        let total = ExerciseStorageManager.shared.totalCalories(forDays: days)
        let all = ExerciseStorageManager.shared.fetchAll()
        let sessions = all.filter { $0.timestamp >= Calendar.current.date(byAdding: .day, value: -days, to: Date())! }
        let avgMets = sessions.isEmpty ? 0 : sessions.map { $0.mets }.reduce(0, +) / Double(sessions.count)
        return [
            "days": days,
            "totalCalories": total,
            "sessionsCount": sessions.count,
            "avgMets": avgMets
        ]
    }

    // 例: 感情履歴エクスポート
    func exportEmotionEntries(forPastDays days: Int) -> [[String: String]] {
        AdviceMemoryStorageManager.shared.fetchFeelingHistoryPublic(forPastDays: days)
    }

    // 例: 変更履歴（監査用）
    func exportChangeLogAll() -> [[String: String]] {
        ChangeLogManager().fetchAll()
    }
}
