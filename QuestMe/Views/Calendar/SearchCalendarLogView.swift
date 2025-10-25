//
//  SearchCalendarLogView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Calendar/SearchCalendarLogView.swift
//
//  🎯 目的:
//      日付とフォルダー名でログを検索し、感想・画像・感情・タグを表示。
//      - タグで絞り込み可能。
//      - 検索結果を予定として登録（Appleカレンダー連携）。
//      - Companion による音声案内対応。
//
//  🔗 依存:
//      - FolderScanner.swift
//      - CalendarSyncManager.swift
//      - QuestMeStorage.swift
//      - CompanionOverlay.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import SwiftUI
import UIKit

struct SearchCalendarLogView: View {
    @State private var selectedDate = Date()
    @State private var selectedFolder = ""
    @State private var selectedTag = ""
    @State private var folderOptions: [String] = []
    @State private var availableTags: [String] = ["おくすり", "感情", "Nutrition", "運動", "検査", "その他"]

    @State private var resultText: String? = nil
    @State private var resultImage: UIImage? = nil
    @State private var emotion: String? = nil
    @State private var tags: [String] = []

    var body: some View {
        VStack(spacing: 20) {
            Text("🔍 カレンダー検索")
                .font(.title2)
                .bold()

            DatePicker("検索する日付", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)

            Picker("タグで絞り込み", selection: $selectedTag) {
                Text("すべてのタグ").tag("")
                ForEach(availableTags, id: \.self) { tag in
                    Text(tag)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedTag) { tag in
                let all = FolderScanner.folders(for: selectedDate)
                folderOptions = tag.isEmpty ? all : all.filter { $0.contains(tag) }
            }

            Picker("ホルダーネーム", selection: $selectedFolder) {
                ForEach(folderOptions, id: \.self) { folder in
                    Text(folder)
                }
            }
            .pickerStyle(.menu)

            Button("検索") {
                searchLog()
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedFolder.isEmpty)

            Divider()

            if let resultText {
                VStack(alignment: .leading, spacing: 8) {
                    Text("📖 内容")
                        .font(.headline)
                    Text(resultText)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }

            if let emotion {
                Text("🧠 感情: \(emotion)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }

            if !tags.isEmpty {
                Text("🏷️ タグ: \(tags.joined(separator: ", "))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            if let image = resultImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
                    .cornerRadius(8)
            }

            if resultText != nil {
                Button("📅 この内容を予定として登録") {
                    registerAsEvent()
                }
                .buttonStyle(.borderedProminent)

                Button("🗣️ Companion に語ってもらう") {
                    CompanionOverlay.shared.speak("検索結果です。\(resultText ?? "")", emotion: .gentle)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            folderOptions = FolderScanner.folders(for: selectedDate)
        }
    }

    // MARK: - 検索処理
    private func searchLog() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: selectedDate)

        let year = Calendar.current.component(.year, from: selectedDate)
        let month = Calendar.current.component(.month, from: selectedDate)

        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Calendar/\(year)年/\(month)月/\(selectedFolder)/\(dateStr).json")

        guard let data = try? Data(contentsOf: fileURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            resultText = "該当する記録が見つかりませんでした。"
            resultImage = nil
            emotion = nil
            tags = []
            return
        }

        resultText = (json["text"] as? [String: Any])?["comment"] as? String
        emotion = json["emotion"] as? String
        tags = json["tags"] as? [String] ?? []

        if let base64 = (json["image"] as? [String: Any])?["base64"] as? String,
           let data = Data(base64Encoded: base64.replacingOccurrences(of: "data:image/jpeg;base64,", with: "")),
           let uiImage = UIImage(data: data) {
            resultImage = uiImage
        } else {
            resultImage = nil
        }
    }

    // MARK: - 予定登録処理
    private func registerAsEvent() {
        let time = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: selectedDate) ?? selectedDate
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "HH:mm"
        let timeStr = hourFormatter.string(from: time)

        let event: [String: Any] = [
            "time": timeStr,
            "title": resultText ?? "予定",
            "category": selectedFolder,
            "notes": "検索結果から登録",
            "color": "青",
            "repeatRule": "なし"
        ]

        let year = Calendar.current.component(.year, from: selectedDate)
        let month = Calendar.current.component(.month, from: selectedDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: selectedDate)

        do {
            try QuestMeStorage.saveEvent(for: dateStr, event: event, year: year, monthJP: "\(month)月")
            CalendarSyncManager.shareToAppleCalendar(title: resultText ?? "予定", start: time)
            CompanionOverlay.shared.speak("予定として登録しました。Appleカレンダーにも共有済みです。", emotion: .happy)
        } catch {
            CompanionOverlay.shared.speak("予定の登録に失敗しました。", emotion: .sad)
        }
    }
}
