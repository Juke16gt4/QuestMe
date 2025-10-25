//
//  AdviceTrendGraphView.swift
//  QuestMe
//
//  Created by 津村淳一 on 2025/10/05.
//

/**
 AdviceTrendGraphView
 --------------------
 目的:
 - 月次レポートにおいて、ユーザーの発話数や感情傾向をグラフで可視化する。
 - 折れ線グラフや棒グラフで日別の相談数を表示。
 - Companion の応答数や感情タイプ別の傾向も表示可能。

 格納先:
 - Swiftファイル: Views/Companion/AdviceTrendGraphView.swift
*/

import SwiftUI
import Charts

struct AdviceTrendGraphView: View {
    let entries: [AdviceEntry]

    var body: some View {
        let grouped = Dictionary(grouping: entries.filter { $0.type == "user" }) { $0.date.prefix(10) }
        let data = grouped.map { (date, items) in
            (String(date), items.count)
        }.sorted { $0.0 < $0.0 }

        Chart {
            ForEach(data, id: \.0) { date, count in
                BarMark(
                    x: .value("日付", date),
                    y: .value("相談数", count)
                )
                .foregroundStyle(.blue)
            }
        }
        .frame(height: 200)
        .padding(.bottom)
    }
}
