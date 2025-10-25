//
//  AppRegistry.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/AppRegistry.swift
//
//  🎯 ファイルの目的:
//      登録されたアプリ情報（RegisteredApp）を UserDefaults に保存・復元する管理器。
//      - JSON 形式でエンコード／デコードし、軽量かつ安全に永続化。
//      - Companion や ProfileView から呼び出され、起動履歴や連携アプリを管理。
//      - AppIcon 表示や起動頻度による並び替えにも対応可能。
//
//  🔗 依存:
//      - RegisteredApp.swift（name, bundleIdentifier, installedDate, category）
//      - UserDefaults（保存）
//      - CompanionProfile.swift（連携）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日
//

import UIKit

struct AppRegistry {
    static let key = "questme.registered.apps"

    // MARK: - 保存
    static func save(_ apps: [RegisteredApp]) {
        let data = try? JSONEncoder().encode(apps)
        UserDefaults.standard.set(data, forKey: key)
    }

    // MARK: - 復元
    static func load() -> [RegisteredApp] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let apps = try? JSONDecoder().decode([RegisteredApp].self, from: data) else {
            return []
        }
        return apps
    }

    // MARK: - 追加（重複を避けて）
    static func add(_ app: RegisteredApp) {
        var current = load()
        if !current.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }) {
            current.append(app)
            save(current)
        }
    }

    // MARK: - 削除
    static func remove(bundleId: String) {
        let filtered = load().filter { $0.bundleIdentifier != bundleId }
        save(filtered)
    }

    // MARK: - 全削除
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
