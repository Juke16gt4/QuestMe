//
//  UserSettingsManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/UserSettingsManager.swift
//
//  🎯 ファイルの目的:
//      ユーザー設定（音声ON/OFFなど）を管理するシングルトン。
//      - CompanionOverlay や AdviceView で使用。
//      - UserDefaults に保存可能。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 作成日: 2025年10月9日

import Foundation

final class UserSettingsManager {
    static let shared = UserSettingsManager()

    var isVoiceEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "voiceEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "voiceEnabled")
        }
    }

    private init() {}
}
