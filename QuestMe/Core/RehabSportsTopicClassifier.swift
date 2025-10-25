//
//  RehabSportsTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/RehabSportsTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      リハビリ/スポーツ科学分野のトピック分類。
//      - 理学療法/作業療法/運動科学/障害予防をキーワードで分類。
//      - MLモデルがあれば補強。
//
//  🔗 依存:
//      - Foundation
//      - RehabSportsModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

final class RehabSportsTopicClassifier: ObservableObject {
    func classify(_ text: String) -> RehabSportsTopic {
        let l = text.lowercased()
        if l.contains("理学療法") || l.contains("pt") { return .physicalTherapy }
        if l.contains("作業療法") || l.contains("ot") { return .occupationalTherapy }
        if l.contains("運動") || l.contains("トレーニング") || l.contains("exercise") { return .exerciseScience }
        if l.contains("障害予防") || l.contains("ケガ防止") { return .prevention }
        return .other
    }
}
