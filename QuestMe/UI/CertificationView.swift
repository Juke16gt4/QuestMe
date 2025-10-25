//
//  CertificationView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/CertificationView.swift
//
//  🎯 ファイルの目的:
//      資格取得モード専用UI。
//      - 進捗表示、試験日カレンダー、関心度スコア、振り返り分析、リマインダー、合格祈願を統合表示。
//      - ユーザーの挑戦を可視化し、感情同期と応援に活用。
//
//  🔗 連動ファイル:
//      - CertificationProgressTracker.swift
//      - ExamCalendarService.swift
//      - InterestScorer.swift
//      - CertificationReminderService.swift
//      - CertificationBlessingService.swift
//      - StorageService.swift
//      - ConversationEntry.swift
//
//  👤 作成者: 津村 淳一
//  📅 修正日: 2025年10月22日
//

import SwiftUI

struct CertificationView: View {
    @StateObject var tracker = CertificationProgressTracker()
    @StateObject var calendar = ExamCalendarService()
    @StateObject var storage = StorageService()
    @StateObject var speech = SpeechSync()

    @State private var logs: [ConversationEntry] = []
    @State private var spokenEmotion: EmotionType = .neutral

    private let scorer = InterestScorer()
    private let reminder = CertificationReminderService()
    private let blessing = CertificationBlessingService()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("🎓 資格取得モード").font(.title2).bold()

                Text(reflectCertificationProgress())
                    .font(.body)
                    .padding()

                VStack(alignment: .leading) {
                    Text("📈 進捗状況")
                    ForEach(tracker.progressList) { item in
                        VStack(alignment: .leading) {
                            Text(item.name)
                            ProgressView(value: item.completedPercent, total: 100.0)
                        }
                    }
                }

                VStack(alignment: .leading) {
                    Text("🗓️ 試験予定")
                    ForEach(calendar.fetchUpcomingExams()) { exam in
                        Text("\(exam.name) - \(exam.date.formatted()) @ \(exam.location)")
                    }
                }

                VStack(alignment: .leading) {
                    Text("🔥 関心度の高い資格")
                    ForEach(scorer.topInterests(from: logs), id: \.self) { keyword in
                        Text("・\(keyword)")
                    }
                }

                let reminders = reminder.checkReminders(for: tracker.progressList)
                if !reminders.isEmpty {
                    VStack(alignment: .leading) {
                        Text("🔔 リマインダー")
                        ForEach(reminders, id: \.self) { msg in
                            Text(msg).foregroundColor(.orange)
                        }
                    }
                }

                if let target = tracker.progressList.sorted(by: { $0.goalDate < $1.goalDate }).first {
                    let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: target.goalDate).day ?? 0
                    let message = blessing.blessing(for: target.name, percent: target.completedPercent, daysLeft: daysLeft)
                    Text(message)
                        .padding()
                        .foregroundColor(.blue)
                }

                if let bubbleText = speech.lastSpokenText {
                    CompanionSpeechBubbleView(text: bubbleText, emotion: spokenEmotion)
                        .padding(.bottom, 12)
                }

                VStack(spacing: 8) {
                    Button("保存") {
                        let entry = ConversationEntry(
                            speaker: "user",
                            text: "資格関連の保存",
                            emotion: "neutral",
                            topic: ConversationSubject(label: "資格-保存")
                        )
                        storage.append(entry)
                        speech.speak("保存しました。引き続き応援します！", language: "ja-JP", rate: 0.5)
                        spokenEmotion = .happy
                    }

                    Button("削除") {
                        if let last = storage.loadAll().last {
                            storage.remove(last)
                            speech.speak("削除しました。必要な情報はいつでも呼び出せます。", language: "ja-JP", rate: 0.5)
                            spokenEmotion = .neutral
                        }
                    }

                    Button("戻る") {
                        speech.speak("前の画面に戻りますね。", language: "ja-JP", rate: 0.5)
                        spokenEmotion = .neutral
                    }

                    Button("次へ") {
                        speech.speak("次のステップへ進みます。", language: "ja-JP", rate: 0.5)
                        spokenEmotion = .happy
                    }

                    Button("メイン画面へ") {
                        speech.speak("ホームに戻ります。", language: "ja-JP", rate: 0.5)
                        spokenEmotion = .neutral
                    }

                    Button("ヘルプ") {
                        speech.speak("この画面では資格の進捗や試験予定、関心度を確認できます。保存や削除も可能です。", language: "ja-JP", rate: 0.5)
                        spokenEmotion = .neutral
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 24)
            }
            .padding()
        }
        .onAppear {
            logs = storage.loadAll().filter {
                $0.topic.label.contains("資格") || $0.emotion == "neutral"
            }

            if let recent = logs.last {
                let message = "資格に関する最近の話題は「\(recent.text)」ですね。引き続き応援します！"
                speech.speak(message, language: "ja-JP", rate: 0.5)
                spokenEmotion = EmotionType(rawValue: recent.emotion) ?? .neutral
            }
        }
    }

    private func reflectCertificationProgress() -> String {
        let certLogs = logs
        let count = certLogs.count
        let recent = certLogs.suffix(3).map { $0.text }
        return "これまでに資格関連で \(count) 件の対話がありました。最近の話題は「\(recent.joined(separator: " / "))」です。"
    }
}
