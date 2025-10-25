//
//  ExerciseLogView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Exercise/ExerciseLogView.swift
//
//  🎯 ファイルの目的:
//      過去に記録された運動履歴を一覧表示するビュー。
//      - 活動名、METs、時間、消費カロリー、記録日時を明示。
//      - ユーザーが自分の努力を振り返り、継続のモチベーションを高める。
//      - 将来的にはフィルター、グラフ表示、エクスポートにも対応可能。
//
//  🔗 依存:
//      - ExerciseStorageManager.swift（履歴取得）
//      - ExerciseEntry（Managers 定義のモデル）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import SwiftUI

struct ExerciseLogView: View {
    @State private var logs: [ExerciseEntry] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(logs, id: \.id) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🕒 \(formatted(log.timestamp))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("🏃‍♂️ \(log.activityName)")
                            .font(.headline)
                        Text("🔥 消費カロリー: \(Int(log.calories)) kcal")
                        Text("⏱ 時間: \(log.durationMinutes) 分")
                        Text("⚖️ 体重: \(Int(log.weightKg)) kg")
                        Text("📊 METs: \(String(format: "%.1f", log.mets))")
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("運動履歴")
            .onAppear {
                logs = ExerciseStorageManager.shared.fetchAll()
            }
        }
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}
