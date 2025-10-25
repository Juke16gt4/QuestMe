//
//  LiteratureModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/LiteratureModels.swift
//
//  🎯 ファイルの目的:
//      現代文学関連のトピック分類と参照モデル。
//      - LiteratureTopic: 小説/詩/批評/文学賞/その他。
//      - LiteratureReference: 出典URL付きの参照情報。
//
//  🔗 依存:
//      - Foundation
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月15日
//

import Foundation
import Combine

enum LiteratureTopic: String, Codable {
    case novel
    case poetry
    case criticism
    case award
    case other
}

struct LiteratureReference: Codable, Hashable {
    let title: String
    let sourceURL: URL?
}
