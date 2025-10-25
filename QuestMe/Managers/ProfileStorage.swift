//
//  ProfileStorage.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/ProfileStorage.swift
//
//  🎯 ファイルの目的:
//      CompanionProfile の保存・読み込み・削除を管理するユーティリティ。
//      - 最大5枠まで保存可能。
//      - 枠がいっぱいの場合は保存失敗を返す。
//      - 削除はユーザー操作でのみ可能。
//      - UserDefaults に JSON 形式で保存。
//
//  🔗 依存:
//      - CompanionProfile.swift（保存対象）
//      - ProfileCreationFlow.swift（保存呼び出し）
//      - ProfileListView.swift（表示）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月1日

import Foundation

class ProfileStorage {
    private static let key = "companionProfiles"
    private static let maxSlots = 5

    static func loadProfiles() -> [CompanionProfile] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let profiles = try? JSONDecoder().decode([CompanionProfile].self, from: data) else { return [] }
        return profiles
    }

    static func saveProfile(_ profile: CompanionProfile) -> Bool {
        var profiles = loadProfiles()
        guard profiles.count < maxSlots else { return false }
        profiles.insert(profile, at: 0)
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: key)
        }
        return true
    }

    static func deleteProfile(at index: Int) {
        var profiles = loadProfiles()
        guard profiles.indices.contains(index) else { return }
        profiles.remove(at: index)
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
