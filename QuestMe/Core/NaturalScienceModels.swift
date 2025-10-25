//
//  NaturalScienceModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/NaturalScienceModels.swift
//
//  🎯 ファイルの目的:
//      自然科学（物理・化学・生物・地学）のトピック分類と参照モデル。
//      - NaturalScienceTopic: 物理/化学/生物/地学/その他。
//      - ScienceReference: 出典URL付きの参照情報（論文や学術記事）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

enum NaturalScienceTopic: String, Codable {
    case physics, chemistry, biology, earth, other
}

struct ScienceReference: Codable, Hashable {
    let title: String
    let sourceURL: URL?
}
