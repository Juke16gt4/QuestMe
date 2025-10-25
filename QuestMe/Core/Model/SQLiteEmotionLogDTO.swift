//
//  SQLiteEmotionLogDTO.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Model/SQLiteEmotionLogDTO.swift
//
//  🎯 ファイルの目的:
//      SQLiteStorageService から UI 層へ渡すデータ構造。
//      - SQLite 用の軽量 DTO。
//      - CoreData 用 DTO とは分離し、責務を明確化。
//      - EmotionLogRepository が変換を担う。
//
//  👤 作成者: 津村 淳一 (Junichi Tsumura)
//  📅 修正版: 2025年10月24日
//

import Foundation

/// SQLite 用の感情ログ DTO
struct SQLiteEmotionLogDTO {
    let id: Int64
    let createdAt: String   // ISO8601 文字列
    let emotionType: String
    let intensity: Double
    let note: String?
}
