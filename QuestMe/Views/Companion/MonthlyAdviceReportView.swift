//
//  MonthlyAdviceReportView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/MonthlyAdviceReportView.swift
//
//  🎯 ファイルの目的:
//      - 月単位でアドバイス履歴と感情傾向を表示するビュー。
//      - CompanionAdviceView や履歴分析エンジンから呼び出される。
//      - AdviceStorageManager と AdviceMemoryStorageManager を使用。
//      - 未定義エラーをすべて退治済み。
//
//  🔗 依存:
//      - AdviceStorageManager.swift（loadAdvices(for:)）
//      - AdviceMemoryStorageManager+Public.swift（fetchFeelingHistoryPublic(forPastDays:)）
//

import SwiftUI

struct AdviceEntry: Identifiable {
    let id: String
    let text: String
    let type: String
    let date: String
}

struct AdviceFeelingEntry: Identifiable {
    let id = UUID()
    let date: String
    let feeling: String
}

struct MonthlyAdviceReportView: View {
    let dateString: String // 例: "202510"

    @State private var adviceEntries: [AdviceEntry] = []
    @State private var feelingEntries: [AdviceFeelingEntry] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("🗓️ \(dateString.prefix(4))年\(dateString.suffix(2))月のアドバイス履歴")
                    .font(.title2)

                ForEach(adviceEntries) { advice in
                    VStack(alignment: .leading) {
                        Text(advice.text)
                            .font(.body)
                        Text(advice.date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Divider()

                Text("📊 感情傾向")
                    .font(.title2)

                ForEach(feelingEntries) { entry in
                    HStack {
                        Text(entry.feeling)
                        Spacer()
                        Text(entry.date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("月次レポート")
        .onAppear {
            loadAdviceEntries()
            loadFeelingEntries()
        }
    }

    private func loadAdviceEntries() {
        let days = (1...31).map { String(format: "%02d", $0) }
        var all: [AdviceEntry] = []

        for day in days {
            let fullDate = "\(dateString)\(day)" // 例: "20251001"
            let raw = AdviceStorageManager.shared.loadAdvices(for: fullDate)
            let entries = raw.compactMap { dict -> AdviceEntry? in
                guard let id = dict["id"] as? String,
                      let text = dict["text"] as? String,
                      let type = dict["type"] as? String,
                      let date = dict["date"] as? String else { return nil }
                return AdviceEntry(id: id, text: text, type: type, date: date)
            }
            all.append(contentsOf: entries)
        }

        adviceEntries = all.sorted { $0.date < $1.date }
    }

    private func loadFeelingEntries() {
        let raw = AdviceMemoryStorageManager.shared.fetchFeelingHistoryPublic(forPastDays: 31)
        feelingEntries = raw.compactMap { dict -> AdviceFeelingEntry? in
            guard let date = dict["date"], let feeling = dict["feeling"] else { return nil }
            return AdviceFeelingEntry(date: date, feeling: feeling)
        }
    }
}
