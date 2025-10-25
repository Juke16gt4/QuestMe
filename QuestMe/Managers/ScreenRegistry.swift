//
//  ScreenRegistry.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/ScreenRegistry.swift
//
//  🎯 ファイルの目的:
//      VoiceIntentRouter からの要求に応じて、対象エンティティに対応する画面を返す。
//      - entity 名に基づき、対応する画面をマッピング。
//      - presentAndFocus(field:) を持つ ScreenProtocol を返す。
//      - CompanionOverlayExpandedView や SupplementListView などと連携予定。
//
//  🔗 依存:
//      - VoiceIntent.swift（意図モデル）
//      - SwiftUI（画面遷移）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import Foundation
import SwiftUI

protocol ScreenProtocol {
    func presentAndFocus(field: String?)
}

final class ScreenRegistry {
    static let shared = ScreenRegistry()
    private init() {}

    func screen(for entity: String) -> ScreenProtocol? {
        switch entity {
        case "UserProfile":
            return UserProfileScreen()
        case "Medication":
            return MedicationScreen()
        case "Supplement":
            return SupplementScreen()
        default:
            return nil
        }
    }
}

// MARK: - 仮の画面実装（スタブ）

struct UserProfileScreen: ScreenProtocol {
    func presentAndFocus(field: String?) {
        print("📄 UserProfileScreen を表示。field=\(field ?? "nil")")
    }
}

struct MedicationScreen: ScreenProtocol {
    func presentAndFocus(field: String?) {
        print("💊 MedicationScreen を表示。field=\(field ?? "nil")")
    }
}

struct SupplementScreen: ScreenProtocol {
    func presentAndFocus(field: String?) {
        print("🍀 SupplementScreen を表示。field=\(field ?? "nil")")
    }
}
