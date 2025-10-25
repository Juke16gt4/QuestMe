//
//  NaturalScienceNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/NaturalScienceNewsService.swift
//
//  🎯 ファイルの目的:
//      自然科学分野のニュース/RSS取得（Nature/Science/大学研究所などを想定）。
//      - タイトル・要約・媒体名・日時・トピックを付与（出典必須）。
//      - 簡易キャッシュ（TTL: 24時間）。
//      - 取得失敗時はフェイルセーフで一般情報を返す。
//
//  🔗 依存:
//      - Foundation
//      - NaturalScienceModels.swift
//
//  👤 修正者: 津村 淳一
//  📅 修正日: 2025年10月17日
//

import Foundation
import Combine

/// 自然科学ニュース記事モデル
struct NaturalScienceNewsItem: Identifiable, Codable, Hashable {
    var id: UUID
    let title: String
    let summary: String
    let source: String
    let published: Date
    let topic: NaturalScienceTopic

    init(id: UUID = UUID(),
         title: String,
         summary: String,
         source: String,
         published: Date,
         topic: NaturalScienceTopic) {
        self.id = id
        self.title = title
        self.summary = summary
        self.source = source
        self.published = published
        self.topic = topic
    }
}

/// 自然科学ニュース取得サービス
final class NaturalScienceNewsService: ObservableObject {
    @Published private(set) var cache: [NaturalScienceTopic: (items: [NaturalScienceNewsItem], fetchedAt: Date)] = [:]
    private let ttl: TimeInterval = 60 * 60 * 24 // 24時間

    private let feeds: [NaturalScienceTopic: URL] = [
        .physics: URL(string: "https://example.com/science/physics.rss")!,
        .chemistry: URL(string: "https://example.com/science/chemistry.rss")!,
        .biology: URL(string: "https://example.com/science/biology.rss")!,
        .earth: URL(string: "https://example.com/science/earth.rss")!,
        .other: URL(string: "https://example.com/science/general.rss")!
    ]

    /// ニュースを取得（副作用型）
    func fetchLatest(for topic: NaturalScienceTopic) async -> [NaturalScienceNewsItem] {
        let now = Date()
        if let cached = cache[topic], now.timeIntervalSince(cached.fetchedAt) < ttl {
            return cached.items
        }
        guard let url = feeds[topic] else { return fallback(topic: topic) }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let items = parseRSS(data: data, topic: topic)
            cache[topic] = (items, now)
            return items.isEmpty ? fallback(topic: topic) : items
        } catch {
            return fallback(topic: topic)
        }
    }

    // ダミーRSSパーサ：実運用はXML解析に置換
    private func parseRSS(data: Data, topic: NaturalScienceTopic) -> [NaturalScienceNewsItem] {
        let now = Date()
        return [
            NaturalScienceNewsItem(
                title: "\(label(topic))の最新研究トピック",
                summary: "\(label(topic))に関する最近の主要成果の要約です。",
                source: "Science RSS Source",
                published: now,
                topic: topic
            )
        ]
    }

    private func fallback(topic: NaturalScienceTopic) -> [NaturalScienceNewsItem] {
        [
            NaturalScienceNewsItem(
                title: "\(label(topic))の一般的な解説",
                summary: "現在詳細を取得中です。一次情報（論文・公式記事）に基づく確認を推奨します。",
                source: "System",
                published: Date(),
                topic: topic
            )
        ]
    }

    private func label(_ t: NaturalScienceTopic) -> String {
        switch t {
        case .physics: return "物理"
        case .chemistry: return "化学"
        case .biology: return "生物"
        case .earth: return "地学"
        case .other: return "自然科学一般"
        }
    }
}
