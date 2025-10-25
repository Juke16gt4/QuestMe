//
//  CompanionTemplates.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Companion/Templates/CompanionTemplates.swift
//
//  🎯 ファイルの目的:
//      Companion のテンプレート文言構造を定義するプロトコル。
//      - greeting, farewell, emotionLabels などを言語別に提供。
//      - TemplateManager.swift から呼び出され、UIや音声に反映。
//      - CompanionTemplates_ja.swift などの具体構造体が準拠。
//
//  🔗 依存:
//      - TemplateManager.swift（言語分岐）
//      - SupportedLanguage.swift（言語コード）
//      - CompanionGreetingEngine.swift（挨拶文）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月29日

import Foundation

protocol CompanionTemplates {
    var greeting: String { get }
    var farewell: String { get }
    var emotionLabels: [String] { get }
}
