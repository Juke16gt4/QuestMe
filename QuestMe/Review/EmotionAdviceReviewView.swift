//
//  EmotionAdviceReviewView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Review/EmotionAdviceReviewView.swift
//
//  🎯 ファイルの目的:
//      感情ログとアドバイス履歴を統合表示するレビュー画面。
//      - EmotionLogStorageManager からログを読み込み表示。
//      - CompanionOverlay による語りや PDF 生成と連携予定。
//
//  🔗 依存:
//      - EmotionLogStorageManager.swift（感情ログ読み込み）
//      - EmotionLog.swift（emotion, date, note）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月10日
//

import SwiftUI

struct EmotionAdviceReviewView: View {
    @State private var logs: [EmotionLog] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("感情ログレビュー")
                .font(.title)
                .bold()

            ForEach(logs) { log in
                VStack(alignment: .leading, spacing: 4) {
                    Text("🧠 感情: \(log.emotion.rawValue)")
                        .font(.headline)
                    Text("📅 日付: \(log.date.formatted(.dateTime.year().month().day().hour().minute()))")
                        .font(.subheadline)
                    if let note = log.note {
                        Text("📝 メモ: \(note)")
                            .font(.body)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
        .padding()
        .onAppear {
            logs = EmotionLogStorageManager.shared.loadAll() // ✅ 修正済み
        }
    }
}
