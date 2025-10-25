//
//  CompanionCreationRoute.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Setup/CompanionCreationRoute.swift
//
//  🎯 ファイルの目的:
//      コンパニオン作成ルートの選択肢（AI生成 / 手動）を定義。
//
//  🔗 依存/連動:
//      - CompanionSetupView.swift（Picker）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月15日
//

import Foundation

public enum CompanionCreationRoute: String, CaseIterable, Identifiable, Codable {
    case aiGenerated = "AI Generated"
    case manual      = "Manual"

    public var id: String { rawValue }
}
