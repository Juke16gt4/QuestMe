//
//  WeeklyCompanionReport.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/WeeklyCompanionReport.swift
//
//  🎯 ファイルの目的:
//      ユーザーの1週間分の対話履歴（DialogueEntry）から感情傾向とスコアを抽出し、週次レポートとして表示。
//      - CompanionMemoryEngine.swift から履歴を取得。
//      - NaturalLanguage を使って感情スコアを算出。
//      - 今後 PDF出力や共有機能に拡張予定。
//
//  🔗 依存:
//      - CompanionMemoryEngine.swift
//      - DialogueEntry.swift
//      - NaturalLanguage（感情分析）
//
//  👤 製作者: 津村 淳一
//  📅 修正日: 2025年10月9日

import SwiftUI
import NaturalLanguage

struct WeeklyCompanionReport: View {
    let startDate: Date
    @State private var summary: String = ""
    @State private var averageScore: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("📅 \(formattedWeek(startDate)) の週次レポート")
                .font(.title2)
                .bold()

            Text("🧠 感情傾向")
                .font(.headline)
            Text(summary)

            Text("💚 平均感情スコア")
                .font(.headline)
            Text("\(averageScore) 点")
                .foregroundColor(scoreColor(averageScore))

            Spacer()
        }
        .padding()
        .onAppear {
            generateWeeklyReport()
        }
    }

    func formattedWeek(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年MM月dd日"
        let end = Calendar.current.date(byAdding: .day, value: 6, to: date)!
        return "\(f.string(from: date))〜\(f.string(from: end))"
    }

    func generateWeeklyReport() {
        let engine = CompanionMemoryEngine()
        let allEntries = engine.loadAllReplies()
        let filtered = allEntries.filter {
            guard let d = parseDate($0.date) else { return false }
            return Calendar.current.isDate(d, equalTo: startDate, toGranularity: .weekOfYear)
        }

        summary = engine.summarizeEmotionTrend(from: filtered)
        averageScore = calculateAverageScore(from: filtered)
    }

    func calculateAverageScore(from entries: [DialogueEntry]) -> Int {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        var total: Double = 0
        var count = 0

        for entry in entries {
            tagger.string = entry.reply
            let scoreTag = tagger.tag(at: entry.reply.startIndex,
                                      unit: NLTokenUnit.paragraph,
                                      scheme: NLTagScheme.sentimentScore).0
            if let scoreStr = scoreTag?.rawValue,
               let scoreVal = Double(scoreStr) {
                total += (scoreVal + 1.0) * 50
                count += 1
            }
        }

        return count == 0 ? 0 : Int(total / Double(count))
    }

    func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }

    func parseDate(_ str: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: str)
    }
}
