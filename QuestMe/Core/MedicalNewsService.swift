//
//  MedicalNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/MedicalNewsService.swift
//
//  🎯 ファイルの目的:
//      医学・薬学関連ニュースの取得。
//      - PubMed RSSや厚労省の安全情報を想定。
//      - 出典必須でタイトル・要約・媒体名を付与。
//      - キャッシュTTLを管理。
//
//  🔗 依存:
//      - Foundation
//      - MedicalModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct MedicalNewsItem: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let source: String
    let published: Date
    let topic: MedicalTopic
}

final class MedicalNewsService: ObservableObject {
    func fetchLatest(for topic: MedicalTopic) async -> [MedicalNewsItem] {
        let now = Date()
        return [
            MedicalNewsItem(title: "\(label(topic))の最新研究",
                            summary: "\(label(topic))に関する最近の研究成果の要約です。",
                            source: "Demo Medical Source",
                            published: now,
                            topic: topic)
        ]
    }

    private func label(_ t: MedicalTopic) -> String {
        switch t {
        case .internalMed: return "内科"
        case .surgery: return "外科"
        case .pharmacology: return "薬理"
        case .publicHealth: return "公衆衛生"
        case .nutrition: return "栄養学"
        case .rehab: return "リハビリ"
        case .sports: return "スポーツ科学"
        case .other: return "医学一般"
        }
    }
}
