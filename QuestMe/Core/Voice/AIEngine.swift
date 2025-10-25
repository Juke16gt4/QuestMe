//
//  AIEngine.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Voice/AIEngine.swift
//
//  🎯 ファイルの目的:
//      AIエンジン列挙と表示名・既定値を提供。
//
//  🔗 依存/連動:
//      - CompanionProfile.swift（参照）
//      - CompanionSetupView.swift（初期選択）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月15日
//

import Foundation

public enum AIEngine: String, Codable, CaseIterable, Hashable {
    case copilot = "Copilot"
    case gpt     = "GPT"
    case claude  = "Claude"
    case gemini  = "Gemini"

    public var displayName: String { rawValue }
}

public extension AIEngine {
    static var defaultEngine: AIEngine { .copilot }
    var label: String { displayName }
}
