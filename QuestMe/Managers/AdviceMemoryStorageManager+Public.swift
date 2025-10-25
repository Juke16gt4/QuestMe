//
//  AdviceMemoryStorageManager+Public.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/AdviceMemoryStorageManager+Public.swift
//
//  🎯 ファイルの目的:
//      ML 用に感情履歴を公開取得する関数を追加する。
//      - fetchFeelingHistoryPublic(forPastDays:) を提供。
//      - EmotionEntryInput へ変換しやすい形式を返す。
//
//  🔗 依存:
//      - AdviceMemoryStorageManager.swift（dbアクセス）
//      - AdviceFeelingEntry.swift（履歴構造体）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import Foundation
import SQLite3

extension AdviceMemoryStorageManager {
    public func fetchFeelingHistoryPublic(forPastDays days: Int) -> [[String: String]] {
        let since = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let sinceStr = ISO8601DateFormatter().string(from: since)
        let sql = "SELECT date, feeling FROM AdviceMemoryLog WHERE date >= ? ORDER BY date ASC;"
        var stmt: OpaquePointer?
        var results: [[String: String]] = []

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, sinceStr, -1, nil)
            while sqlite3_step(stmt) == SQLITE_ROW {
                let dateStr = String(cString: sqlite3_column_text(stmt, 0))
                let feeling = String(cString: sqlite3_column_text(stmt, 1))
                results.append(["date": dateStr, "feeling": feeling])
            }
        }
        sqlite3_finalize(stmt)
        return results
    }
}
