//
//  PsychologyModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/PsychologyModels.swift
//
//  🎯 ファイルの目的:
//      心理学関連のトピック分類と参照モデル。
//      - PsychologyTopic: 認知/発達/社会/その他。
//      - PsychologyReference: 出典URL付きの参照情報。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

enum PsychologyTopic: String, Codable {
    case cognitive, developmental, social, other
}

struct PsychologyReference: Codable, Hashable {
    let title: String
    let sourceURL: URL?
}
