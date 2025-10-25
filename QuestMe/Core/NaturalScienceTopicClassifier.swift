//
//  NaturalScienceTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/NaturalScienceTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      自然科学分野のトピック分類（物理/化学/生物/地学）。
//      - キーワードベースの一次分類。
//      - MLモデルがあれば補強（任意）。
//
//  🔗 依存:
//      - Foundation
//      - NaturalLanguage（任意）
//      - NaturalScienceModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine
import NaturalLanguage

final class NaturalScienceTopicClassifier: ObservableObject {
    private var nlModel: NLModel? = {
        if let url = Bundle.main.url(forResource: "NaturalScienceClassifier", withExtension: "mlmodelc") {
            return try? NLModel(contentsOf: url)
        }
        return nil
    }()

    func classify(_ text: String) -> NaturalScienceTopic {
        if let rule = ruleClassify(text) { return rule }
        if let model = nlModel, let label = model.predictedLabel(for: text) {
            return mapLabel(label)
        }
        return .other
    }

    private func ruleClassify(_ text: String) -> NaturalScienceTopic? {
        let l = text.lowercased()
        // 物理
        if l.contains("物理") || l.contains("量子") || l.contains("相対性") || l.contains("熱力学") || l.contains("physics") {
            return .physics
        }
        // 化学
        if l.contains("化学") || l.contains("合成") || l.contains("有機") || l.contains("触媒") || l.contains("chemistry") {
            return .chemistry
        }
        // 生物
        if l.contains("生物") || l.contains("進化") || l.contains("遺伝") || l.contains("細胞") || l.contains("biology") {
            return .biology
        }
        // 地学
        if l.contains("地学") || l.contains("地質") || l.contains("気象") || l.contains("惑星") || l.contains("earth science") || l.contains("geology") {
            return .earth
        }
        return nil
    }

    private func mapLabel(_ label: String) -> NaturalScienceTopic {
        switch label.lowercased() {
        case "physics": return .physics
        case "chemistry": return .chemistry
        case "biology": return .biology
        case "earth": return .earth
        default: return .other
        }
    }
}
