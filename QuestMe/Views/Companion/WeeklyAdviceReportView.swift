//
//  WeeklyAdviceReportView.swift
//  QuestMe
//
//  Created by 津村淳一 on 2025/10/05.
//

/**
 WeeklyAdviceReportView
 ----------------------
 目的:
 - Companion が過去7日間のアドバイスと会話履歴を振り返り、音声＋吹き出しで提示する。
 - AdviceLog から抽出した内容を時系列で表示。
 - 継続対話モードとして「今週どう感じましたか？」と問いかけ、ユーザーの感情を記録。
 - 記録された感情に応じてパーソナライズされた励ましを提示。
 - 最後にナラティブモードとして、感情履歴を物語として語り、週次レポートを締めくくる。

 格納先:
 - Swiftファイル: Views/Companion/WeeklyAdviceReportView.swift
*/

import SwiftUI

struct WeeklyAdviceReportView: View {
    @State private var entries: [AdviceEntry] = []
    @State private var feelings: [AdviceFeelingEntry] = []

    var body: some View {
        VStack(spacing: 16) {
            Text("今週の振り返り")
                .font(.title2)
                .bold()

            CompanionSpeechBubbleView()

            ScrollView {
                ForEach(entries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("［\(entry.type)］ \(entry.content)")
                            .font(.body)
                        Text(entry.date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .onAppear {
            entries = AdviceStorageManager.shared.fetchAdviceLog(forPastDays: 7)
            CompanionOverlay.shared.speakWeeklySummary(entries: entries)

            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                CompanionOverlay.shared.askWeeklyFeeling { feeling in
                    AdviceMemoryStorageManager.shared.saveFeeling(feeling)
                    CompanionOverlay.shared.speak("記録しました。", emotion: .happy)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        CompanionOverlay.shared.speakEncouragementBasedOnFeeling()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                            feelings = AdviceMemoryStorageManager.shared.fetchFeelingHistory(forPastDays: 30)
                            CompanionOverlay.shared.speakNarrative(for: feelings)
                        }
                    }
                }
            }
        }
    }
}
