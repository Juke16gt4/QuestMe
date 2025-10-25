//
//  NutritionAdvisorML.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Advice/NutritionAdvisorML.swift
//
//  🎯 ファイルの目的:
//      栄養サマリ（PFC・カロリー）を Core ML モデルに渡し、文面アドバイスを生成する。
//      - NutritionAdvisor プロトコルの ML 実装。
//      - モデル欠損時はルールベースにフォールバック。
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

final class NutritionAdvisorML: NutritionAdvisor {
    private let fallback = NutritionAdvisorRuleBased()

    func advice(for summary: NutritionSummaryInput) -> String {
        guard let model = ModelRegistry.shared.nutritionModel else {
            return fallback.advice(for: summary)
        }
        // 仮の入出力。実際は auto-generated クラスを使用（例: NutritionAdviceModelInput/Output）
        let provider = try? MLDictionaryFeatureProvider(dictionary: [
            "days": summary.days,
            "calories": summary.calories,
            "protein": summary.protein,
            "fat": summary.fat,
            "carbs": summary.carbs
        ])
        guard let input = provider,
              let out = try? model.prediction(from: input),
              let advice = out.featureValue(for: "advice")?.stringValue else {
            return fallback.advice(for: summary)
        }
        return advice
    }
}

// ルールベース（フォールバック）
final class NutritionAdvisorRuleBased: NutritionAdvisor {
    func advice(for summary: NutritionSummaryInput) -> String {
        if summary.protein < Double(summary.days) * 40 { return "タンパク質が不足気味です。もう少し意識して摂りましょう。" }
        if summary.fat > Double(summary.days) * 80 { return "脂質が多めです。揚げ物を控えると良いかもしれません。" }
        if summary.carbs > Double(summary.days) * 300 { return "炭水化物が多めです。バランスを意識しましょう。" }
        return "栄養バランスは概ね良好です！"
    }
}
