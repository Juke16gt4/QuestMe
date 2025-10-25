//
//  RehabSportsModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/RehabSportsModels.swift
//
//  🎯 ファイルの目的:
//      リハビリ/スポーツ科学関連のトピック分類と参照モデル。
//      - RehabSportsTopic: 理学療法/作業療法/運動科学/障害予防/その他。
//      - RehabSportsReference: 出典URL付きの参照情報。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

enum RehabSportsTopic: String, Codable {
    case physicalTherapy, occupationalTherapy, exerciseScience, prevention, other
}

struct RehabSportsReference: Codable, Hashable {
    let title: String
    let sourceURL: URL?
}
