//
//  NutritionModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/NutritionModels.swift
//
//  🎯 ファイルの目的:
//      栄養学関連のトピック分類と参照モデル。
//      - NutritionTopic: 栄養素/食事療法/サプリメント/その他。
//      - NutritionReference: 出典URL付きの参照情報。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

enum NutritionTopic: String, Codable {
    case nutrient, dietTherapy, supplement, other
}

struct NutritionReference: Codable, Hashable {
    let title: String
    let sourceURL: URL?
}
