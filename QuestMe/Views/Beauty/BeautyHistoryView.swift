//
//  BeautyHistoryView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Beauty/BeautyHistoryView.swift
//
//  🎯 目的:
//      美容アドバイス履歴の時系列表示。グラフ化の土台（明度/乾燥/赤み）。
//      ・生活習慣リンクのサマリーも吹き出しで提示。
//      ・継続の励みになる可視化を行う。
//      ・共通ナビ（メイン画面へ/もどる/ヘルプ）を統合。
//
//  🔗 依存:
//      - SwiftUI, Charts
//      - BeautyStorageManager.swift
//      - CompanionSpeechBubbleView（吹き出し）
//
//  🔗 関連/連動ファイル:
//      - BeautyAdviceEngine.swift
//      - BeautyCaptureView.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-21

import SwiftUI
import Charts

struct BeautyHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var logs: [BeautyLog] = []
    @State private var bubbleText = NSLocalizedString("TrendChecking", comment: "最近の肌の傾向を確認しています…")

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CompanionSpeechBubbleView(text: bubbleText, emotion: .gentle)

                Chart {
                    ForEach(chartPoints(), id: \.id) { p in
                        LineMark(x: .value(NSLocalizedString("Date", comment: "日付"), p.date),
                                 y: .value(NSLocalizedString("Value", comment: "値"), p.value))
                            .foregroundStyle(p.color)
                            .symbol(by: .value(NSLocalizedString("Metric", comment: "項目"), p.label))
                    }
                }
                .frame(height: 240)

                ForEach(logs) { log in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(DateFormatter.localizedString(from: log.timestamp, dateStyle: .medium, timeStyle: .short))
                            .font(.headline)
                        Text(log.analysis.summary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .onAppear {
            logs = BeautyStorageManager.shared.loadHistoryLogs()
            bubbleText = summarizeTrend(logs: logs)
        }
        .navigationTitle(NSLocalizedString("BeautyAdviceHistory", comment: "美容アドバイス履歴"))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(NSLocalizedString("MainScreen", comment: "メイン画面へ")) { dismiss() }
                Button(NSLocalizedString("Back", comment: "もどる")) { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(NSLocalizedString("Help", comment: "ヘルプ")) {
                    CompanionOverlay.shared.speak(NSLocalizedString("HistoryHelp", comment: "履歴画面の説明"), emotion: .neutral)
                }
            }
        }
    }

    struct ChartPoint: Identifiable {
        var id = UUID()
        var date: Date
        var value: Double
        var label: String
        var color: Color
    }

    private func chartPoints() -> [ChartPoint] {
        var points: [ChartPoint] = []
        for log in logs {
            points.append(.init(date: log.timestamp, value: log.analysis.brightnessScore, label: NSLocalizedString("Brightness", comment: "明度"), color: .yellow))
            points.append(.init(date: log.timestamp, value: log.analysis.drynessScore, label: NSLocalizedString("Dryness", comment: "乾燥"), color: .orange))
            points.append(.init(date: log.timestamp, value: log.analysis.rednessScore, label: NSLocalizedString("Redness", comment: "赤み"), color: .red))
        }
        return points
    }

    private func summarizeTrend(logs: [BeautyLog]) -> String {
        guard !logs.isEmpty else { return NSLocalizedString("NoHistory", comment: "履歴が見つかりませんでした。") }
        let avgDry = logs.map { $0.analysis.drynessScore }.reduce(0, +) / Double(logs.count)
        if avgDry < 50 {
            return NSLocalizedString("DrynessStable", comment: "最近は乾燥傾向が落ち着いています。今のケアを続けましょう。")
        } else {
            return NSLocalizedString("DrynessContinues", comment: "乾燥が少し続いています。今夜は保湿を意識しましょう。")
        }
    }
}
