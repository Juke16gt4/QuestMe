//
//  SQLStorageManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/SQLStorageManager.swift
//
//  🎯 ファイルの目的:
//      SQLiteファイルの自動生成と追加保存方式の初期化を担う管理器。
//      - ユーザーの健康・感情・生活記録を SQLite に追加保存形式で刻み続ける。
//      - UserProfile テーブルを生成し、insertUserProfile() により保存可能。
//      - 他のテーブル（Diseases, AlcoholRecordsなど）も拡張可能。
//
//  🔗 依存:
//      - SQLite.swift（DB操作）
//      - UserProfile.swift（保存構造）
//      - PostalCodeResolver.swift（地域推定）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import Foundation
import SQLite

final class SQLStorageManager {
    static let shared = SQLStorageManager()
    private var db: Connection?

    // MARK: - テーブルとカラム定義
    private let userProfileTable = Table("UserProfile")

    private let id = Expression<Int64>("id")
    private let userId = Expression<Int>("userId")
    private let name = Expression<String>("name")
    private let birthdate = Expression<Date>("birthdate")
    private let postalCode = Expression<String>("postalCode")
    private let region = Expression<String>("region")
    private let occupation = Expression<String>("occupation")
    private let heightCm = Expression<Double>("heightCm")
    private let weightKg = Expression<Double>("weightKg")
    private let isHealthy = Expression<Bool>("isHealthy")
    private let tobaccoType = Expression<String>("tobaccoType")
    private let cigarettesPerDay = Expression<Int>("cigarettesPerDay")
    private let timestamp = Expression<Date>("timestamp")

    // MARK: - 初期化
    private init() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbURL = path.appendingPathComponent("SQL/UserProfile.sqlite3")
        try? FileManager.default.createDirectory(at: dbURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        db = try? Connection(dbURL.path)
        createTablesIfNeeded()
    }

    // MARK: - テーブル作成
    private func createTablesIfNeeded() {
        guard let db = db else { return }
        do {
            try db.run(userProfileTable.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(userId)
                t.column(name)
                t.column(birthdate)
                t.column(postalCode)
                t.column(region)
                t.column(occupation)
                t.column(heightCm)
                t.column(weightKg)
                t.column(isHealthy)
                t.column(tobaccoType)
                t.column(cigarettesPerDay)
                t.column(timestamp, defaultValue: Date())
            })
        } catch {
            print("❌ テーブル作成失敗: \(error)")
        }
    }

    // MARK: - データ挿入
    func insertUserProfile(_ profile: UserProfile) {
        guard let db = db else { return }
        let insert = userProfileTable.insert(
            userId <- (profile.id ?? 1),
            name <- profile.name,
            birthdate <- profile.birthdate,
            postalCode <- profile.postalCode,
            region <- profile.region,
            occupation <- profile.occupation,
            heightCm <- profile.heightCm,
            weightKg <- profile.weightKg,
            isHealthy <- profile.isHealthy,
            tobaccoType <- profile.tobaccoType.rawValue,
            cigarettesPerDay <- profile.cigarettesPerDay,
            timestamp <- Date()
        )
        do {
            try db.run(insert)
        } catch {
            print("❌ データ挿入失敗: \(error)")
        }
    }
}
