//
//  ArtsMusicModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/ArtsMusicModels.swift
//
//  🎯 ファイルの目的:
//      芸術・音楽関連のトピック分類と参照モデル。
//      - ArtsMusicTopic: 美術史/音楽理論/作品解説/その他。
//      - ArtsMusicReference: 出典URL付きの参照情報（美術館・音楽学会など）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

enum ArtsMusicTopic: String, Codable {
    case artHistory, musicTheory, workAnalysis, other
}

struct ArtsMusicReference: Codable, Hashable {
    let title: String
    let sourceURL: URL?
}
