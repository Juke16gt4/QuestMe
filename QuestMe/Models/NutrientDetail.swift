//
//  NutrientDetail.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/NutrientDetail.swift
//
//  🎯 目的:
//      栄養素1項目の汎用モデル（Edamam互換キーでも自前辞書でも利用）
//
//  🔗 関連/連動:
//      - NutritionDictionaryManager.swift（辞書ロード/保存）
//      - NutritionLocalSaveManager.swift（JSON保存）
//      - NutritionDetailView.swift（表示）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月19日
//

import Foundation

public struct NutrientDetail: Codable, Hashable {
    public let label: String
    public let quantity: Double
    public let unit: String

    public init(label: String, quantity: Double, unit: String) {
        self.label = label
        self.quantity = quantity
        self.unit = unit
    }
}
