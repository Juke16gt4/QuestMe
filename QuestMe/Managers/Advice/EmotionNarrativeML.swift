//
//  EmotionNarrativeML.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Advice/EmotionNarrativeML.swift
//
//  🎯 ファイルの目的:
//      週次の感情履歴を Core ML で要約し、語りスタイルに合わせたナラティブ文面を返す。
//      - EmotionNarrativeAdvisor プロトコルの ML 実装。
//      - スタイルは入力特徴に含める（poetic/logical/humorous/gentle/sexy）。
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

final class EmotionNarrativeML: EmotionNarrativeAdvisor {
    func narrative(for entries: [EmotionEntryInput], style: String) -> String {
        guard let model = ModelRegistry.shared.emotionModel else {
            // フォールバック：簡易サマリ
            let summary = entries.map { "\($0.dateString): \($0.feeling)" }.joined(separator: " / ")
            return "最近の記録を振り返ります。\(summary)"
        }
        // entries を文字列連結してモデルに渡す（モデル設計に応じて変更）
        let joined = entries.map { "\($0.dateString)=\($0.feeling)" }.joined(separator: ";")
        let provider = try? MLDictionaryFeatureProvider(dictionary: [
            "entries": joined,
            "style": style
        ])
        guard let input = provider,
              let out = try? model.prediction(from: input),
              let text = out.featureValue(for: "narrative")?.stringValue else {
            let summary = entries.map { "\($0.dateString): \($0.feeling)" }.joined(separator: " / ")
            return "最近の記録を振り返ります。\(summary)"
        }
        return text
    }
}
