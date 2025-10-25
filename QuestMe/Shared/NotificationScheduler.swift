//
//  NotificationScheduler.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Shared/NotificationScheduler.swift
//
//  🎯 目的:
//      美容チェック推奨時間帯の通知（土曜22-23時 / 日曜8-10時）を週次で繰り返し。
//      ・ユーザーに儀式的な撮影を促す（習慣化）。
//
//  🔗 依存:
//      - Foundation, UserNotifications
//
//  🔗 関連/連動ファイル:
//      - BeautyCaptureView.swift（通知後に撮影誘導）
//      - SleepTimerView.swift（就寝/起床の儀式化）
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-21

import Foundation
import UserNotifications

final class NotificationScheduler {
    static let shared = NotificationScheduler()

    func scheduleBeautyCheckReminders() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }

            self.scheduleWeekly(id: "beauty-sat-22", weekday: 7, hour: 22, minute: 0, body: "美容チェックの時間です。撮影して解析しましょう。")
            self.scheduleWeekly(id: "beauty-sat-23", weekday: 7, hour: 23, minute: 0, body: "美容チェックの時間です。撮影して解析しましょう。")
            self.scheduleWeekly(id: "beauty-sun-08", weekday: 1, hour: 8, minute: 0, body: "美容チェックの時間です。撮影して解析しましょう。")
            self.scheduleWeekly(id: "beauty-sun-10", weekday: 1, hour: 10, minute: 0, body: "美容チェックの時間です。撮影して解析しましょう。")
        }
    }

    private func scheduleWeekly(id: String, weekday: Int, hour: Int, minute: Int, body: String) {
        let content = UNMutableNotificationContent()
        content.title = "QuestMe 美容チェック"
        content.body = body
        content.sound = .default

        var comps = DateComponents()
        comps.weekday = weekday
        comps.hour = hour
        comps.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }
}
