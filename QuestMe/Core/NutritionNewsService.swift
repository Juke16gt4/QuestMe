//
//  NutritionNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/NutritionNewsService.swift
//
//  🎯 ファイルの目的:
//      栄養学関連ニュースの取得。
//      - 厚労省「食事摂取基準」やWHOガイドラインを想定。
//      - 出典必須でタイトル・要約・媒体名を付与。
//      - キャッシュTTLを管理。
//
//  🔗 依存:
//      - Foundation
//      - NutritionModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct NutritionNewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let published: Date
    let topic: NutritionTopic
}

final class NutritionNewsService: ObservableObject {
    func fetchLatest(for topic: NutritionTopic) async -> [NutritionNewsItem] {
        let now = Date()
        return [
            NutritionNewsItem(title: "\(label(topic))に関する最新情報",
                              summary: "\(label(topic))に関する最近の研究やガイドラインの要約です。",
                              source: "Demo Nutrition Source",
                              published: now,
                              topic: topic)
        ]
    }

    private func label(_ t: NutritionTopic) -> String {
        switch t {
        case .nutrient: return "栄養素"
        case .dietTherapy: return "食事療法"
        case .supplement: return "サプリメント"
        case .other: return "栄養学一般"
        }
    }
}
