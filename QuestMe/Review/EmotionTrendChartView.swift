//
//  EmotionTrendChartView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Review/EmotionTrendChartView.swift
//
//  🎯 ファイルの目的:
//      感情ログの傾向を日付別に可視化する。
//      - Swift Charts を用いて感情別のスタック棒グラフを表示。
//      - 感情の色分けと凡例表示を含む。
//      - EmotionReviewView から呼び出される予定。
//
//  🔗 依存:
//      - Models/EmotionLog.swift（emotion, date）
//      - Swift Charts（Chart, BarMark）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月10日
//

import SwiftUI
import Charts

struct EmotionCountEntry: Identifiable {
    let id = UUID()
    let date: Date
    let emotion: String
    let count: Int
}

struct EmotionTrendChartView: View {
    let entries: [EmotionCountEntry]

    var body: some View {
        VStack(alignment: .leading) {
            Text("感情の傾向")
                .font(.title2)
                .bold()
                .padding(.bottom, 8)

            Chart(entries) { entry in
                BarMark(
                    x: .value("日付", entry.date),
                    y: .value("感情数", entry.count)
                )
                .foregroundStyle(by: .value("感情", entry.emotion))
                .position(by: .value("感情", entry.emotion)) // ✅ スタック表示
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day().month())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartLegend(position: .bottom)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            .chartForegroundStyleScale([
                "嬉しい": .blue,
                "悲しい": .gray,
                "怒り": .red,
                "普通": .green
            ])
        }
        .padding()
    }
}
