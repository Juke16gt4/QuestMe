//
//  DayScheduleView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Calendar/DayScheduleView.swift
//
//  🎯 目的:
//      指定日のイベントと保存フォルダーを表示する。
//      - FolderScanner により1日フォルダーを可視化。
//      - 検索・ヘルプ・メイン・戻るボタンを音声対応で配置。
//
//  🔗 依存:
//      - CalendarEngine.swift
//      - FolderScanner.swift
//      - CompanionOverlay.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import SwiftUI

struct DayScheduleView: View {
    let date: Date
    @ObservedObject var engine: CalendarEngine

    @State private var folders: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            Text("📅 \(formattedDate(date)) の予定")
                .font(.title2)
                .bold()

            // ✅ イベント表示
            let dateStr = isoDateString(date)
            let events = engine.events(on: dateStr)
            if events.isEmpty {
                Text("この日のイベントは登録されていません。")
                    .foregroundColor(.gray)
            } else {
                ForEach(events, id: \.id) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🕒 \(event.time)  \(event.title)")
                            .font(.headline)
                        Text("カテゴリ: \(event.category)")
                            .font(.caption)
                        Text("メモ: \(event.notes)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }

            Divider()

            // ✅ フォルダー一覧表示
            VStack(alignment: .leading, spacing: 8) {
                Text("📂 この日に保存されたフォルダー")
                    .font(.headline)

                if folders.isEmpty {
                    Text("保存されたフォルダーはありません。")
                        .foregroundColor(.gray)
                } else {
                    ForEach(folders, id: \.self) { folder in
                        Text("・\(folder)")
                    }
                }
            }

            Spacer()

            // ✅ メイン・戻るボタン
            HStack {
                Button("🏠 メイン画面") {
                    CompanionOverlay.shared.speak("メイン画面に戻ります。", emotion: .neutral)
                    // 画面遷移処理
                }
                Spacer()
                Button("🔙 戻る") {
                    CompanionOverlay.shared.speak("前の画面に戻ります。", emotion: .neutral)
                    // 画面遷移処理
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            folders = FolderScanner.folders(for: date)
            if folders.isEmpty {
                CompanionOverlay.shared.speak("この日に保存されたフォルダーはありません。", emotion: .neutral)
            } else {
                let joined = folders.joined(separator: "、")
                CompanionOverlay.shared.speak("この日に保存されたフォルダーは「\(joined)」です。", emotion: .gentle)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("🔍") {
                    CompanionOverlay.shared.speak("検索画面に移動します。", emotion: .neutral)
                    // 検索画面遷移処理
                }
                Button("❓") {
                    CompanionOverlay.shared.speak("この画面では1日の予定と保存フォルダーを確認できます。", emotion: .gentle)
                }
            }
        }
    }

    // MARK: - 日付フォーマット
    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy年MM月dd日"
        return f.string(from: date)
    }

    private func isoDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
