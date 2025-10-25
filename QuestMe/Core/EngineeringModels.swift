//
//  EngineeringModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/EngineeringModels.swift
//
//  🎯 ファイルの目的:
//      工学・情報科学関連のトピック分類と参照モデル。
//      - EngineeringTopic: AI/ロボティクス/材料工学/ソフトウェア工学/その他。
//      - EngineeringReference: 出典URL付きの参照情報（IEEE/ACM/大学研究所など）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

enum EngineeringTopic: String, Codable {
    case ai, robotics, materials, software, other
}

struct EngineeringReference: Codable, Hashable {
    let title: String
    let sourceURL: URL?
}
