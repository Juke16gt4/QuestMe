//
//  CompanionDialogueHistoryView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionDialogueHistoryView.swift
//
//  🎯 ファイルの目的:
//      ユーザーが過去にAIコンパニオンへ返信した内容を一覧で振り返る履歴ビュー。
//      - Calendar/年/月/対話/日.json を読み込み、日付順に表示。
//      - CompanionAdviceView や CompanionMemoryEngine に連携可能。
//      - ユーザーの自己理解と継続的な対話を支援する。
//
//  🔗 依存:
//      - DialogueEntry.swift（履歴モデル）
//      - FileManager（ファイル読み込み）
//      - JSONSerialization（解析）
//
//  👤 製作者: 津村 淳一
//  📅 修正日: 2025年10月9日

import SwiftUI

struct CompanionDialogueHistoryView: View {
    @State private var entries: [DialogueEntry] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(entries.sorted(by: { $0.date > $1.date })) { entry in
                    Section(entry.date) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🧠 コンパニオンの語りかけ")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(entry.advice)
                                .font(.body)
                                .foregroundColor(.blue)

                            Text("🗣️ あなたの返信")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(entry.reply)
                                .font(.body)
                        }
                    }
                }
            }
            .navigationTitle("対話履歴")
            .onAppear {
                loadDialogueHistory()
            }
        }
    }

    func loadDialogueHistory() {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let calendarRoot = docs.appendingPathComponent("Calendar")

        guard let enumerator = fm.enumerator(at: calendarRoot, includingPropertiesForKeys: nil) else { return }

        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent.hasSuffix(".json"),
               fileURL.path.contains("対話") {
                if let data = try? Data(contentsOf: fileURL),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let date = json["date"] as? String,
                   let advice = json["advice"] as? String,
                   let reply = json["reply"] as? String {
                    let entry = DialogueEntry(date: date, advice: advice, reply: reply)
                    entries.append(entry)
                }
            }
        }
    }
}
