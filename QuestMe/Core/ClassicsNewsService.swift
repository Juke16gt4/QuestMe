//
//  ClassicsNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/ClassicsNewsService.swift
//
//  🎯 ファイルの目的:
//      古典文学・思想関連ニュースの取得。
//      - 青空文庫や大学古典資料を想定。
//      - 出典必須でタイトル・要約・媒体名を付与。
//      - キャッシュTTLを管理。
//
//  🔗 依存:
//      - Foundation
//      - ClassicsModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct ClassicsNewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let published: Date
    let topic: ClassicsTopic
}

final class ClassicsNewsService: ObservableObject {
    func fetchLatest(for topic: ClassicsTopic) async -> [ClassicsNewsItem] {
        let now = Date()
        return [
            ClassicsNewsItem(title: "\(label(topic))に関する解説記事",
                             summary: "\(label(topic))に関する最近の研究や公開資料の要約です。",
                             source: "Demo Classics Source",
                             published: now,
                             topic: topic)
        ]
    }

    private func label(_ t: ClassicsTopic) -> String {
        switch t {
        case .waka: return "和歌"
        case .kanshi: return "漢詩"
        case .greekDrama: return "ギリシャ悲劇"
        case .ancientPhilosophy: return "古代哲学"
        case .other: return "古典一般"
        }
    }
}
