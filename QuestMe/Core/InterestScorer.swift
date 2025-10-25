//
//  InterestScorer.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/InterestScorer.swift
//
//  🎯 ファイルの目的:
//      会話ログから資格関連の関心キーワードを抽出。
//      - シンプルな頻度ベース。
//      - 上位キーワードを返す。
//
//  🔗 連動ファイル:
//      - CertificationView.swift
//      - StorageService.swift
//
//  👤 作成者: 津村 淳一 (Junichi Tsumura)
//  📅 作成日: 2025年10月16日
//

import Foundation
import Combine

final class InterestScorer {
    func topInterests(from logs: [ConversationEntry], limit: Int = 5) -> [String] {
        var freq: [String: Int] = [:]
        for entry in logs {
            let words = entry.text.split(separator: " ").map { String($0) }
            for w in words {
                if w.contains("試験") || w.lowercased().contains("toeic") || w.contains("情報") || w.contains("薬剤師") {
                    freq[w, default: 0] += 1
                }
            }
        }
        return Array(freq.sorted { $0.value > $1.value }.prefix(limit).map { $0.key })
    }
}
