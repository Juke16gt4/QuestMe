//
//  ExerciseStorageManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/Exercise/ExerciseStorageManager.swift
//
//  🎯 ファイルの目的:
//      運動記録（活動名、METs、時間、体重、消費カロリー）を SQLite に追加保存する管理器。
//      - append-only 形式で記録を刻み続ける。
//      - 消費カロリーを自動計算し、日・週・月・任意日数の集計が可能。
//      - Companion が音声で応答するための集計関数も提供。
//      - 履歴表示用の全件取得機能も搭載。
//
//  🔗 依存:
//      - SQLite.swift（DB操作）
//      - CompanionOverlay.swift（音声応答）
//      - ExerciseActivity.swift（活動定義）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import Foundation
import SQLite3

// MARK: - 表示用モデル（唯一の正）
struct ExerciseEntry {
    var id: Int64
    var activityName: String
    var mets: Double
    var durationMinutes: Int
    var weightKg: Double
    var calories: Double
    var timestamp: Date
}

final class ExerciseStorageManager {
    static let shared = ExerciseStorageManager()
    private var db: Connection?

    private let table = Table("ExerciseRecords")

    private let id = Expression<Int64>("id")
    private let userId = Expression<Int>("userId")
    private let activityName = Expression<String>("activityName")
    private let mets = Expression<Double>("mets")
    private let durationMinutes = Expression<Int>("durationMinutes")
    private let weightKg = Expression<Double>("weightKg")
    private let calories = Expression<Double>("calories")
    private let timestamp = Expression<Date>("timestamp")

    private init() {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbURL = path.appendingPathComponent("SQL/ExerciseRecords.sqlite3")
        try? FileManager.default.createDirectory(at: dbURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        db = try? Connection(dbURL.path)
        createTableIfNeeded()
    }

    private func createTableIfNeeded() {
        try? db?.run(table.create(ifNotExists: true) { t in
            t.column(id, primaryKey: .autoincrement)
            t.column(userId)
            t.column(activityName)
            t.column(mets)
            t.column(durationMinutes)
            t.column(weightKg)
            t.column(calories)
            t.column(timestamp, defaultValue: Date())
        })
    }

    // MARK: - 追加保存（消費カロリー自動計算）
    func saveRecord(userId: Int, activity: ExerciseActivity, durationMinutes: Int, weightKg: Double) {
        let hours = Double(durationMinutes) / 60.0
        let kcal = activity.mets * hours * weightKg * 1.05

        let insert = table.insert(
            self.userId <- userId,
            self.activityName <- activity.name,
            self.mets <- activity.mets,
            self.durationMinutes <- durationMinutes,
            self.weightKg <- weightKg,
            self.calories <- kcal,
            self.timestamp <- Date()
        )
        try? db?.run(insert)

        CompanionOverlay.shared.speak("記録しました！今回の運動による消費カロリーは \(Int(kcal)) キロカロリーです。素晴らしいですね！")
    }

    // MARK: - 集計（任意日数）
    func totalCalories(forDays days: Int) -> Double {
        guard let db = db else { return 0 }
        let since = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let query = table.filter(timestamp >= since)
        let sum = try? db.scalar(query.select(calories.sum))
        return sum ?? 0
    }

    // MARK: - 集計（日・週・月）
    func totalCaloriesToday() -> Double {
        totalCalories(forDays: 1)
    }

    func totalCaloriesThisWeek() -> Double {
        totalCalories(forDays: 7)
    }

    func totalCaloriesThisMonth() -> Double {
        totalCalories(forDays: 30)
    }

    // MARK: - Companion 応答（任意日数）
    func speakCalories(forDays days: Int) {
        let total = totalCalories(forDays: days)
        CompanionOverlay.shared.speak("過去\(days)日間の消費カロリーは、合計で \(Int(total)) キロカロリーです。よく頑張りましたね！")
    }

    // MARK: - 全件取得（履歴表示用）
    func fetchAll() -> [ExerciseEntry] {
        guard let db = db else { return [] }
        var results: [ExerciseEntry] = []

        if let rows = try? db.prepare(table.order(timestamp.desc)) {
            for row in rows {
                let entry = ExerciseEntry(
                    id: row[id],
                    activityName: row[activityName],
                    mets: row[mets],
                    durationMinutes: row[durationMinutes],
                    weightKg: row[weightKg],
                    calories: row[calories],
                    timestamp: row[timestamp]
                )
                results.append(entry)
            }
        }
        return results
    }
}
