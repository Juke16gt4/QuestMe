//
//  QuestMeStorage.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Storage/QuestMeStorage.swift
//
//  🎯 目的:
//      カレンダー予定（EventItem）を日付ごとに保存。
//      - 保存形式: Documents/Calendar/yyyy-MM-dd/カテゴリ/event.json
//      - 複数イベントを1ファイルに蓄積。
//      - Companion やカレンダーUIから再利用可能。
//
//  🔗 連動:
//      - AddEventSheet.swift（予定追加）
//      - SearchCalendarLogView.swift（検索結果 → 予定登録）
//      - ScheduleAndEventDialogView.swift（表示）
//      - CalendarSyncManager.swift（Appleカレンダー連携）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import Foundation

struct QuestMeStorage {
    /// 予定を保存（日付フォルダー形式）
    /// - Parameters:
    ///   - dateStr: "yyyy-MM-dd" 形式の日付文字列
    ///   - event: [String: Any] 形式の予定情報
    ///   - year: 年（例: 2025）
    ///   - monthJP: 月（例: "10月"）
    static func saveEvent(for dateStr: String, event: [String: Any], year: Int, monthJP: String) throws {
        guard let category = event["category"] as? String else { return }

        let fm = FileManager.default
        let root = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folder = root
            .appendingPathComponent("Calendar")
            .appendingPathComponent(dateStr)              // ← 日付フォルダー
            .appendingPathComponent(category)             // ← カテゴリフォルダー

        try fm.createDirectory(at: folder, withIntermediateDirectories: true)

        let fileURL = folder.appendingPathComponent("event.json") // ← 固定ファイル名

        var json: [String: Any] = [:]
        if let data = try? Data(contentsOf: fileURL),
           let existing = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            json = existing
        }

        var events = json["events"] as? [[String: Any]] ?? []
        events.append(event)
        json["events"] = events

        let newData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        try newData.write(to: fileURL)
    }
}
