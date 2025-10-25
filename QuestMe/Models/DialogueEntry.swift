//
//  DialogueEntry.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/DialogueEntry.swift
//
//  🎯 ファイルの目的:
//      ユーザーとコンパニオンの対話履歴を保持するモデル。
//      - CompanionMemoryEngine.swift, MonthlyCompanionReport.swift などで使用。
//      - 感情傾向分析、語りかけ生成、レポート表示に活用。
//      - 日付・語りかけ・返信を保持。
//      - Identifiable に準拠し、List表示に対応。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 作成日: 2025年10月9日

import Foundation

struct DialogueEntry: Identifiable, Codable {
    let id = UUID()
    let date: String       // 例: "2025-10-09"
    let advice: String     // コンパニオンの語りかけ
    let reply: String      // ユーザーの返信
}
