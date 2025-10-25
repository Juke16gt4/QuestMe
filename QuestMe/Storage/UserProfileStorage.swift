//
//  UserProfileStorage.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Storage/UserProfileStorage.swift
//
//  🎯 ファイルの目的:
//      UserProfile モデルを SQLite に保存・読み込みするストレージ層。
//      - append-only 原則に従い、更新時は新規レコードを INSERT。
//      - 最新プロフィールは lastUpdated の降順で取得。
//      - 履歴一覧を取得し、ユーザーが過去の状態を振り返れるようにする。
//      - ProfileEditView / UserProfileView の保存処理と接続。
//
//  🔗 依存:
//      - SQLite3
//      - UserProfile.swift（モデル）
//      - Supplement.swift
//      - TobaccoType.swift
//
//  👤 製作者: 津村 淳一
//  📅 修正版: 2025年10月24日（email カラム対応）
//

import Foundation
import SQLite3

final class UserProfileStorage {
    static let shared = UserProfileStorage()
    private let dbPath = "UserProfile.sqlite3"
    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createTableIfNeeded()
    }

    // MARK: - DB接続
    private func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("SQL")
        try? FileManager.default.createDirectory(at: fileURL, withIntermediateDirectories: true)
        let dbURL = fileURL.appendingPathComponent(dbPath)

        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("❌ データベースを開けませんでした")
        }
    }

    // MARK: - テーブル作成
    private func createTableIfNeeded() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS UserProfile (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            name TEXT,
            email TEXT,
            birthdate REAL,
            postalCode TEXT,
            region TEXT,
            heightCm REAL,
            weightKg REAL,
            isHealthy INTEGER,
            diseases TEXT,
            occupation TEXT,
            supplements TEXT,
            tobaccoType TEXT,
            cigarettesPerDay INTEGER,
            lastUpdated REAL
        );
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    // MARK: - 保存（append-only）
    func save(_ profile: UserProfile) {
        let insertQuery = """
        INSERT INTO UserProfile
        (title, name, email, birthdate, postalCode, region, heightCm, weightKg, isHealthy, diseases, occupation, supplements, tobaccoType, cigarettesPerDay, lastUpdated)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, insertQuery, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (profile.title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (profile.name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (profile.email as NSString).utf8String, -1, nil) // email
            sqlite3_bind_double(stmt, 4, profile.birthdate.timeIntervalSince1970)
            sqlite3_bind_text(stmt, 5, (profile.postalCode as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (profile.region as NSString).utf8String, -1, nil)
            sqlite3_bind_double(stmt, 7, profile.heightCm)
            sqlite3_bind_double(stmt, 8, profile.weightKg)
            sqlite3_bind_int(stmt, 9, profile.isHealthy ? 1 : 0)

            let diseasesJSON = try? JSONEncoder().encode(profile.diseases)
            sqlite3_bind_text(stmt, 10, (String(data: diseasesJSON ?? Data(), encoding: .utf8)! as NSString).utf8String, -1, nil)

            sqlite3_bind_text(stmt, 11, (profile.occupation as NSString).utf8String, -1, nil)

            let supplementsJSON = try? JSONEncoder().encode(profile.supplements)
            sqlite3_bind_text(stmt, 12, (String(data: supplementsJSON ?? Data(), encoding: .utf8)! as NSString).utf8String, -1, nil)

            sqlite3_bind_text(stmt, 13, (profile.tobaccoType.rawValue as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 14, Int32(profile.cigarettesPerDay))
            sqlite3_bind_double(stmt, 15, Date().timeIntervalSince1970)

            if sqlite3_step(stmt) == SQLITE_DONE {
                print("✅ UserProfile 保存成功")
            } else {
                print("❌ UserProfile 保存失敗")
            }
        }
        sqlite3_finalize(stmt)
    }

    // MARK: - 最新プロフィールを取得
    func loadLatest() -> UserProfile? {
        let query = "SELECT * FROM UserProfile ORDER BY lastUpdated DESC LIMIT 1;"
        var stmt: OpaquePointer?
        var profile: UserProfile?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                profile = decodeProfile(stmt: stmt)
            }
        }
        sqlite3_finalize(stmt)
        return profile
    }

    // MARK: - 全履歴を取得
    func loadAll() -> [UserProfile] {
        let query = "SELECT * FROM UserProfile ORDER BY lastUpdated DESC;"
        var stmt: OpaquePointer?
        var profiles: [UserProfile] = []

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let profile = decodeProfile(stmt: stmt)
                profiles.append(profile)
            }
        }
        sqlite3_finalize(stmt)
        return profiles
    }

    // MARK: - デコード処理
    private func decodeProfile(stmt: OpaquePointer?) -> UserProfile {
        let title = String(cString: sqlite3_column_text(stmt, 1))
        let name = String(cString: sqlite3_column_text(stmt, 2))
        let email = String(cString: sqlite3_column_text(stmt, 3)) // email
        let birthdate = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 4))
        let postalCode = String(cString: sqlite3_column_text(stmt, 5))
        let region = String(cString: sqlite3_column_text(stmt, 6))
        let heightCm = sqlite3_column_double(stmt, 7)
        let weightKg = sqlite3_column_double(stmt, 8)
        let isHealthy = sqlite3_column_int(stmt, 9) == 1

        let diseasesJSON = String(cString: sqlite3_column_text(stmt, 10))
        let diseases = (try? JSONDecoder().decode([String].self, from: diseasesJSON.data(using: .utf8)!)) ?? []

        let occupation = String(cString: sqlite3_column_text(stmt, 11))

        let supplementsJSON = String(cString: sqlite3_column_text(stmt, 12))
        let supplements = (try? JSONDecoder().decode([Supplement].self, from: supplementsJSON.data(using: .utf8)!)) ?? []

        let tobaccoType = TobaccoType(rawValue: String(cString: sqlite3_column_text(stmt, 13))) ?? .none
        let cigarettesPerDay = Int(sqlite3_column_int(stmt, 14))
        let lastUpdated = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 15))

        return UserProfile(
            id: Int(sqlite3_column_int(stmt, 0)),
            title: title,
            name: name,
            email: email,
            birthdate: birthdate,
            postalCode: postalCode,
            region: region,
            heightCm: heightCm,
            weightKg: weightKg,
            isHealthy: isHealthy,
            diseases: diseases,
            lastUpdated: lastUpdated,
            occupation: occupation,
            supplements: supplements,
            tobaccoType: tobaccoType,
            cigarettesPerDay: cigarettesPerDay
        )
    }
}
