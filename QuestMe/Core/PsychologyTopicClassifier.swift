//
//  PsychologyTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/PsychologyTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      心理学分野のトピック分類。
//      - 認知/発達/社会心理をキーワードで分類。
//      - MLモデルがあれば補強。
//
//  🔗 依存:
//      - Foundation
//      - PsychologyModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

final class PsychologyTopicClassifier: ObservableObject {
    func classify(_ text: String) -> PsychologyTopic {
        let l = text.lowercased()
        if l.contains("認知") || l.contains("記憶") || l.contains("思考") { return .cognitive }
        if l.contains("発達") || l.contains("乳児") || l.contains("青年期") { return .developmental }
        if l.contains("社会") || l.contains("集団") || l.contains("対人") { return .social }
        return .other
    }
}
