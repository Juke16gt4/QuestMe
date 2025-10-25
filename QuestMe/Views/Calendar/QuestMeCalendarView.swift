//
//  QuestMeCalendarView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Calendar/QuestMeCalendarView.swift
//
//  🎯 目的:
//      月グリッド表示、祝日色分け、イベント存在マーク、日ビュー遷移。
//      - 検索・ヘルプ・メイン・戻るボタンを音声対応で配置。
//      - Companion による母国語音声案内。
//      - CalendarEngine による祝日・イベント取得。
//
//  🔗 依存:
//      - CalendarEngine.swift
//      - DayScheduleView.swift
//      - CompanionOverlay.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import SwiftUI
import Foundation

struct QuestMeCalendarView: View {
    @StateObject private var engine = CalendarEngine()
    @State private var currentMonth = Date()
    private let cal = Calendar(identifier: .gregorian)

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                header
                weekdayHeader
                monthGrid
                Spacer()
            }
            .onAppear {
                engine.loadYear(cal.component(.year, from: currentMonth))
                CompanionOverlay.shared.speak("この画面では月ごとの予定と保存フォルダーを確認できます。", emotion: .gentle)
            }
            .navigationTitle("QuestMe カレンダー")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("🔍") {
                        CompanionOverlay.shared.speak("検索画面に移動します。", emotion: .neutral)
                        // 検索画面遷移処理
                    }
                    Button("❓") {
                        CompanionOverlay.shared.speak("この画面では月ごとの予定と保存フォルダーを確認できます。", emotion: .gentle)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button("🏠 メイン画面") {
                        CompanionOverlay.shared.speak("メイン画面に戻ります。", emotion: .neutral)
                        // ホーム画面遷移処理
                    }
                    Spacer()
                    Button("🔙 戻る") {
                        CompanionOverlay.shared.speak("前の画面に戻ります。", emotion: .neutral)
                        // 戻る処理
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Button {
                currentMonth = cal.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                engine.loadYear(cal.component(.year, from: currentMonth))
            } label: { Image(systemName: "chevron.left") }

            Spacer()
            Text(headerLabel(currentMonth)).font(.headline)
            Spacer()

            Button {
                currentMonth = cal.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                engine.loadYear(cal.component(.year, from: currentMonth))
            } label: { Image(systemName: "chevron.right") }
        }
        .padding(.horizontal)
    }

    private func headerLabel(_ date: Date) -> String {
        let year = cal.component(.year, from: date)
        let month = cal.component(.month, from: date)
        return "\(year)年\(month)月"
    }

    // MARK: - Weekday Header
    private var weekdayHeader: some View {
        HStack {
            ForEach(["日","月","火","水","木","金","土"], id: \.self) { w in
                Text(w)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(w == "日" ? .red : (w == "土" ? .blue : .secondary))
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Month Grid
    private var monthGrid: some View {
        let cells = monthCells(for: currentMonth)
        return LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7), spacing: 8) {
            ForEach(cells, id: \.self) { date in
                let dateStr = isoDateString(date)
                NavigationLink {
                    DayScheduleView(date: date, engine: engine)
                } label: {
                    VStack(spacing: 6) {
                        Text(dayNumber(date))
                            .font(.subheadline)
                            .fontWeight(cal.isDateInToday(date) ? .bold : .regular)
                            .foregroundColor(foregroundColor(for: date, dateStr: dateStr))
                            .frame(maxWidth: .infinity)

                        Circle()
                            .fill(Color.orange.opacity(0.8))
                            .frame(width: 6, height: 6)
                            .opacity((engine.events(on: dateStr).isEmpty) ? 0 : 1)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(6)
                    .background(backgroundColor(for: date))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(!isInMonth(date, currentMonth))
            }
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Helpers
    private func monthCells(for month: Date) -> [Date] {
        guard
            let monthInterval = cal.dateInterval(of: .month, for: month),
            let firstWeek = cal.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else { return [] }
        let start = firstWeek.start
        return (0..<42).compactMap { cal.date(byAdding: .day, value: $0, to: start) }
    }

    private func dayNumber(_ date: Date) -> String { String(cal.component(.day, from: date)) }

    private func isoDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = cal
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private func isInMonth(_ date: Date, _ month: Date) -> Bool {
        guard let interval = cal.dateInterval(of: .month, for: month) else { return false }
        return interval.contains(date)
    }

    private func foregroundColor(for date: Date, dateStr: String) -> Color {
        if engine.isHoliday(dateString: dateStr) || cal.component(.weekday, from: date) == 1 { return .red }
        if cal.component(.weekday, from: date) == 7 { return .blue }
        return .black
    }

    private func backgroundColor(for date: Date) -> Color {
        if cal.component(.weekday, from: date) == 1 { return Color.pink.opacity(0.12) }
        if cal.component(.weekday, from: date) == 7 { return Color.blue.opacity(0.12) }
        return Color.white
    }
}
