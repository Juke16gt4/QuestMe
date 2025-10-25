//
//  ArtsMusicNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/ArtsMusicNewsService.swift
//
//  🎯 ファイルの目的:
//      芸術・音楽関連ニュースの取得。
//      - 美術館・音楽学会・著作権切れ資料を想定。
//      - 出典必須でタイトル・要約・媒体名を付与。
//      - キャッシュTTLを管理。
//
//  🔗 依存:
//      - Foundation
//      - ArtsMusicModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct ArtsMusicNewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let published: Date
    let topic: ArtsMusicTopic
}

final class ArtsMusicNewsService: ObservableObject {
    func fetchLatest(for topic: ArtsMusicTopic) async -> [ArtsMusicNewsItem] {
        let now = Date()
        return [
            ArtsMusicNewsItem(title: "\(label(topic))に関する解説記事",
                              summary: "\(label(topic))に関する最近の研究や公開資料の要約です。",
                              source: "Demo ArtsMusic Source",
                              published: now,
                              topic: topic)
        ]
    }

    private func label(_ t: ArtsMusicTopic) -> String {
        switch t {
        case .artHistory: return "美術史"
        case .musicTheory: return "音楽理論"
        case .workAnalysis: return "作品解説"
        case .other: return "芸術・音楽一般"
        }
    }
}
