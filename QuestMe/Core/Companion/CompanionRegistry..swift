//
//  CompanionRegistry.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Companion/CompanionRegistry.swift
//
//  🎯 ファイルの目的:
//      Companion の登録・一覧・削除を管理するレジストリ。
//      - CompanionSetupView や ProfileListView などで使用。
//      - Companion の一時保持や切り替えに対応。
//      - Companion の一括削除（clear）も可能。
//
//  🔗 依存:
//      - Companion.swift（モデル定義）
//      - CompanionSetupView.swift（登録時に使用）
//      - UserAISelectionView.swift（選択時に使用）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月3日
import Foundation

public class CompanionRegistry {
    public static let shared = CompanionRegistry()
    private(set) var companions: [Companion] = []

    public func register(_ companion: Companion) {
        companions.append(companion)
    }

    public func all() -> [Companion] {
        companions
    }

    public func clear() {
        companions.removeAll()
    }
}
