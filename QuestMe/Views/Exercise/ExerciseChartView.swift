///
//  ExerciseChartView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Exercise/ExerciseChartView.swift
//
//  🎯 ファイルの目的:
//      運動履歴を週単位・月単位でグラフ表示するビュー。
//      - 日ごとの消費カロリーを棒グラフで可視化。
//      - Companion が音声で応援できる基盤を提供。
//      - ExerciseStorageManager から履歴を取得。
//
//  🔗 依存:
//      - Charts（グラフ描画）
//      - ExerciseStorageManager.swift（履歴取得）
//      - ChartEntry.swift（表示モデル）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import SwiftUI
import Charts

struct ExerciseChartView: View {
    @State private var period: ChartPeriod = .week
    @State private var entries: [ChartEntry] = []

    var body: some View {
        VStack {
            Text("運動カロリー推移")
                .font(.title2)
                .bold()
                .padding(.top)

            Picker("期間", selection: $period) {
                Text("週").tag(ChartPeriod.week)
                Text("月").tag(ChartPeriod.month)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Chart(entries) { entry in
                BarMark(
                    x: .value("日付", entry.date, unit: .day),
                    y: .value("消費カロリー", entry.calories)
                )
                .foregroundStyle(.blue)
            }
            .frame(height: 250)
            .padding()

            Spacer()
        }
        .onAppear {
            loadData()
        }
        .onChange(of: period) { _ in
            loadData()
        }
    }

    // MARK: - データ読み込み
    private func loadData() {
        let days = (period == .week) ? 7 : 30
        let all = ExerciseStorageManager.shared.fetchAll()

        // 指定期間内のデータを抽出
        let since = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let filtered = all.filter { $0.timestamp >= since }

        // 日ごとに合計
        let grouped = Dictionary(grouping: filtered) { entry in
            Calendar.current.startOfDay(for: entry.timestamp)
        }

        entries = grouped.map { (date, items) in
            ChartEntry(
                date: date,
                calories: items.reduce(0) { $0 + $1.calories }
            )
        }
        .sorted { $0.date < $1.date }
    }
}

// MARK: - 表示用モデル
enum ChartPeriod {
    case week
    case month
}

struct ChartEntry: Identifiable {
    let id = UUID()
    let date: Date
    let calories: Double
}
