//
//  LiteratureNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/LiteratureNewsService.swift
//
//  🎯 ファイルの目的:
//      現代文学関連ニュースの取得。
//      - 文芸誌、文学賞公式サイト、新聞文芸欄を想定。
//      - 出典必須でタイトル・要約・媒体名を付与。
//      - トピックごとに記事を切り替え。
//      - キャッシュTTLを管理。
//
//  🔗 依存:
//      - Foundation
//      - Combine   ← ★ 追加
//      - LiteratureModels.swift
//
//  👤 作成者: 津村 淳一
//  📅 改変日: 2025年10月15日
//

import Foundation
import Combine   // ← ★ これを追加

struct LiteratureNewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let published: Date
    let topic: LiteratureTopic
}

final class LiteratureNewsService: ObservableObject {
    @Published private(set) var cache: [LiteratureTopic: (items: [LiteratureNewsItem], fetchedAt: Date)] = [:]
    private let ttl: TimeInterval = 60 * 60 // 1時間キャッシュ

    func fetchLatest(for topic: LiteratureTopic) async -> [LiteratureNewsItem] {
        let now = Date()
        if let cached = cache[topic], now.timeIntervalSince(cached.fetchedAt) < ttl {
            return cached.items
        }

        let items: [LiteratureNewsItem]
        switch topic {
        case .novel:
            items = [
                LiteratureNewsItem(
                    title: "新進作家による長編小説が話題",
                    summary: "現代社会をテーマにした長編小説が文芸誌で注目を集めています。",
                    source: "Demo Literature Magazine",
                    published: now,
                    topic: .novel
                )
            ]
        case .poetry:
            items = [
                LiteratureNewsItem(
                    title: "現代詩の新しい潮流",
                    summary: "若手詩人による詩集が文学賞候補に選ばれました。",
                    source: "Demo Poetry Journal",
                    published: now,
                    topic: .poetry
                )
            ]
        case .criticism:
            items = [
                LiteratureNewsItem(
                    title: "文学批評の最新動向",
                    summary: "批評家による現代文学の分析が学術誌に掲載されました。",
                    source: "Demo Criticism Review",
                    published: now,
                    topic: .criticism
                )
            ]
        case .award:
            items = [
                LiteratureNewsItem(
                    title: "文学賞の受賞作が発表",
                    summary: "今年の主要文学賞の受賞作が決定しました。",
                    source: "Demo Award Committee",
                    published: now,
                    topic: .award
                )
            ]
        case .other:
            items = [
                LiteratureNewsItem(
                    title: "現代文学の一般的な話題",
                    summary: "文芸誌や新聞で取り上げられた最近の文学動向です。",
                    source: "Demo General Source",
                    published: now,
                    topic: .other
                )
            ]
        }

        cache[topic] = (items, now)
        return items
    }
}
