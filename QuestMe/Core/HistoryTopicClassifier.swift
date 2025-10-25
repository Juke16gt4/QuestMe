//
//  HistoryTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/HistoryTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      歴史分野のトピック分類。
//      - 日本史/世界史をキーワードで分類。
//      - MLモデルがあれば補強。
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

final class HistoryTopicClassifier: ObservableObject {
    @Published var classification: String = ""

    func classify(_ subject: ConversationSubject) {
        let t = subject.label.lowercased()
        switch true {
        case t.contains("戦争"), t.contains("革命"), t.contains("侵略"):
            classification = "軍事史"
        case t.contains("文化"), t.contains("宗教"), t.contains("思想"):
            classification = "文化史"
        case t.contains("政治"), t.contains("制度"), t.contains("法律"):
            classification = "政治史"
        default:
            classification = "一般史"
        }
    }
}
