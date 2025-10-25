//
//  SQLiteStorageService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Storage/SQLiteStorageService.swift
//
//  🎯 ファイルの目的:
//      SQLite.swift を用いた汎用的な永続化サービス。
//      - DB初期化・テーブル作成・感情ログや設定値の保存/取得を担う。
//      - UI同期は行わず、非同期通知型で返す設計。
//      - 返り値は極力返さず、ログ出力やクロージャ通知で処理を完結させる。
//
//  🔗 連動ファイル:
//      - SQLiteEmotionLogDTO.swift（DTO定義）
//      - EmotionLogRepository.swift（ドメイン層ユースケース）
//      - CompanionEmotionManager.swift（感情成長の保存トリガ）
//
//  👤 作成者: 津村 淳一
//  📅 修正版: 2025年10月24日
//

import Foundation
import SQLite3

final class SQLiteStorageService {

    // MARK: - Singleton
    static let shared = SQLiteStorageService()

    // MARK: - Internal State
    private var db: Connection?

    // Tables
    private let emotionLogs = Table("emotion_logs")
    private let settings    = Table("settings")

    // Columns: emotion_logs
    private let id          = Expression<Int64>("id")
    private let createdAt   = Expression<String>("created_at") // ISO8601
    private let emotionType = Expression<String>("emotion_type")
    private let intensity   = Expression<Double>("intensity")
    private let note        = Expression<String?>("note")

    // Columns: settings
    private let key         = Expression<String>("key")
    private let value       = Expression<String>("value")

    private init() {
        initializeDatabaseIfNeeded()
        createTablesIfNeeded()
    }

    // MARK: - Initialization
    private func initializeDatabaseIfNeeded() {
        do {
            let url = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("QuestMe")
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            let dbURL = url.appendingPathComponent("questme.sqlite3")
            db = try Connection(dbURL.path)
            db?.busyTimeout = 2.0
        } catch {
            print("[SQLiteStorageService] DB init failed:", error.localizedDescription)
        }
    }

    private func createTablesIfNeeded() {
        guard let db else { return }
        do {
            try db.run(emotionLogs.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(createdAt)
                t.column(emotionType)
                t.column(intensity)
                t.column(note)
            })
            try db.run(settings.create(ifNotExists: true) { t in
                t.column(key, primaryKey: true)
                t.column(value)
            })
        } catch {
            print("[SQLiteStorageService] Table create failed:", error.localizedDescription)
        }
    }

    // MARK: - Commands

    func saveEmotionLog(iso8601Date: String,
                        emotion: String,
                        intensityValue: Double,
                        noteText: String? = nil,
                        completion: (() -> Void)? = nil) {
        guard let db else { return }
        do {
            let insert = emotionLogs.insert(
                createdAt <- iso8601Date,
                emotionType <- emotion,
                intensity <- intensityValue,
                note <- noteText
            )
            try db.run(insert)
            completion?()
        } catch {
            print("[SQLiteStorageService] saveEmotionLog failed:", error.localizedDescription)
        }
    }

    func upsertSetting(_ k: String, _ v: String, completion: (() -> Void)? = nil) {
        guard let db else { return }
        do {
            try db.run(settings.filter(key == k).delete())
            try db.run(settings.insert(key <- k, value <- v))
            completion?()
        } catch {
            print("[SQLiteStorageService] upsertSetting failed:", error.localizedDescription)
        }
    }

    func deleteSetting(_ k: String, completion: (() -> Void)? = nil) {
        guard let db else { return }
        do {
            try db.run(settings.filter(key == k).delete())
            completion?()
        } catch {
            print("[SQLiteStorageService] deleteSetting failed:", error.localizedDescription)
        }
    }

    // MARK: - Reads

    func fetchEmotionLogs(limit: Int = 100, notify: @escaping ([SQLiteEmotionLogDTO]) -> Void) {
        guard let db else { notify([]); return }
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [SQLiteEmotionLogDTO] = []
            do {
                for row in try db.prepare(self.emotionLogs.order(self.id.desc).limit(limit)) {
                    let dto = SQLiteEmotionLogDTO(
                        id: row[self.id],
                        createdAt: row[self.createdAt],
                        emotionType: row[self.emotionType],
                        intensity: row[self.intensity],
                        note: row[self.note]
                    )
                    results.append(dto)
                }
            } catch {
                print("[SQLiteStorageService] fetchEmotionLogs failed:", error.localizedDescription)
            }
            DispatchQueue.main.async { notify(results) }
        }
    }

    func fetchSetting(_ k: String, notify: @escaping (String?) -> Void) {
        guard let db else { notify(nil); return }
        DispatchQueue.global(qos: .utility).async {
            var v: String?
            do {
                if let row = try db.pluck(self.settings.filter(self.key == k)) {
                    v = row[self.value]
                }
            } catch {
                print("[SQLiteStorageService] fetchSetting failed:", error.localizedDescription)
            }
            DispatchQueue.main.async { notify(v) }
        }
    }
}
