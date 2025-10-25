//
//  ScheduleAndEventDialogView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Calendar/ScheduleAndEventDialogView.swift
//
//  🎯 ファイルの目的:
//      ユーザーの予定とイベントを表示・編集する統合ビュー。
//      - カレンダー上の予定（服薬・検査・通院・記念日など）を表示。
//      - Companion がイベントに応じた語りかけを行う。
//      - 保存形式: Calendar/年/月/予定/日.json
//
//  🔗 依存:
//      - CompanionSectionView.swift（Sharedに統一）
//      - CompanionSpeechBubble.swift
//
//  👤 製作者: 津村 淳一
//  📅 修正日: 2025年10月9日

import SwiftUI

struct ScheduleAndEventDialogView: View {
    let date: Date
    @State private var events: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("📅 \(formattedDate(date)) の予定とイベント")
                    .font(.title2)
                    .bold()

                CompanionSectionView(title: "📌 登録された予定") {
                    VStack(alignment: .leading, spacing: 8) {
                        if events.isEmpty {
                            Text("この日に登録された予定はありません。")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(events, id: \.self) { event in
                                Text("・\(event)")
                            }
                        }
                    }
                }

                CompanionSectionView(title: "🗣️ コンパニオンの案内") {
                    CompanionSpeechBubble()
                }
            }
            .padding()
            .onAppear {
                loadEvents()
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    func loadEvents() {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dateStr = formattedDate(date)
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let root = docs.appendingPathComponent("Calendar/\(year)年/\(month)月")

        if let data = try? Data(contentsOf: root.appendingPathComponent("予定/\(dateStr).json")),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let items = json["events"] as? [String] {
            events = items
        }
    }
}
