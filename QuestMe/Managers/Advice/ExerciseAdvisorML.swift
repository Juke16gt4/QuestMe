//
//  ExerciseAdvisorML.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Advice/ExerciseAdvisorML.swift
//
//  🎯 ファイルの目的:
//      運動サマリ（総消費カロリー・セッション数・平均 METs）を Core ML で評価し、励まし文面を生成。
//      - ExerciseAdvisor プロトコルの ML 実装。
//      - モデル欠損時はルールベースへフォールバック。
//
//  🔗 依存:
//      - Protocols/MLAdvisor.swift
//      - Services/ML/ModelRegistry.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import Foundation
import CoreML

final class ExerciseAdvisorML: ExerciseAdvisor {
    private let fallback = ExerciseAdvisorRuleBased()

    func advice(for summary: ExerciseSummaryInput) -> String {
        guard let model = ModelRegistry.shared.exerciseModel else {
            return fallback.advice(for: summary)
        }
        let provider = try? MLDictionaryFeatureProvider(dictionary: [
            "days": summary.days,
            "totalCalories": summary.totalCalories,
            "sessionsCount": summary.sessionsCount,
            "avgMets": summary.avgMets
        ])
        guard let input = provider,
              let out = try? model.prediction(from: input),
              let advice = out.featureValue(for: "advice")?.stringValue else {
            return fallback.advice(for: summary)
        }
        return advice
    }
}

final class ExerciseAdvisorRuleBased: ExerciseAdvisor {
    func advice(for summary: ExerciseSummaryInput) -> String {
        if summary.sessionsCount == 0 { return "今週はまだ運動がありません。軽いストレッチから始めてみましょう。" }
        if summary.totalCalories > Double(summary.days) * 200 { return "素晴らしい活動量です！無理なく継続していきましょう。" }
        return "良いペースです。この調子でいきましょう。"
    }
}
