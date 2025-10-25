//
//  SleepTimerView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Beauty/SleepTimerView.swift
//
//  🎯 目的:
//      美容専用の睡眠タイマー。就寝/起床時刻のセット→就寝案内→起床アラーム（音源 or Companion音声）。
//      ・保存先: Calendar/美容アドバイス/睡眠/yyyy-MM-dd.json
//      ・起床時に美容アドバイスと連動した短い提案を表示。
//      ・共通ナビ（メイン画面へ/もどる/ヘルプ）と明示的保存ボタンを統合。
//
//  🔗 依存:
//      - SwiftUI, UserNotifications
//      - CompanionOverlay（発話）
//
//  🔗 関連/連動ファイル:
//      - BeautyCaptureView.swift（就寝/起床後の提案）
//      - NotificationScheduler.swift（定期リマインド）
//
//  👤 作成者: 津村 淳一
//  📅 作成日時: 2025-10-21

import SwiftUI
import UserNotifications

struct SleepTimerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sleepTime = Date()
    @State private var wakeTime = Calendar.current.date(byAdding: .hour, value: 7, to: Date()) ?? Date()
    @State private var useCompanionVoice = true

    var body: some View {
        Form {
            Section(NSLocalizedString("BedTimeSection", comment: "就寝時間")) {
                DatePicker(NSLocalizedString("BedTime", comment: "寝る時間"), selection: $sleepTime, displayedComponents: [.hourAndMinute])
            }
            Section(NSLocalizedString("WakeTimeSection", comment: "起床時間")) {
                DatePicker(NSLocalizedString("WakeTime", comment: "起きる時間"), selection: $wakeTime, displayedComponents: [.hourAndMinute])
            }
            Section(NSLocalizedString("WakeMethodSection", comment: "起こし方")) {
                Toggle(NSLocalizedString("UseCompanionVoiceWake", comment: "コンパニオン音声で起こす"), isOn: $useCompanionVoice)
            }
            Section {
                Button(NSLocalizedString("Start", comment: "開始")) {
                    CompanionOverlay.shared.speak(NSLocalizedString("SleepSoonPrompt", comment: "そろそろ休みましょう。良い睡眠が美容につながります。"), emotion: .gentle)
                    scheduleAlarm(at: wakeTime)
                    saveSleepLog(sleep: sleepTime, wake: wakeTime)
                }
                Button(NSLocalizedString("Save", comment: "保存")) {
                    saveSleepLog(sleep: sleepTime, wake: wakeTime)
                    CompanionOverlay.shared.speak(NSLocalizedString("SleepLogSaved", comment: "睡眠ログを保存しました。"), emotion: .gentle)
                }
            }
        }
        .navigationTitle(NSLocalizedString("BeautySleepTimer", comment: "美容専用睡眠タイマー"))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(NSLocalizedString("MainScreen", comment: "メイン画面へ")) { dismiss() }
                Button(NSLocalizedString("Back", comment: "もどる")) { dismiss() }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(NSLocalizedString("Help", comment: "ヘルプ")) {
                    CompanionOverlay.shared.speak(NSLocalizedString("SleepTimerHelp", comment: "睡眠タイマーの説明"), emotion: .neutral)
                }
            }
        }
    }

    private func scheduleAlarm(at date: Date) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("BeautyTimerTitle", comment: "QuestMe 美容タイマー")
            content.body = useCompanionVoice
                ? NSLocalizedString("WakeVoiceBody", comment: "起きてください！朝ですよ〜")
                : NSLocalizedString("WakeDefaultBody", comment: "起床時間です。今日も良い一日を。")
            content.sound = .default

            let comps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let req = UNNotificationRequest(identifier: "beauty-sleep-alarm", content: content, trigger: trigger)
            center.add(req)
        }
    }

    private func saveSleepLog(sleep: Date, wake: Date) {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folder = docs.appendingPathComponent("Calendar/美容アドバイス/睡眠")
        try? fm.createDirectory(at: folder, withIntermediateDirectories: true)

        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        let fn = folder.appendingPathComponent("\(f.string(from: Date())).json")

        let hours = max(0, wake.timeIntervalSince(sleep) / 3600.0)
        let payload: [String: Any] = [
            "sleep": sleep.timeIntervalSince1970,
            "wake": wake.timeIntervalSince1970,
            "hours": hours
        ]
        if let data = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted) {
            try? data.write(to: fn)
        }

        if hours < 6 {
            CompanionOverlay.shared.speak(NSLocalizedString("ShortSleepAdvice", comment: "睡眠が少し短めでした。今日は保湿を意識しましょう。"), emotion: .gentle)
        } else {
            CompanionOverlay.shared.speak(NSLocalizedString("GoodSleepPraise", comment: "良い睡眠でした。肌の明るさにも反映されますね。"), emotion: .happy)
        }
    }
}
