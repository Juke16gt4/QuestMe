//
//  HolidayAutoMarker.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/Holiday/HolidayAutoMarker.swift
//
//  🎯 ファイルの目的:
//      年間カレンダーデータに祝日フラグを自動付与する
//

import Foundation

final class HolidayAutoMarker {

    /// 指定された祝日リストをもとに YearData の各日付にフラグを付与
    /// - Parameters:
    ///   - yearData: 祝日フラグを付与する対象の年データ
    ///   - holidayDates: "yyyy-MM-dd" 形式の日付文字列のセット
    func markHolidays(in yearData: inout YearData, holidayDates: Set<String>) {
        for i in yearData.days.indices {
            if holidayDates.contains(yearData.days[i].date) {
                yearData.days[i].isHoliday = true   // ← インデックス経由で代入
            }
        }
    }
}
