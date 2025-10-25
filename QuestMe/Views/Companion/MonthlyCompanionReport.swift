//
//  MonthlyCompanionReport.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/MonthlyCompanionReport.swift
//
//  🎯 ファイルの目的:
//      ユーザーの1ヶ月分の記録（感情・食事・服薬・検査・イベント）をまとめて振り返るビュー。
//      - 感情傾向・イベント頻度・健康スコア平均などを表示。
//      - CompanionMemoryEngine.swift と連携。
//      - PDF出力や共有機能は後日拡張可能。
//
//  🔗 依存:
//      - CompanionMemoryEngine.swift
//      - NaturalLanguage（感情スコア）
//      - DialogueEntry（CompanionMemoryEngine に統合済み）
//      - CompanionSectionView.swift（Sharedに統一）
//
//  👤 製作者: 津村 淳一
//  📅 修正日: 2025年10月9日

import SwiftUI
import NaturalLanguage
import Foundation

struct MonthlyCompanionReport: View {
    let year: Int
    let month: Int
    @State private var summary: String = ""
    @State private var keywords: [String] = []
    @State private var eventCount: Int = 0
    @State private var averageScore: Int = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("📅 \(year)年\(month)月の振り返り")
                    .font(.title2)
                    .bold()

                CompanionSectionView(
                    title: "感情傾向まとめ",
                    content: AnyView(
                        Text(summary)
                    )
                )

                CompanionSectionView(
                    title: "よく使われた言葉",
                    content: AnyView(
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(keywords, id: \.self) { word in
                                Text("・\(word)")
                            }
                        }
                    )
                )

                CompanionSectionView(
                    title: "イベント件数",
                    content: AnyView(
                        Text("\(eventCount) 件")
                    )
                )

                CompanionSectionView(
                    title: "平均健康スコア",
                    content: AnyView(
                        Text("\(averageScore) 点")
                            .foregroundColor(scoreColor(averageScore))
                    )
                )

                Spacer()
            }
            .padding()
            .onAppear {
                generateMonthlyReport()
            }
        }
    }

    func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }

    func generateMonthlyReport() {
        let engine = CompanionMemoryEngine()
        let allEntries: [DialogueEntry] = engine.loadAllReplies()
        let filtered = allEntries.filter {
            guard let d = parseDate($0.date) else { return false }
            return Calendar.current.component(.year, from: d) == year &&
                   Calendar.current.component(.month, from: d) == month
        }

        summary = engine.summarizeEmotionTrend(from: filtered)
        keywords = engine.extractKeywords(from: filtered)
        eventCount = filtered.count
        averageScore = calculateAverageScore(from: filtered)
    }

    func calculateAverageScore(from entries: [DialogueEntry]) -> Int {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        var total: Double = 0
        var count = 0

        for entry in entries {
            tagger.string = entry.reply
            let scoreTag = tagger.tag(at: entry.reply.startIndex,
                                      unit: .paragraph,
                                      scheme: .sentimentScore).0
            if let scoreStr = scoreTag?.rawValue,
               let scoreVal = Double(scoreStr) {
                total += (scoreVal + 1.0) * 50 // normalize to 0–100
                count += 1
            }
        }

        return count == 0 ? 0 : Int(total / Double(count))
    }

    func parseDate(_ str: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: str)
    }
}
