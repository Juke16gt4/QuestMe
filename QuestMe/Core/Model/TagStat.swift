//
//  TagStat.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Model/TagStat.swift
//
//  🎯 ファイルの目的:
//      タグごとの統計情報モデル。
//      - タグ名 (name)
//      - 出現数 (count)
//      - 正答率 (correctRate: 0〜100[%])
//      唯一の定義として、View/Serviceで共通利用する。
//
//  🔗 連動ファイル:
//      - RadarChartView.swift
//      - DashboardView.swift
//
//  👤 作成者: 津村 淳一 (Junichi Tsumura)
//  📅 作成日: 2025年10月16日
//

import Foundation

struct TagStat: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let count: Int
    let correctRate: Double
}
