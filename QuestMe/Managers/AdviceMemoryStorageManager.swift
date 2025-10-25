//
//  AdviceMemoryStorageManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/AdviceMemoryStorageManager.swift
//
//  🎯 ファイルの目的:
//      - 感情履歴を SQLite に保存・取得する。
//      - CompanionOverlay から呼び出され、音声案内と連動して履歴を記録。
//      - AdviceMemoryStorageManager+Public.swift から拡張される。
//      - テーブル: AdviceMemoryLog(date TEXT, feeling TEXT)
//
//  🧑‍💻 作成者: 津村 淳一 (Junichi Tsumura)
//  🗓️ 制作日: 2025年10月10日 JST
//
//  🔗 依存:
//      - SQLite3（永続化）
//      - EmotionType.swift（感情タイプ）
//

import Foundation
import SQLite3

final class AdviceMemoryStorageManager {
    static let shared = AdviceMemoryStorageManager()
    private let dbFileName = "AdviceMemory.sqlite"
    private(set) var db: OpaquePointer?

    private init() {
        openDatabase()
        createTableIfNeeded()
    }

    private func openDatabase() {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbURL = dir.appendingPathComponent(dbFileName)
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("❌ SQLite DB オープン失敗")
        }
    }

    private func createTableIfNeeded() {
        let sql = """
        CREATE TABLE IF NOT EXISTS AdviceMemoryLog (
            date TEXT NOT NULL,
            feeling TEXT NOT NULL
        );
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    /// 感情を保存（ISO8601形式で日付記録）
    func saveFeeling(_ feeling: EmotionType) {
        let dateStr = ISO8601DateFormatter().string(from: Date())
        let sql = "INSERT INTO AdviceMemoryLog (date, feeling) VALUES (?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, dateStr, -1, nil)
            sqlite3_bind_text(stmt, 2, feeling.rawValue, -1, nil) // ✅ rawValue を保存
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    /// 最新の感情を取得
    func fetchLatestFeeling() -> EmotionType? {
        let sql = "SELECT feeling FROM AdviceMemoryLog ORDER BY date DESC LIMIT 1;"
        var stmt: OpaquePointer?
        var result: String?

        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                result = String(cString: sqlite3_column_text(stmt, 0))
            }
        }
        sqlite3_finalize(stmt)

        return EmotionType(rawValue: result ?? "") // ✅ CompanionEmotion → EmotionType に統一
    }
}
