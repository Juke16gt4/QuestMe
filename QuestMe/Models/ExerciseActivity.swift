//
//  ExerciseActivity.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/ExerciseActivity.swift
//
//  🎯 ファイルの目的:
//      METs方式に基づく運動活動の一覧を保持する構造体。
//      - Picker で選択可能な運動名と METs を提供。
//      - Companion や運動記録画面で活用される。
//      - 消費カロリー計算や励ましフレーズ生成に連動。
//
//  🔗 依存:
//      - ExerciseStorageManager.swift（記録）
//      - CompanionPhrases.swift（励まし）
//      - ExerciseRecordView.swift（UI表示）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import Foundation

struct ExerciseActivity: Identifiable, Hashable {
    let id = UUID()
    let name: String       // 活動名（例: 速歩、水泳）
    let mets: Double       // METs値
    let minutesPerEx: Int  // 1エクササイズに必要な時間（分）
}
