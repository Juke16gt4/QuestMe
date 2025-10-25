//
//  NutritionLog.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/NutritionLog.swift
//
//  🎯 ファイルの目的:
//      ユーザーの食事記録を保持するモデル。
//      - 1日分の食事（朝・昼・夜・間食）を記録。
//      - DayInsightView で表示され、AIコンパニオンが栄養バランスを評価。
//      - 保存形式: Calendar/年/月/Nutrition/日.json
//
//  🔗 依存:
//      - SwiftUI（表示）
//      - JSONEncoder/Decoder（保存）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月9日

import Foundation

struct NutritionLog: Codable, Identifiable {
    var id = UUID()
    var meals: [String]    // 例: ["朝食：納豆ご飯", "昼食：サンドイッチ", "夕食：焼き魚と味噌汁"]
}
