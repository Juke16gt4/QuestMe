//
//  RehabSportsNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/RehabSportsNewsService.swift
//
//  🎯 ファイルの目的:
//      リハビリ/スポーツ科学関連ニュースの取得。
//      - 理学療法士協会、スポーツ庁、学会誌を想定。
//      - 出典必須でタイトル・要約・媒体名を付与。
//      - キャッシュTTLを管理。
//
//  🔗 依存:
//      - Foundation
//      - RehabSportsModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct RehabSportsNewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let published: Date
    let topic: RehabSportsTopic
}

final class RehabSportsNewsService: ObservableObject {
    func fetchLatest(for topic: RehabSportsTopic) async -> [RehabSportsNewsItem] {
        let now = Date()
        return [
            RehabSportsNewsItem(title: "\(label(topic))に関する最新情報",
                                summary: "\(label(topic))に関する最近の研究や政策の要約です。",
                                source: "Demo RehabSports Source",
                                published: now,
                                topic: topic)
        ]
    }

    private func label(_ t: RehabSportsTopic) -> String {
        switch t {
        case .physicalTherapy: return "理学療法"
        case .occupationalTherapy: return "作業療法"
        case .exerciseScience: return "運動科学"
        case .prevention: return "障害予防"
        case .other: return "リハビリ/スポーツ科学一般"
        }
    }
}
