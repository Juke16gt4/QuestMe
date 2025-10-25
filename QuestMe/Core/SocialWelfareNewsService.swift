//
//  SocialWelfareNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/SocialWelfareNewsService.swift
//
//  🎯 ファイルの目的:
//      社会福祉学関連ニュースの取得。
//      - 厚労省や国連の福祉関連ニュースを想定。
//      - 出典必須でタイトル・要約・媒体名を付与。
//      - キャッシュTTLを管理。
//
//  🔗 依存:
//      - Foundation
//      - SocialWelfareModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct SocialWelfareNewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let published: Date
    let topic: SocialWelfareTopic
}

final class SocialWelfareNewsService: ObservableObject {
    func fetchLatest(for topic: SocialWelfareTopic) async -> [SocialWelfareNewsItem] {
        let now = Date()
        return [
            SocialWelfareNewsItem(title: "\(label(topic))に関する最新動向",
                                  summary: "\(label(topic))に関する最近の政策や研究の要約です。",
                                  source: "Demo Welfare Source",
                                  published: now,
                                  topic: topic)
        ]
    }

    private func label(_ t: SocialWelfareTopic) -> String {
        switch t {
        case .elderly: return "高齢者福祉"
        case .disability: return "障害者福祉"
        case .child: return "児童福祉"
        case .poverty: return "生活保護・貧困対策"
        case .community: return "地域福祉"
        case .international: return "国際福祉"
        case .other: return "社会福祉一般"
        }
    }
}
