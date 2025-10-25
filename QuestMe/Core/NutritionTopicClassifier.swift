//
//  NutritionTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/NutritionTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      栄養学分野のトピック分類。
//      - 栄養素/食事療法/サプリメントをキーワードで分類。
//      - MLモデルがあれば補強。
//
//  🔗 依存:
//      - Foundation
//      - NutritionModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

final class NutritionTopicClassifier: ObservableObject {
    func classify(_ text: String) -> NutritionTopic {
        let l = text.lowercased()
        if l.contains("栄養素") || l.contains("ビタミン") || l.contains("ミネラル") { return .nutrient }
        if l.contains("食事療法") || l.contains("糖尿病食") || l.contains("減塩") { return .dietTherapy }
        if l.contains("サプリ") || l.contains("プロテイン") || l.contains("supplement") { return .supplement }
        return .other
    }
}
