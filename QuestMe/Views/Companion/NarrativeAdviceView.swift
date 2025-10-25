//
//  NarrativeAdviceView.swift
//  QuestMe
//
//  Created by 津村淳一 on 2025/10/05.
//

/**
 NarrativeAdviceView
 -------------------
 目的:
 - Companion が過去の感情記録を物語として語る「ナラティブモード」を提供する。
 - AdviceMemoryLog から履歴を取得し、語り口で提示。
 - CompanionOverlay.speakNarrative により、音声＋吹き出しで語る。

 格納先:
 - Swiftファイル: Views/Companion/NarrativeAdviceView.swift
*/

import SwiftUI

struct NarrativeAdviceView: View {
    @State private var entries: [AdviceFeelingEntry] = []

    var body: some View {
        VStack(spacing: 16) {
            Text("あなたの変化の物語")
                .font(.title2)
                .bold()

            CompanionSpeechBubbleView()

            ScrollView {
                ForEach(entries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("［\(entry.date.prefix(10))］ \(entry.feeling)")
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .onAppear {
            entries = AdviceMemoryStorageManager.shared.fetchFeelingHistory(forPastDays: 30)
            CompanionOverlay.shared.speakNarrative(for: entries)
        }
    }
}
