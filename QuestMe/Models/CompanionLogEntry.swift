//
//  CompanionLogEntry.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/Log/CompanionLogEntry.swift
//
//  🎯 ファイルの目的:
//      - AIコンパニオンの発話ログを保存するための構造体。
//      - 吹き出し表示・感情分類・スタイル・日時を記録。
//      - CalendarHolder / LogViewer / LogExporter で使用可能。
//
//  🔗 依存:
//      - EmotionType.swift
//      - CompanionStyle.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月16日
//

import Foundation

/// コンパニオンの発話ログ
struct CompanionLogEntry: Codable, Identifiable {
    let id: UUID
    let text: String
    let style: CompanionStyle
    let emotion: EmotionType
    let date: Date

    init(text: String, style: CompanionStyle, emotion: EmotionType, timestamp: Date = Date()) {
        self.id = UUID()
        self.text = text
        self.style = style
        self.emotion = emotion
        self.date = timestamp
    }

    /// ログファイル用の1行テキスト
    var formattedLine: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return "[\(formatter.string(from: date))] (\(style.rawValue)) <\(emotion.rawValue)>: \(text)"
    }
}
