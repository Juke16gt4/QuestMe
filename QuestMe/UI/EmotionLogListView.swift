//
//  EmotionLogListView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/EmotionLogListView.swift
//
//  🎯 目的:
//      Core Data に保存された感情ログの検証・可視化。
//      削除操作は提供しない（“心臓部”保護）。
//

import SwiftUI

struct EmotionLogListView: View {
    @State private var logs: [EmotionLog] = []

    var body: some View {
        List(logs, id: \.uuid) { log in
            VStack(alignment: .leading, spacing: 4) {
                Text("\(log.emotion) • \(formatted(log.timestamp))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(log.text)
                    .font(.body)
                if let ritual = log.ritual, !ritual.isEmpty {
                    Text("ritual: \(ritual)").font(.caption).foregroundColor(.blue)
                }
                if let metadata = log.metadata, !metadata.isEmpty {
                    Text(metadata).font(.caption2).foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)
        }
        .onAppear { logs = EmotionLogRepository.shared.fetchRecent() }
        .navigationTitle("Emotion logs")
    }

    private func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}
