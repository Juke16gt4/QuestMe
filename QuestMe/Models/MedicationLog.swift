//
//  MedicationLog.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/MedicationLog.swift
//
//  🎯 ファイルの目的:
//      ユーザーの服薬記録を保持するモデル。
//      - 1日分の服薬内容を記録。
//      - DayInsightView で表示され、AIコンパニオンが服薬状況を確認。
//      - 保存形式: Calendar/年/月/服薬/日.json
//
//  🔗 依存:
//      - SwiftUI（表示）
//      - JSONEncoder/Decoder（保存）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月9日

import Foundation

struct MedicationLog: Codable, Identifiable {
    var id = UUID()
    var items: [String]    // 例: ["ロサルタン 50mg", "メトホルミン 500mg"]
}
