//
//  CertificationHistoryVisualizer.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/CertificationHistoryVisualizer.swift
//
//  🎯 ファイルの目的:
//      資格関連の過去ログを時系列で分析・可視化。
//      - 総対話数、最近の話題、初回・最新の記録日を抽出。
//      - ユーザーの学習履歴を振り返る基盤として活用。
//
//  🔗 依存:
//      - Foundation
//      - Models.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

struct CertificationLogSummary {
    let totalEntries: Int
    let recentTopics: [String]
    let firstDate: Date?
    let lastDate: Date?
}

final class CertificationHistoryVisualizer {
    func summarize(from logs: [ConversationEntry]) -> CertificationLogSummary {
        let certLogs = logs.filter { $0.topic == .growth }
        let topics = certLogs.map { $0.text }
        let first = certLogs.first?.timestamp
        let last = certLogs.last?.timestamp
        return CertificationLogSummary(
            totalEntries: certLogs.count,
            recentTopics: Array(topics.suffix(5)),
            firstDate: first,
            lastDate: last
        )
    }
}
