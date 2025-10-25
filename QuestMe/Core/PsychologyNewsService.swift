//
//  PsychologyNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/PsychologyNewsService.swift
//
//  🎯 ファイルの目的:
//      心理学関連ニュースの取得。
//      - APAや心理学会誌を想定。
//      - 出典必須でタイトル・要約・媒体名を付与。
//      - キャッシュTTLを管理。
//
//  🔗 依存:
//      - Foundation
//      - PsychologyModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct PsychologyNewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let published: Date
    let topic: PsychologyTopic
}

final class PsychologyNewsService: ObservableObject {
    func fetchLatest(for topic: PsychologyTopic) async -> [PsychologyNewsItem] {
        let now = Date()
        return [
            PsychologyNewsItem(title: "\(label(topic))に関する最新研究",
                               summary: "\(label(topic))に関する最近の研究成果の要約です。",
                               source: "Demo Psychology Source",
                               published: now,
                               topic: topic)
        ]
    }

    private func label(_ t: PsychologyTopic) -> String {
        switch t {
        case .cognitive: return "認知心理"
        case .developmental: return "発達心理"
        case .social: return "社会心理"
        case .other: return "心理学一般"
        }
    }
}
