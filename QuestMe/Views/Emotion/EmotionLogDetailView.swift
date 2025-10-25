//
//  EmotionLogDetailView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Emotion/EmotionLogDetailView.swift
//
//  🎯 目的:
//      おでかけログ（1件）を個別に表示。
//      - 感想、写真、日時、座標、地点名を明示。
//      - 将来的に編集・削除・共有に拡張可能。
//
//  🔗 関連:
//      - EmotionLogViewer.swift（一覧 → 個別遷移）
//      - EmotionLogFileWriter.swift（保存元）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import SwiftUI

struct EmotionLogDetailView: View {
    let log: EmotionLogFile

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(log.placeName)
                    .font(.title)
                    .bold()

                Text("日時: \(formattedDate(log.timestamp))")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("座標: \(log.latitude), \(log.longitude)")
                    .font(.caption2)

                if let comment = log.comment {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("感想")
                            .font(.headline)
                        Text(comment)
                            .font(.body)
                            .padding(.bottom, 8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let image = log.image {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("写真")
                            .font(.headline)
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // 今後の拡張：編集・削除・共有ボタン
                /*
                HStack {
                    Button("編集") { ... }
                    Button("削除") { ... }
                    Button("共有") { ... }
                }
                */
            }
            .padding()
        }
        .navigationTitle("ログ詳細")
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}
