//
//  StockModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/StockModels.swift
//
//  🎯 ファイルの目的:
//      株式関連のトピック分類と参照モデル。
//      - StockTopic: 銘柄/業種/市場動向/財務指標/その他。
//      - StockReference: 出典URL付きの参照情報（証券会社・金融機関・公式資料など）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

enum StockTopic: String, Codable {
    case company, sector, market, indicator, other
}

struct StockReference: Codable, Hashable {
    let title: String
    let sourceURL: URL?
}
