//
//  EmotionClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Emotion/EmotionClassifier.swift
//
//  🎯 ファイルの目的:
//      CoreMLモデル（EmotionClassifier.mlmodel）を読み込み、テキストを感情ラベルに分類するラッパー。
//      - ユーザー入力文から感情を推定（例: "joy", "sad", "neutral"）。
//      - Companion の語り口や表情制御に活用可能。
//      - CombineやVoiceEmotionAnalyzerとの連携も視野に入れる。
//
//  🔗 依存:
//      - CoreML（モデル読み込み）
//      - EmotionDrivenResponseView.swift（使用予定）
//      - CompanionExpression.swift（表情連動）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月29日

import Foundation
import CoreML

/// CoreMLモデルを手動で読み込み、テキストを分類するラッパー
public final class EmotionClassifier {
    private let model: MLModel

    /// モデル初期化（EmotionClassifier.mlmodelc を読み込む）
    public init(configuration: MLModelConfiguration) throws {
        guard let url = Bundle.main.url(forResource: "EmotionClassifier", withExtension: "mlmodelc") else {
            throw NSError(domain: "EmotionClassifier", code: -1, userInfo: [NSLocalizedDescriptionKey: "モデルファイルが見つかりません"])
        }
        self.model = try MLModel(contentsOf: url)
    }

    /// テキストを分類し、ラベル（文字列）を返す
    /// - Parameter text: ユーザー入力文
    /// - Returns: 感情ラベル（例: "joy", "sad", "neutral"）
    public func prediction(text: String) throws -> String {
        let input = try MLDictionaryFeatureProvider(dictionary: ["text": text])
        let output = try model.prediction(from: input)
        return output.featureValue(for: "label")?.stringValue ?? "neutral"
    }
}
