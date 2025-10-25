//
//  CertificationNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/CertificationNewsService.swift
//
//  🎯 ファイルの目的:
//      資格取得分野のニュース取得。
//      - 試験日程変更、制度改定、出題傾向などを取得。
//      - 出典必須でタイトル・要約・媒体名・日時・トピックを付与。
//      - 実運用ではRSS/JSON APIに差し替え可能。
//
//  🔗 依存:
//      - Foundation
//      - CertificationModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct CertificationNewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let published: Date
    let topic: CertificationTopic
}

final class CertificationNewsService: ObservableObject {
    func fetchLatest(for topic: CertificationTopic) async -> [CertificationNewsItem] {
        let now = Date()
        return [
            CertificationNewsItem(
                title: "\(label(topic))に関する最新情報",
                summary: "\(label(topic))に関する最近の試験制度や出題傾向の要約です。",
                source: "Demo Certification Source",
                published: now,
                topic: topic
            )
        ]
    }

    private func label(_ t: CertificationTopic) -> String {
        switch t {
        case .domesticMedical: return "国内医療資格"
        case .domesticLegal: return "国内法律資格"
        case .domesticIT: return "国内IT資格"
        case .domesticFinance: return "国内金融資格"
        case .internationalLanguage: return "国際語学資格"
        case .internationalTech: return "国際技術資格"
        case .internationalBusiness: return "国際ビジネス資格"
        case .other: return "資格一般"
        }
    }
}
