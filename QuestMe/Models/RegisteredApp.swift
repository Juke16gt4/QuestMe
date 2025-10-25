//
//  RegisteredApp.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/RegisteredApp.swift
//
//  🎯 ファイルの目的:
//      コックピットに表示するアプリの情報を保持するモデル。
//      - Companion が連携アプリを紹介・起動する際に使用。
//      - AppRegistry.swift により保存・復元・並び替えが可能。
//
//  🔗 依存:
//      - AppRegistry.swift（保存管理）
//      - CompanionDashboardView.swift（表示）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import Foundation

struct RegisteredApp: Codable, Identifiable {
    var id = UUID()
    var name: String
    var bundleIdentifier: String
    var installedDate: Date
    var category: AppCategory
}

/// アプリのカテゴリ分類
enum AppCategory: String, Codable {
    case health
    case productivity
    case entertainment
    case other
}
