//
//  ExerciseRecord.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/ExerciseRecord.swift
//
//  🎯 ファイルの目的:
//      運動記録の入力補助モデル（UI内部利用）。
//      - UIでの一時的な状態保持に使用。
//      - 保存は ExerciseStorageManager.saveRecord(...) を使用するため、直接DBには保存しない。
//
//  🔗 依存:
//      - ExerciseActivity.swift（活動定義）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import Foundation

struct ExerciseRecord {
    let activity: ExerciseActivity
    let durationMinutes: Int
    let weightKg: Double
    let date: Date
}
