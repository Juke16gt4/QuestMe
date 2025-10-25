//
//  CompanionMemoryChartView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionMemoryChartView.swift
//
//  🎯 ファイルの目的:
//      ユーザーの過去のコンパニオン対話履歴（DialogueEntry）から感情スコアを抽出し、折れ線グラフで可視化するビュー。
//      - NaturalLanguage を使って感情スコア（sentimentScore）を算出。
//      - CompanionMemoryEngine.swift から履歴を取得。
//      - 月別・週別の感情推移を視覚化予定（現在は全履歴対象）。
//
//  🔗 依存:
//      - CompanionMemoryEngine.swift（履歴取得）
//      - DialogueEntry.swift（履歴モデル）
//      - NaturalLanguage（感情スコア抽出）
//      - Charts（Swift Charts）
//      - NLTagger.Options（明示的に定義）
//
//  👤 製作者: 津村 淳一
//  📅 修正日: 2025年10月9日

import SwiftUI
import Charts
import NaturalLanguage

struct SentimentScoreEntry: Identifiable {
    let id = UUID()
    let date: Date
    let score: Int
}

struct CompanionMemoryChartView: View {
    @State private var scores: [SentimentScoreEntry] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("🧠 コンパニオンとの感情履歴")
                .font(.title2)
                .bold()

            if scores.isEmpty {
                Text("履歴が見つかりませんでした。")
                    .foregroundColor(.gray)
            } else {
                Chart {
                    ForEach(scores) { entry in
                        LineMark(
                            x: .value("日付", entry.date),
                            y: .value("感情スコア", entry.score)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(entry.score >= 80 ? .green : (entry.score >= 60 ? .orange : .red))
                    }
                }
                .frame(height: 240)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day().month())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            loadScores()
        }
    }

    func loadScores() {
        let engine = CompanionMemoryEngine()
        let entries = engine.loadAllReplies()
        var result: [SentimentScoreEntry] = []

        let tagger = NLTagger(tagSchemes: [.sentimentScore])

        for entry in entries {
            guard let date = parseDate(entry.date) else { continue }
            tagger.string = entry.reply

            let tag = tagger.tag(at: entry.reply.startIndex,
                                 unit: NLTokenUnit.paragraph,
                                 scheme: NLTagScheme.sentimentScore).0

            if let raw = tag?.rawValue,
               let val = Double(raw) {
                let normalized = Int((val + 1.0) * 50) // -1.0〜1.0 → 0〜100
                result.append(SentimentScoreEntry(date: date, score: normalized))
            }
        }

        scores = result.sorted(by: { $0.date < $1.date })
    }

    func parseDate(_ str: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: str)
    }
}
