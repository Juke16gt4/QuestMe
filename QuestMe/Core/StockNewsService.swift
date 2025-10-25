//
//  StockNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/StockNewsService.swift
//
//  🎯 ファイルの目的:
//      株式関連ニュースの取得。
//      - 出典必須でタイトル・要約・媒体名・日時・トピックを付与。
//      - キャッシュTTLを管理。
//      - 実運用ではRSS/JSON APIに差し替え可能。
//
//  🔗 依存:
//      - Foundation
//      - StockModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct StockNewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let published: Date
    let topic: StockTopic
}

final class StockNewsService: ObservableObject {
    func fetchLatest(for topic: StockTopic) async -> [StockNewsItem] {
        let now = Date()
        return [
            StockNewsItem(title: "\(label(topic))に関する最新情報",
                          summary: "\(label(topic))に関する最近の動向や分析の要約です。",
                          source: "Demo Stock Source",
                          published: now,
                          topic: topic)
        ]
    }

    private func label(_ t: StockTopic) -> String {
        switch t {
        case .company: return "個別銘柄"
        case .sector: return "業種別"
        case .market: return "市場動向"
        case .indicator: return "財務指標"
        case .other: return "株式一般"
        }
    }
}
