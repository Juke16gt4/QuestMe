//
//  MealRecord.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/MealRecord.swift
//
//  🎯 ファイルの目的:
//      食事記録のデータ構造を定義し、保存・読み込みを容易にする
//
//  🔗 依存:
//      - NutritionStorageManager.swift
//
//  👤 製作者: 津村 淳一
//  📅 作成日: 2025年10月23日
//

import UIKit

struct MealRecord: Codable {
    let mealType: String
    let userInput: String
    let calories: Double
    let protein: Double
    let fat: Double
    let carbs: Double
    let imageFileName: String
}
