//
//  HistoryModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/HistoryModels.swift
//
//  🎯 ファイルの目的:
//      歴史（日本史・世界史）関連のトピック分類と参照モデル。
//      - HistoryTopic: 日本史/世界史/その他。
//      - HistoryReference: 出典URL付きの参照情報。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

enum HistoryTopic: String, Codable {
    case japan, world, other
}

struct HistoryReference: Codable, Hashable {
    let title: String
    let sourceURL: URL?
}
