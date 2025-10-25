//
//  CalendarSyncManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Services/Calendar/CalendarSyncManager.swift
//
//  🎯 目的:
//      Appleカレンダーに予定を登録。
//      - 繰り返しルール対応（daily, weekly, monthly）
//      - 通知設定（10分前）
//      - 重複登録防止（同一タイトル・日時）
//
//  🔗 連動:
//      - AddEventSheet.swift
//      - SearchCalendarLogView.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import Foundation
import EventKit

struct CalendarSyncManager {
    static func shareToAppleCalendar(title: String, start: Date, repeatRule: String = "なし") {
        let store = EKEventStore()

        store.requestAccess(to: .event) { granted, error in
            guard granted, error == nil else {
                CompanionOverlay.shared.speak("Appleカレンダーへのアクセスが拒否されました。", emotion: .sad)
                return
            }

            // 重複チェック
            let predicate = store.predicateForEvents(withStart: start, end: start.addingTimeInterval(3600), calendars: nil)
            let existing = store.events(matching: predicate).first(where: { $0.title == title })
            if existing != nil {
                CompanionOverlay.shared.speak("同じタイトルの予定がすでに登録されています。", emotion: .neutral)
                return
            }

            let event = EKEvent(eventStore: store)
            event.title = title
            event.startDate = start
            event.endDate = start.addingTimeInterval(3600)
            event.calendar = store.defaultCalendarForNewEvents

            // 🔁 繰り返しルール
            switch repeatRule {
            case "毎日":
                event.recurrenceRules = [EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil)]
            case "毎週":
                event.recurrenceRules = [EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil)]
            case "毎月":
                event.recurrenceRules = [EKRecurrenceRule(recurrenceWith: .monthly, interval: 1, end: nil)]
            default:
                break
            }

            // 🔔 通知設定（10分前）
            let alarm = EKAlarm(relativeOffset: -600)
            event.addAlarm(alarm)

            do {
                try store.save(event, span: .thisEvent)
                CompanionOverlay.shared.speak("Appleカレンダーに予定を登録しました。", emotion: .happy)
            } catch {
                CompanionOverlay.shared.speak("Appleカレンダーへの登録に失敗しました。", emotion: .sad)
            }
        }
    }
}
