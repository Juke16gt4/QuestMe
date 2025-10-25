//
//  EconomicsTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/EconomicsTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      経済学・経営学分野のトピック分類。
//      - マクロ/ミクロ/経営戦略/統計をキーワードで分類。
//      - MLモデルがあれば補強。
//
//  🔗 依存:
//      - Foundation
//      - EconomicsModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

final class EconomicsTopicClassifier: ObservableObject {
    func classify(_ text: String) -> EconomicsTopic {
        let l = text.lowercased()
        if l.contains("gdp") || l.contains("景気") || l.contains("金融政策") || l.contains("マクロ") {
            return .macro
        }
        if l.contains("需要") || l.contains("供給") || l.contains("価格") || l.contains("ミクロ") {
            return .micro
        }
        if l.contains("経営") || l.contains("戦略") || l.contains("マーケティング") || l.contains("マネジメント") {
            return .strategy
        }
        if l.contains("統計") || l.contains("データ") || l.contains("分析") || l.contains("回帰") {
            return .statistics
        }
        return .other
    }
}
