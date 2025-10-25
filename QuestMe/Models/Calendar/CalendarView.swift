//
//  CalendarView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/Calendar/CalendarView.swift
//
//  🎯 ファイルの責任:
//      - カレンダー表示（CalendarGridView）
//      - 選択日の感情ログ表示
//      - 選択日の予定一覧表示
//      - 予定追加ボタン（AddEventSheet）
//      - Companion 音声案内連携
//
//  🔗 依存:
//      - CalendarGridView.swift
//      - EmotionLogStorageManager.swift
//      - QuestMeStorage.swift
//      - AddEventSheet.swift
//      - CompanionOverlay.swift
//
//  👤 製作者: 津村 淳一
//  📅 改訂日: 2025年10月21日

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate: Date = Date()
    @State private var emotionLogs: [EmotionLog] = []
    @State private var scheduledEvents: [EventItem] = []
    @State private var showAddEventSheet = false

    var body: some View {
        VStack(spacing: 16) {
            Text("📅 カレンダー")
                .font(.title)
                .bold()

            CalendarGridView(selectedDate: $selectedDate)

            Divider()

            // 🧠 感情ログ表示
            Text("🧠 感情ログ")
                .font(.headline)

            let logsForDate = emotionLogs.filter {
                Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
            }

            if logsForDate.isEmpty {
                Text("この日の感情ログはありません。")
                    .foregroundColor(.secondary)
            } else {
                ForEach(logsForDate) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("感情: \(log.emotion.rawValue)")
                        if let note = log.note {
                            Text("メモ: \(note)")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }

            Divider()

            // 📌 予定一覧表示
            Text("📌 登録された予定")
                .font(.headline)

            if scheduledEvents.isEmpty {
                Text("この日の予定は登録されていません。")
                    .foregroundColor(.secondary)
            } else {
                ForEach(scheduledEvents) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🕒 \(event.time) - \(event.title)")
                            .font(.subheadline)
                            .bold()
                        Text("カテゴリ: \(event.category)")
                            .font(.caption)
                        if !event.notes.isEmpty {
                            Text("メモ: \(event.notes)")
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }

            Divider()

            // ➕ 予定追加ボタン
            Button("➕ この日に予定を追加") {
                CompanionOverlay.shared.speak("予定追加画面を開きます。", emotion: .encouraging)
                showAddEventSheet = true
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .onAppear {
            emotionLogs = EmotionLogStorageManager.shared.loadAll()
            loadScheduledEvents()
            CompanionOverlay.shared.speak("カレンダー画面です。日付を選んで感情ログや予定を確認できます。", emotion: .gentle)
        }
        .onChange(of: selectedDate) { _ in
            loadScheduledEvents()
        }
        .sheet(isPresented: $showAddEventSheet) {
            AddEventSheet(date: selectedDate)
        }
    }

    // MARK: - 予定読み込み
    private func loadScheduledEvents() {
        let fm = FileManager.default
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: selectedDate)

        let dateFolder = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Calendar")
            .appendingPathComponent(dateStr)

        guard let categoryFolders = try? fm.contentsOfDirectory(at: dateFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) else {
            scheduledEvents = []
            return
        }

        var allEvents: [EventItem] = []

        for folderURL in categoryFolders where folderURL.hasDirectoryPath {
            let fileURL = folderURL.appendingPathComponent("event.json")
            if let data = try? Data(contentsOf: fileURL),
               let json = try? JSONDecoder().decode([String: [EventItem]].self, from: data),
               let events = json["events"] {
                allEvents.append(contentsOf: events)
            }
        }

        scheduledEvents = allEvents.sorted { $0.time < $1.time }
    }
}
