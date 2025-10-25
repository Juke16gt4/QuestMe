//
//  MockExamService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/MockExamService.swift
//
//  🎯 ファイルの目的:
//      資格ごとの模擬試験を生成。
//      - 本番形式の選択問題を提供。
//      - UIや振り返り分析に活用。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

struct MockExamQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctIndex: Int
}

final class MockExamService: ObservableObject {
    func generate(for certification: String) -> [MockExamQuestion] {
        switch certification.lowercased() {
        case "toefl":
            return [
                MockExamQuestion(question: "TOEFLのReadingセクションは何分？", options: ["30分", "60分", "90分", "45分"], correctIndex: 1),
                MockExamQuestion(question: "Listeningで流れるのは？", options: ["講義", "会話", "ニュース", "両方"], correctIndex: 3)
            ]
        case "薬剤師":
            return [
                MockExamQuestion(question: "薬剤師国家試験の科目数は？", options: ["3", "5", "7", "9"], correctIndex: 2)
            ]
        default:
            return []
        }
    }
}
