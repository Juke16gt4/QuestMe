//
//  HistoryNewsService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/HistoryNewsService.swift
//
//  🎯 ファイルの目的:
//      歴史関連ニュースや研究発表の取得。
//      - 国立国会図書館デジタルコレクションや歴史学会誌を想定。
//      - 出典必須でタイトル・要約・媒体名を付与。
//      - キャッシュTTLを管理。
//
//  🔗 依存:
//      - Foundation
//      - HistoryModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

final class HistoryNewsService: ObservableObject {
    @Published var articles: [String] = []

    func fetch(for subject: ConversationSubject) async {
        let keyword = subject.label.lowercased()
        switch true {
        case keyword.contains("戦争"), keyword.contains("革命"), keyword.contains("侵略"):
            articles = [
                "ナポレオン戦争の戦術分析",
                "明治維新と軍事改革",
                "冷戦期の核戦略"
            ]
        case keyword.contains("文化"), keyword.contains("宗教"), keyword.contains("思想"):
            articles = [
                "仏教伝来と日本文化",
                "ルネサンス思想の影響",
                "江戸時代の庶民文化"
            ]
        case keyword.contains("政治"), keyword.contains("制度"), keyword.contains("法律"):
            articles = [
                "憲法改正の歴史的背景",
                "江戸幕府の統治制度",
                "民主主義の発展史"
            ]
        default:
            articles = [
                "歴史全般に関する最近の研究",
                "歴史教育の課題と展望",
                "史料保存の最新技術"
            ]
        }
    }
}
