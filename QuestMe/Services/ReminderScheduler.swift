//
//  ReminderScheduler.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/ReminderScheduler.swift
//
//  🎯 ファイルの目的:
//      学習リマインドのローカル通知を管理する。
//      - 許可取得、単発通知、毎日/毎週の繰り返し通知をスケジューリング。
//      - 通知タップでアプリ内のSummaryViewerViewへ遷移（呼び出し元で対応）。
//
//  🔗 依存:
//      - UserNotifications.framework（import UserNotifications）
//

import Foundation
import UserNotifications

enum ReminderType {
    case oneTime(date: Date)
    case daily(hour: Int, minute: Int)
    case weekly(weekday: Int, hour: Int, minute: Int) // weekday: 1=Sun ... 7=Sat
}

struct ReminderScheduler {
    static func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            completion(granted)
        }
    }

    static func schedule(title: String, body: String, type: ReminderType, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger: UNNotificationTrigger

        switch type {
        case .oneTime(let date):
            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        case .daily(let hour, let minute):
            var comps = DateComponents()
            comps.hour = hour
            comps.minute = minute
            trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        case .weekly(let weekday, let hour, let minute):
            var comps = DateComponents()
            comps.weekday = weekday
            comps.hour = hour
            comps.minute = minute
            trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        }

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancel(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
