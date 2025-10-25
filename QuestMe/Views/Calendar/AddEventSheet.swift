//
//  AddEventSheet.swift
//  QuestMe
//
//  Created by Junichi Tsumura on 2025/10/09.
//  Purpose:
//  ユーザーが日付ごとにイベントを追加できるUI。
//  テキスト・音声・繰り返し・色・カテゴリ選択を含み、保存後は .json に格納。
//  Appleカレンダーにも共有される。保存先フォルダーは自動生成。
//  対応カテゴリ：「おくすり」「運動」「Nutrition」「血液検査結果」「感情」「その他」
//  保存形式：Documents/Calendar/年/月/カテゴリ/日.json

import SwiftUI
import EventKit

struct AddEventSheet: View {
    @Environment(\.dismiss) var dismiss
    let date: Date

    @State private var title = ""
    @State private var notes = ""
    @State private var time = Date()
    @State private var category = "おくすり"
    @State private var color = "クリーム色"
    @State private var repeatRule = "なし"

    private let categories = ["おくすり", "運動", "Nutrition", "血液検査結果", "感情", "その他"]
    private let colors = ["クリーム色", "青", "緑", "赤", "紫", "グレー"]
    private let repeatOptions = ["なし", "毎日", "毎週", "毎月"]

    var body: some View {
        NavigationStack {
            Form {
                Section("タイトル") {
                    TextField("イベント名", text: $title)
                }

                Section("時間") {
                    DatePicker("開始時刻", selection: $time, displayedComponents: .hourAndMinute)
                }

                Section("カテゴリ") {
                    Picker("カテゴリ", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                }

                Section("色") {
                    Picker("色", selection: $color) {
                        ForEach(colors, id: \.self) { Text($0) }
                    }
                }

                Section("繰り返し") {
                    Picker("繰り返し", selection: $repeatRule) {
                        ForEach(repeatOptions, id: \.self) { Text($0) }
                    }
                }

                Section("メモ") {
                    TextField("補足メモ", text: $notes)
                }

                Section {
                    Button("保存して共有") {
                        saveEvent()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("イベント追加")
        }
    }

    private func saveEvent() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)

        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH:mm"
        let timeStr = hourFormatter.string(from: time)

        let event = EventItem(
            time: timeStr,
            title: title,
            category: category,
            notes: notes,
            color: color,
            repeatRule: repeatRule
        )

        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let monthJP = "\(month)月"

        do {
            try QuestMeStorage.saveEvent(for: dateStr, event: event, year: year, monthJP: monthJP)
            CalendarSyncManager.shareToAppleCalendar(title: title, start: time)
        } catch {
            print("保存失敗: \(error)")
        }
    }
}
