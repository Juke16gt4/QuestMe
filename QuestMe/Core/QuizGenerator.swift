//
//  QuizGenerator.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/QuizGenerator.swift
//
//  🎯 ファイルの目的:
//      資格ごとの軽量な練習問題を生成。
//      - 選択式クイズを提供。
//      - UIや音声学習に活用。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

struct QuizItem: Identifiable {
    let id = UUID()
    let question: String
    let choices: [String]
    let answerIndex: Int
    let explanation: String
}

final class QuizGenerator {
    func generate(for keyword: String) -> [QuizItem] {
        if keyword.lowercased().contains("aws") {
            return [
                QuizItem(question: "AWSの代表的なストレージサービスは？",
                         choices: ["EC2", "S3", "RDS", "Lambda"],
                         answerIndex: 1,
                         explanation: "S3はオブジェクトストレージサービスです。")
            ]
        }
        return []
    }
}
