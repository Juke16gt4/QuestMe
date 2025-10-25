//
//  ChangeLogManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/ChangeLogManager.swift
//
//  🎯 ファイルの目的:
//      アプリケーション全体の変更履歴（更新・削除・追加・自動補完）を記録する管理器。
//      - ChangeLog.sqlite3 に append-only 形式で保存。
//      - entityType, entityId, field, action, oldValue, newValue, reason, timestamp を記録。
//      - Companion の操作や EditSessionManager から呼び出され、履歴を一元管理。
//
//  🔗 依存:
//      - SQLite3（DB操作）
//      - EditSessionManager.swift（履歴記録）
//      - EntityOperator.swift（変更元）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import Foundation
import SQLite3

final class ChangeLogManager {
    private var db: OpaquePointer?

    // MARK: - 初期化とテーブル作成
    init() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SQL/ChangeLog.sqlite3").path
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("❌ ChangeLog DB のオープンに失敗しました")
        } else {
            createTableIfNeeded()
        }
    }

    private func createTableIfNeeded() {
        let sql = """
        CREATE TABLE IF NOT EXISTS ChangeLog (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            entityType TEXT,
            entityId TEXT,
            field TEXT,
            action TEXT,
            oldValue TEXT,
            newValue TEXT,
            reason TEXT,
            timestamp TEXT
        );
        """
        sqlite3_exec(db, sql, nil, nil, nil)
    }

    // MARK: - 履歴の追加
    func insert(userId: Int,
                entityType: String,
                entityId: String,
                field: String?,
                action: String,
                oldValue: String?,
                newValue: String?,
                reason: String) {
        
        let sql = """
        INSERT INTO ChangeLog (userId, entityType, entityId, field, action, oldValue, newValue, reason, timestamp)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, Int32(userId))
            sqlite3_bind_text(stmt, 2, entityType, -1, nil)
            sqlite3_bind_text(stmt, 3, entityId, -1, nil)
            sqlite3_bind_text(stmt, 4, field ?? "", -1, nil)
            sqlite3_bind_text(stmt, 5, action, -1, nil)
            sqlite3_bind_text(stmt, 6, oldValue ?? "", -1, nil)
            sqlite3_bind_text(stmt, 7, newValue ?? "", -1, nil)
            sqlite3_bind_text(stmt, 8, reason, -1, nil)
            sqlite3_bind_text(stmt, 9, ISO8601DateFormatter().string(from: Date()), -1, nil)
            sqlite3_step(stmt)
        } else {
            print("❌ ChangeLog の挿入に失敗しました")
        }
        sqlite3_finalize(stmt)
    }

    // MARK: - デバッグ用: 履歴の全件取得（任意）
    func fetchAll() -> [[String: String]] {
        var results: [[String: String]] = []
        let sql = "SELECT * FROM ChangeLog ORDER BY timestamp DESC;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                var row: [String: String] = [:]
                for i in 0..<sqlite3_column_count(stmt) {
                    let key = String(cString: sqlite3_column_name(stmt, i))
                    let value = String(cString: sqlite3_column_text(stmt, i))
                    row[key] = value
                }
                results.append(row)
            }
        }
        sqlite3_finalize(stmt)
        return results
    }
}
