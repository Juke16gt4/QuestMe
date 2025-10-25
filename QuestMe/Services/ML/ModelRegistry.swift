//
//  ModelRegistry.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/ML/ModelRegistry.swift
//
//  🎯 ファイルの目的:
//      .mlmodel をロードし、各 ML アダプタへ供給するレジストリ。
//      - モデルの差し替え・バージョン管理・メモリ管理を集中化。
//      - 失敗時は nil を返し、ルールベースへフォールバック可能にする。
//
//  🔗 依存:
//      - CoreML
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import Foundation
import CoreML

final class ModelRegistry {
    static let shared = ModelRegistry()
    private init() {}

    // 例: 栄養アドバイスモデル
    private(set) var nutritionModel: MLModel? = {
        guard let url = Bundle.main.url(forResource: "NutritionAdviceModel", withExtension: "mlmodelc") else { return nil }
        return try? MLModel(contentsOf: url)
    }()

    // 例: 運動アドバイスモデル
    private(set) var exerciseModel: MLModel? = {
        guard let url = Bundle.main.url(forResource: "ExerciseAdviceModel", withExtension: "mlmodelc") else { return nil }
        return try? MLModel(contentsOf: url)
    }()

    // 例: 感情ナラティブモデル
    private(set) var emotionModel: MLModel? = {
        guard let url = Bundle.main.url(forResource: "EmotionNarrativeModel", withExtension: "mlmodelc") else { return nil }
        return try? MLModel(contentsOf: url)
    }()

    // 例: 意図分類モデル
    private(set) var intentModel: MLModel? = {
        guard let url = Bundle.main.url(forResource: "IntentClassifierModel", withExtension: "mlmodelc") else { return nil }
        return try? MLModel(contentsOf: url)
    }()
}
