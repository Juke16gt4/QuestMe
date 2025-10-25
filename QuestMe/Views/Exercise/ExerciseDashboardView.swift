//
//  ExerciseDashboardView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Exercise/ExerciseDashboardView.swift
//
//  🎯 ファイルの目的:
//      運動履歴を「グラフ」「リスト」「📅 カレンダー表示」「📂 日別記録ビュー」で表示するダッシュボードビュー。
//      - 週単位・月単位の切り替えに対応。
//      - Companion が音声で応援する基盤を提供。
//      - グラフは ExerciseChartView、リストは ExerciseLogView に準拠。
//      - 📅 カレンダー表示は Documents/Exercise/YYYY-MM-DD フォルダを一覧表示。
//      - 📂 フォルダをタップすると DailyExerciseRecordView に遷移。
//
//  🔗 依存:
//      - Charts（グラフ描画）
//      - ExerciseStorageManager.swift（履歴取得）
//      - ExerciseChartView.swift（グラフ）
//      - ExerciseLogView.swift（リスト）
//      - DailyExerciseRecordView.swift（日別記録）
//      - CompanionOverlay.swift（音声）
//
//  👤 製作者: 津村 淳一
//  📅 統合日: 2025年10月8日
//

import SwiftUI
import Charts

struct ExerciseDashboardView: View {
    @State private var period: ChartPeriod = .week
    @State private var entries: [ChartEntry] = []
    @State private var logs: [ExerciseEntry] = []
    @State private var calendarFolders: [String] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("運動ダッシュボード")
                        .font(.title)
                        .bold()

                    // 期間切り替え
                    Picker("期間", selection: $period) {
                        Text("週").tag(ChartPeriod.week)
                        Text("月").tag(ChartPeriod.month)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // グラフ表示
                    Chart(entries) { entry in
                        BarMark(
                            x: .value("日付", entry.date, unit: .day),
                            y: .value("消費カロリー", entry.calories)
                        )
                        .foregroundStyle(.blue)
                    }
                    .frame(height: 220)
                    .padding(.horizontal)

                    Divider().padding(.vertical, 8)

                    // 詳細リスト
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📋 運動履歴")
                            .font(.headline)
                            .padding(.leading)

                        ForEach(logs, id: \.id) { log in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🕒 \(formatted(log.timestamp))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("🏃‍♂️ \(log.activityName)")
                                    .font(.headline)
                                Text("🔥 \(Int(log.calories)) kcal ・ ⏱ \(log.durationMinutes) 分 ・ ⚖️ \(Int(log.weightKg)) kg")
                                    .font(.subheadline)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }

                    Divider().padding(.vertical, 8)

                    // 📅 カレンダー表示 → 📂 日別記録ビューへ遷移
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📅 カレンダー保存フォルダ")
                            .font(.headline)
                            .padding(.leading)

                        ForEach(calendarFolders, id: \.self) { folder in
                            NavigationLink(destination: DailyExerciseRecordView(folderName: folder)) {
                                HStack {
                                    Image(systemName: "folder")
                                    Text(folder)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(6)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.top)
            }
            .onAppear {
                loadData()
                loadCalendarFolders()
                speakSummary()
            }
            .onChange(of: period) { _ in
                loadData()
            }
            .navigationTitle("運動ダッシュボード")
        }
    }

    // MARK: - データ読み込み
    private func loadData() {
        let days = (period == .week) ? 7 : 30
        let all = ExerciseStorageManager.shared.fetchAll()

        let since = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let filtered = all.filter { $0.timestamp >= since }

        let grouped = Dictionary(grouping: filtered) { entry in
            Calendar.current.startOfDay(for: entry.timestamp)
        }

        entries = grouped.map { (date, items) in
            ChartEntry(
                date: date,
                calories: items.reduce(0) { $0 + $1.calories }
            )
        }
        .sorted { $0.date < $1.date }

        logs = filtered.sorted { $0.timestamp > $1.timestamp }
    }

    // MARK: - 📅 フォルダ読み込み
    private func loadCalendarFolders() {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Exercise", isDirectory: true)

        if let contents = try? FileManager.default.contentsOfDirectory(at: base, includingPropertiesForKeys: nil) {
            calendarFolders = contents
                .filter { $0.hasDirectoryPath }
                .map { $0.lastPathComponent }
                .sorted(by: >)
        }
    }

    // MARK: - Companion 応援セリフ
    private func speakSummary() {
        let total = (period == .week)
            ? ExerciseStorageManager.shared.totalCaloriesThisWeek()
            : ExerciseStorageManager.shared.totalCaloriesThisMonth()

        let message = (period == .week)
            ? "今週の消費カロリーは \(Int(total)) キロカロリーです。とても頑張りましたね！"
            : "今月の消費カロリーは \(Int(total)) キロカロリーです。継続は力なりですね！"

        CompanionOverlay.shared.speak(message)
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}
