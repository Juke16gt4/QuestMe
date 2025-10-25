//
//  DiaryView.swift
//  QuestMe
//
//  作成者: 津村 淳一 (Junichi Tsumura)
//  作成日: 2025年10月6日
//
//  📂 格納場所:
//      QuestMe/Companion/Memory/DiaryView.swift
//
//  🎯 ファイルの目的:
//      「記憶の書」に保存された地域体験（UserEventHistory）を日付で振り返るビュー。
//      - フォルダー名「思い出」に日付付きで保存された記録を読み込む。
//      - カレンダーから日付を選択し、該当する思い出を表示。
//      - Companion が語りかけ、感想を追記可能。
//      - PDFや画像化は行わず、ローカル保存＋語りかけに特化。
//      - 日記代わりとして、人生の記録と再発見を支援する。

import SwiftUI

struct DiaryView: View {
    @State private var selectedDate: Date = Date()
    @State private var history: UserEventHistory?
    @State private var newNote: String = ""
    @State private var showConfirmation = false

    var body: some View {
        VStack(spacing: 20) {
            Text("📅 思い出日記")
                .font(.title)
                .bold()

            DatePicker("日付を選択", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)

            Divider()

            if let history = history {
                Text("📖 タイトル: \(history.title)")
                    .font(.headline)

                Text("訪問日: \(history.visitedAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if !history.tags.isEmpty {
                    Text("タグ: \(history.tags.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let notes = history.notes {
                    Text("感想: \(notes)")
                        .padding(.top)
                }

                Button("Companionに語ってもらう") {
                    let message = "『\(history.title)』の日ですね。あなたはこう語っていました──「\(history.notes ?? "…」")」"
                    CompanionOverlay.shared.speak(message, emotion: .happy)
                }

                Divider()

                TextField("感想を追記する", text: $newNote)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("保存する") {
                    var updated = history
                    updated.notes = newNote
                    MemoryStorage.shared.save(updated)
                    showConfirmation = true
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("この日には記録がありません。")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .onAppear {
            history = MemoryStorage.shared.load(for: selectedDate)
        }
        .onChange(of: selectedDate) { newDate in
            history = MemoryStorage.shared.load(for: newDate)
        }
        .alert("保存しました", isPresented: $showConfirmation) {
            Button("OK") {}
        }
    }
}
