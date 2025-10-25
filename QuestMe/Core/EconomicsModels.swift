//
//  EconomicsModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/EconomicsModels.swift
//
//  🎯 ファイルの目的:
//      経済学・経営学関連のトピック分類と参照モデル。
//      - EconomicsTopic: マクロ/ミクロ/経営戦略/統計/その他。
//      - EconomicsReference: 出典URL付きの参照情報（IMF/OECD/日銀など）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

enum EconomicsTopic: String, Codable {
    case macro, micro, strategy, statistics, other
}

struct EconomicsReference: Codable, Hashable {
    let title: String
    let sourceURL: URL?
}
