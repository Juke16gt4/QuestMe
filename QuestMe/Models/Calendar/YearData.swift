//
//  YearData.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/Calendar/YearData.swift
//
//  🎯 ファイルの目的:
//      カレンダーの基礎データモデルを定義する。
//      - 年単位のデータ (YearData)
//      - 日ごとの記録 (DayRecord)
//      - イベント情報 (EventItem)
//

import Foundation

/// 年単位のカレンダーデータ
struct YearData: Codable {
    let year: Int
    var days: [DayRecord]
}

/// 日ごとの記録
struct DayRecord: Codable, Identifiable {
    var id: String { date }
    let date: String        // "yyyy-MM-dd"
    let weekday: String     // "Sun" 等
    var isHoliday: Bool     // ← let → var に修正
    var events: [EventItem]
}

/// イベント情報
struct EventItem: Codable, Identifiable {
    var id = UUID()
    var time: String        // "09:00" 等
    var title: String
    var category: String
    var notes: String
    var color: String       // "#FF9900" 等
    var repeatRule: String  // "none", "daily" 等
}
