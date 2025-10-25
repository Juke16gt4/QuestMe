//
//  EventReminderManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Calendar/EventReminderManager.swift
//
//  🎯 ファイルの目的:
//      ユーザーがイベント（服薬・検査・運動など）に対して通知を設定・管理するビュー。
//      - 通知時刻・繰り返し・カテゴリ別ON/OFFを設定可能。
//      - 通知はローカル通知（UNUserNotificationCenter）で実行。
//      - 保存形式：UserDefaults または JSON（通知設定）
//      - ScheduleAndEventDialogView.swift から起動される。
//
//  🔗 依存:
//      - UNUserNotificationCenter（通知）
//      - EventItem.swift（カテゴリ参照）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月9日

import SwiftUI
import UserNotifications

struct ReminderSetting: Identifiable, Codable {
    var id = UUID()
    var category: String
    var time: Date
    var repeatRule: String
    var enabled: Bool
}

struct EventReminderManager: View {
    let date: Date
    @State private var reminders: [ReminderSetting] = []
    private let categories = ["おくすり", "運動", "Nutrition", "血液検査結果", "感情"]

    var body: some View {
        NavigationStack {
            Form {
                ForEach($reminders) { $reminder in
                    Section(reminder.category) {
                        Toggle("通知を有効にする", isOn: $reminder.enabled)
                        DatePicker("通知時刻", selection: $reminder.time, displayedComponents: .hourAndMinute)
                        Picker("繰り返し", selection: $reminder.repeatRule) {
                            ForEach(["なし", "毎日", "毎週"], id: \.self) { Text($0) }
                        }
                    }
                }

                Button("通知を保存") {
                    saveReminders()
                    scheduleNotifications()
                }
            }
            .navigationTitle("通知設定")
            .onAppear {
                loadReminders()
            }
        }
    }

    func loadReminders() {
        let key = "reminders-\(formattedDate(date))"
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ReminderSetting].self, from: data) {
            reminders = decoded
        } else {
            reminders = categories.map {
                ReminderSetting(category: $0, time: defaultTime(for: $0), repeatRule: "なし", enabled: false)
            }
        }
    }

    func saveReminders() {
        let key = "reminders-\(formattedDate(date))"
        if let data = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func scheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }

            for reminder in reminders where reminder.enabled {
                let content = UNMutableNotificationContent()
                content.title = "QuestMe 通知"
                content.body = "\(reminder.category) の時間です"
                content.sound = .default

                var trigger: UNNotificationTrigger?
                let components = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)

                switch reminder.repeatRule {
                case "毎日":
                    trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                case "毎週":
                    var weekly = components
                    weekly.weekday = Calendar.current.component(.weekday, from: date)
                    trigger = UNCalendarNotificationTrigger(dateMatching: weekly, repeats: true)
                default:
                    trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                }

                let request = UNNotificationRequest(
                    identifier: "\(reminder.category)-\(formattedDate(date))",
                    content: content,
                    trigger: trigger
                )
                center.add(request)
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    func defaultTime(for category: String) -> Date {
        var components = DateComponents()
        switch category {
        case "おくすり": components.hour = 8
        case "運動": components.hour = 18
        case "Nutrition": components.hour = 12
        case "血液検査結果": components.hour = 9
        case "感情": components.hour = 21
        default: components.hour = 10
        }
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}
