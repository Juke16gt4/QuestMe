//
//  DailyExerciseRecordView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Exercise/DailyExerciseRecordView.swift
//
//  🎯 ファイルの目的:
//      指定された日付フォルダ内の運動記録ファイルを読み取り、一覧表示する。
//      - Documents/Exercise/YYYY-MM-DD/record_*.json を読み込む。
//      - Companion が記録件数や合計カロリーを音声で応援する。
//      - 今後、編集・削除・エクスポートにも拡張可能。
//
//  🔗 依存:
//      - ExerciseRecord.swift（モデル）
//      - CompanionOverlay.swift（音声）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月8日
//

import SwiftUI

struct DailyExerciseRecordView: View {
    let folderName: String
    @State private var records: [ExerciseRecord] = []

    var body: some View {
        VStack(spacing: 16) {
            Text("📂 \(folderName) の記録")
                .font(.title2)
                .bold()

            if records.isEmpty {
                Text("記録が見つかりませんでした。")
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(records.indices, id: \.self) { index in
                        let record = records[index]
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🏃‍♂️ \(record.activity.name)")
                                .font(.headline)
                            Text("⏱ 時間: \(record.durationMinutes) 分 ・ ⚖️ 体重: \(Int(record.weightKg)) kg")
                                .font(.subheadline)
                            Text("📅 記録日時: \(formatted(record.date))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            loadRecords()
        }
    }

    private func loadRecords() {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Exercise/\(folderName)", isDirectory: true)

        guard let files = try? FileManager.default.contentsOfDirectory(at: base, includingPropertiesForKeys: nil) else {
            return
        }

        let jsonFiles = files.filter { $0.pathExtension == "json" }

        var loaded: [ExerciseRecord] = []
        let decoder = JSONDecoder()
        for file in jsonFiles {
            if let data = try? Data(contentsOf: file),
               let record = try? decoder.decode(ExerciseRecord.self, from: data) {
                loaded.append(record)
            }
        }

        records = loaded.sorted { $0.date < $1.date }

        let totalKcal = loaded.reduce(0.0) { sum, r in
            let hours = Double(r.durationMinutes) / 60.0
            return sum + r.activity.mets * hours * r.weightKg * 1.05
        }

        CompanionOverlay.shared.speak("\(folderName) の記録は \(loaded.count) 件、合計 \(Int(totalKcal)) キロカロリーです。素晴らしいですね！")
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: date)
    }
}
