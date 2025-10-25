//
//  InsightReviewView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Review/InsightReviewView.swift
//
//  🎯 ファイルの目的:
//      感情履歴・検査値・アドバイス・相関コメント・グラフを統合表示するレビュー画面。
//      - EmotionTrendChartView に履歴を渡してグラフ表示。
//      - PDFレポート生成や CompanionOverlay の語りとも連携予定。
//
//  🔗 依存:
//      - EmotionTrendChartView.swift（グラフ表示）
//      - EmotionReportGenerator.swift（PDF生成）
//      - ChartImageManager.swift（グラフ画像パス）
//      - EmotionLog.swift（感情タイプ）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月10日
//

import SwiftUI

struct InsightReviewView: View {
    let rawHistory: [[String: String]] // 例: ["date": "2025-10-09T10:00:00Z", "emotion": "嬉しい", "count": "3"]

    var body: some View {
        let emotionEntries: [EmotionCountEntry] = rawHistory.compactMap { dict in
            guard let dateStr = dict["date"],
                  let emotion = dict["emotion"],
                  let countStr = dict["count"],
                  let count = Int(countStr),
                  let date = ISO8601DateFormatter().date(from: dateStr) else {
                return nil
            }
            return EmotionCountEntry(date: date, emotion: emotion, count: count)
        }

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("感情レビュー")
                    .font(.title)
                    .bold()

                EmotionTrendChartView(entries: emotionEntries)

                // 他のレビュー要素（検査値、アドバイス、相関コメントなど）をここに追加予定
            }
            .padding()
        }
    }
}
