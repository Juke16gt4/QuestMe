//
//  CalendarGridView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/Calendar/CalendarGridView.swift
//
//  🎯 ファイルの責任:
//      - カレンダーの日付グリッドを表示する。
//      - CalendarView から呼び出され、選択された日付を更新する。
//      - 今後、感情ログの色分けや Companion の語りと連携可能。
//
//  🔗 依存:
//      - SwiftUI（View）
//      - CalendarView.swift（selectedDate のバインディング）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月10日
//

import SwiftUI

import SwiftUI

struct CalendarGridView: View {
    @Binding var selectedDate: Date

    private let calendar = Calendar.current
    private let daysInWeek = 7

    var body: some View {
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today) ?? (1..<31)
        let components = calendar.dateComponents([.year, .month], from: today)
        let firstDay = calendar.date(from: components) ?? today

        VStack {
            Text("🗓️ \(components.year ?? 0)年 \(components.month ?? 0)月")
                .font(.headline)
                .padding(.bottom, 8)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: daysInWeek)) {
                ForEach(range, id: \.self) { day in
                    let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) ?? today
                    Button(action: {
                        selectedDate = date
                    }) {
                        Text("\(day)")
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.blue.opacity(0.3) : Color(.systemGray5))
                            .cornerRadius(6)
                    }
                }
            }
        }
    }
}
