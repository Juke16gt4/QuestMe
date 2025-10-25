//
//  UnifiedNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/UnifiedNewsService.swift
//
//  🎯 ファイルの目的:
//      全分野のニュース取得（資格取得含む）。
//      - トピックに応じて CertificationNewsService を呼び出す。
//      - ConversationTopic に基づき分野別ニュースを返す。
//
//  🔗 依存:
//      - Foundation
//      - CertificationNewsService.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

final class UnifiedNewsService: ObservableObject {
    private let certNews = CertificationNewsService()

    func fetchLatest(for topic: ConversationTopic) async -> [CertificationNewsItem] {
        switch topic {
        case .growth:
            return await certNews.fetchLatest(for: .internationalLanguage) // 仮：分類器と連携可
        default:
            return []
        }
    }
}
