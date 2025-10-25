//
//  EngineeringTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Engineering/EngineeringTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      工学話題を分類するロジックを提供。
//      - ConversationSubject を受け取り、分類結果を文字列で返す。
//      - SwiftUI の @EnvironmentObject で注入可能。
//
//  🔗 依存/連動:
//      - EngineeringView.swift
//      - ConversationSubject.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月15日
//

import Foundation
import Combine

final class EngineeringTopicClassifier: ObservableObject {
    @Published var classification: String = ""

    func classify(_ subject: ConversationSubject) {
        let t = subject.label.lowercased()
        switch true {
        case t.contains("ai"), t.contains("人工知能"), t.contains("機械学習"):
            classification = "人工知能"
        case t.contains("ロボット"), t.contains("制御"), t.contains("自律"):
            classification = "ロボティクス"
        case t.contains("材料"), t.contains("構造"), t.contains("強度"):
            classification = "材料工学"
        case t.contains("電気"), t.contains("回路"), t.contains("半導体"):
            classification = "電気電子工学"
        default:
            classification = "その他工学"
        }
    }
}
