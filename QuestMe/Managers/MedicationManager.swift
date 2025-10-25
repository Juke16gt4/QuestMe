//
//  MedicationManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/MedicationManager.swift
//
//  🎯 ファイルの目的:
//      ユーザーが登録した「おくすりデータ」を SQLite に追加保存形式で記録する管理器。
//      - 登録方法（音声・処方箋QR・GS1コード・ヒートシール・手入力）を source として保持。
//      - 初回起動時に Medication.sqlite3 を自動生成し、以降は履歴を追記。
//      - AdviceLogManager や CompanionAdviceView から呼び出される。
//
//  🔗 依存:
//      - SQLite.swift（DB操作）
//      - AdviceLogManager.swift（アドバイス連携）
//      - CompanionSetupView.swift（登録）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import Foundation
import SQLite3

final class MedicationManager {

    // MARK: - Dependencies
    private let db: Connection
    private let medication = Table("Medication")

    // MARK: - Columns
    private let id = Expression<Int64>("id")
    private let userId = Expression<Int>("userId")
    private let name = Expression<String>("name")
    private let dosage = Expression<String>("dosage")
    private let source = Expression<String>("source")   // voice, qr, gs1, heatseal, manual
    private let timestamp = Expression<Date>("timestamp")

    // MARK: - Init
    init() {
        // Documents/SQL/Medication.sqlite3 を初回のみ自動生成
        let docsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sqlDir = docsURL.appendingPathComponent("SQL", isDirectory: true)
        try? FileManager.default.createDirectory(at: sqlDir, withIntermediateDirectories: true)

        let dbURL = sqlDir.appendingPathComponent("Medication.sqlite3")
        db = try! Connection(dbURL.path)

        createTableIfNeeded()
    }

    // MARK: - Table Creation
    private func createTableIfNeeded() {
        try? db.run(medication.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(userId)
            t.column(name)
            t.column(dosage)
            t.column(source)
            t.column(timestamp, defaultValue: Date())
        })
    }

    // MARK: - Insert (append-only)
    func insertMedication(userId: Int, name: String, dosage: String, source: String) {
        let insert = medication.insert(
            self.userId <- userId,
            self.name <- name,
            self.dosage <- dosage,
            self.source <- source,
            self.timestamp <- Date()
        )
        try? db.run(insert)
    }

    // MARK: - Query
    func allMedications(forUserId uid: Int) -> [Row] {
        (try? db.prepare(medication.filter(userId == uid).order(timestamp.desc)))?.map { $0 } ?? []
    }

    func latestMedication(forUserId uid: Int) -> Row? {
        try? db.pluck(medication.filter(userId == uid).order(timestamp.desc))
    }
}
