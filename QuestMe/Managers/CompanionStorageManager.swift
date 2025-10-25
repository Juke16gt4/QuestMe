//
//  CompanionStorageManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/CompanionStorageManager.swift
//
//  🎯 ファイルの目的:
//      CompanionProfile を保存・呼び出し・削除・切り替えするための永続管理ユーティリティ。
//      - CompanionSetupView で作製されたコンパニオンを保存。
//      - 使用中のコンパニオンを記録し、次回起動時に復元可能。
//      - append-only の原則に従い、履歴を保持。
//      - FloatingCompanionView や VoiceGenerator から呼び出される。
//      - 故人コンパニオンは最大3体まで保存可能とする。
//
//  🔗 依存:
//      - CompanionProfile.swift（モデル）
//      - UserDefaults（保存）
//      - FloatingCompanionOverlayView.swift（切り替え）
//      - DeceasedAssetStore.swift（故人アセット保存）
//
//  👤 製作者: 津村 淳一
//  📅 改変日: 2025年10月11日
//

import Foundation

final class CompanionStorageManager {
    static let shared = CompanionStorageManager()

    private let allKey = "savedCompanions"
    private let activeKey = "activeCompanion"

    // MARK: - 保存
    func save(_ profile: CompanionProfile) {
        var all = loadAll()
        all.append(profile)
        persist(all, forKey: allKey)
    }

    /// 故人コンパニオン保存（最大3体まで）
    func saveDeceased(_ profile: CompanionProfile) -> Bool {
        let deceased = loadAll().filter { $0.isDeceased }
        guard deceased.count < 3 else {
            return false
        }
        save(profile)
        return true
    }

    // MARK: - 一覧取得
    func loadAll() -> [CompanionProfile] {
        guard let data = UserDefaults.standard.data(forKey: allKey),
              let profiles = try? JSONDecoder().decode([CompanionProfile].self, from: data) else {
            return []
        }
        return profiles
    }

    func loadDeceased() -> [CompanionProfile] {
        return loadAll().filter { $0.isDeceased }
    }

    // MARK: - 削除
    func delete(_ profile: CompanionProfile) {
        var all = loadAll()
        all.removeAll { $0.id == profile.id }
        persist(all, forKey: allKey)

        // 使用中のコンパニオンだった場合は解除
        if loadActive()?.id == profile.id {
            UserDefaults.standard.removeObject(forKey: activeKey)
        }

        // 故人アセットも削除
        if profile.isDeceased {
            DeceasedAssetStore.shared.deleteAssets(for: profile.id)
        }
    }

    // MARK: - 使用中のコンパニオンを設定
    func setActive(_ profile: CompanionProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: activeKey)
        }
    }

    // MARK: - 使用中のコンパニオンを取得
    func loadActive() -> CompanionProfile? {
        guard let data = UserDefaults.standard.data(forKey: activeKey),
              let profile = try? JSONDecoder().decode(CompanionProfile.self, from: data) else {
            return nil
        }
        return profile
    }

    // MARK: - 内部保存処理
    private func persist(_ profiles: [CompanionProfile], forKey key: String) {
        if let data = try? JSONEncoder().encode(profiles) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
