//
//  EconomicsNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/EconomicsNewsService.swift
//
//  🎯 ファイルの目的:
//      経済学・経営学関連ニュースの取得。
//      - IMF/OECD/日銀/経済学会誌を想定。
//      - 出典必須でタイトル・要約・媒体名を付与。
//      - キャッシュTTLを管理。
//
//  🔗 依存:
//      - Foundation
//      - EconomicsModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct EconomicsNewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let published: Date
    let topic: EconomicsTopic
}

final class EconomicsNewsService: ObservableObject {
    func fetchLatest(for topic: EconomicsTopic) async -> [EconomicsNewsItem] {
        let now = Date()
        return [
            EconomicsNewsItem(title: "\(label(topic))に関する最新動向",
                              summary: "\(label(topic))に関する最近の政策や研究の要約です。",
                              source: "Demo Economics Source",
                              published: now,
                              topic: topic)
        ]
    }

    private func label(_ t: EconomicsTopic) -> String {
        switch t {
        case .macro: return "マクロ経済"
        case .micro: return "ミクロ経済"
        case .strategy: return "経営戦略"
        case .statistics: return "統計"
        case .other: return "経済学・経営学一般"
        }
    }
}
