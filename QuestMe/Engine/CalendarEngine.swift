//
//  CalendarEngine.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Engines/CalendarEngine.swift
//
//  🎯 ファイルの目的:
//      カレンダー表示や日付選択の状態を管理する ObservableObject。
//      - QuestMeCalendarView や DayScheduleView から監視される。
//      - 年単位 JSON の読み込み。
//      - 指定日のイベント取得、祝日判定。
//

import Foundation
import Combine

final class CalendarEngine: ObservableObject {
    /// 年単位のカレンダーデータ
    @Published var yearData: YearData?

    /// 指定年の JSON を読み込む
    func loadYear(_ year: Int) {
        guard let url = Bundle.main.url(forResource: "\(year)", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(YearData.self, from: data)
            self.yearData = decoded
        } catch {
            print("読み込み失敗: \(error)")
        }
    }

    /// 指定日付のイベント一覧を返す
    func events(on dateString: String) -> [EventItem] {
        yearData?.days.first(where: { $0.date == dateString })?.events ?? []
    }

    /// 指定日付が祝日かどうかを返す
    func isHoliday(dateString: String) -> Bool {
        yearData?.days.first(where: { $0.date == dateString })?.isHoliday ?? false
    }
}
