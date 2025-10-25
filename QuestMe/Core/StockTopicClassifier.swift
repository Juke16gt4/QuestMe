//
//  StockTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/StockTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      株式分野のトピック分類。
//      - 銘柄/業種/市場動向/財務指標をキーワードで分類。
//      - MLモデルがあれば補強（任意）。
//
//  🔗 依存:
//      - Foundation
//      - StockModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

final class StockTopicClassifier: ObservableObject {
    func classify(_ text: String) -> StockTopic {
        let l = text.lowercased()
        if l.contains("トヨタ") || l.contains("apple") || l.contains("任天堂") { return .company }
        if l.contains("テクノロジー") || l.contains("製薬") || l.contains("金融") { return .sector }
        if l.contains("日経平均") || l.contains("s&p") || l.contains("nasdaq") { return .market }
        if l.contains("per") || l.contains("roe") || l.contains("配当") { return .indicator }
        return .other
    }
}
