//
//  DayInsightView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Calendar/DayInsightView.swift
//
//  🎯 ファイルの目的:
//      ユーザーの1日分の記録（感情・食事・服薬・検査）を振り返るビュー。
//      - 感情ログ・食事記録・服薬記録・検査結果を表示。
//      - CompanionSpeechBubble や WellnessScoreEngine と連携。
//      - 保存形式: Calendar/年/月/カテゴリ/日.json
//
//  🔗 依存:
//      - EmotionLog.swift
//      - NutritionLog.swift
//      - MedicationLog.swift
//      - LabResult.swift（Modelsに統一）
//      - CompanionSectionView.swift（Sharedに統一）
//      - CompanionSpeechBubble.swift
//      - WellnessScoreEngine.swift
//
//  👤 製作者: 津村 淳一
//  📅 修正日: 2025年10月9日

import SwiftUI

struct DayInsightView: View {
    let date: Date
    @State private var emotion: EmotionLog?
    @State private var nutrition: NutritionLog?
    @State private var medication: MedicationLog?
    @State private var labResult: LabResult?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("📅 \(formattedDate(date)) の振り返り")
                    .font(.title2)
                    .bold()

                CompanionSectionView(
                    title: "💚 健康スコア",
                    content: AnyView(WellnessScoreEngine(date: date))
                )

                if let emotion = emotion {
                    CompanionSectionView(
                        title: "😊 感情ログ",
                        content: AnyView(
                            VStack(alignment: .leading, spacing: 4) {
                                Text("気分: \(emotion.mood)")
                                if !emotion.notes.isEmpty {
                                    Text("メモ: \(emotion.notes)")
                                }
                            }
                        )
                    )
                }

                if let nutrition = nutrition {
                    CompanionSectionView(
                        title: "🍽️ 食事記録",
                        content: AnyView(
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(nutrition.meals, id: \.self) { meal in
                                    Text(meal)
                                }
                            }
                        )
                    )
                }

                if let medication = medication {
                    CompanionSectionView(
                        title: "💊 服薬記録",
                        content: AnyView(
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(medication.items, id: \.self) { item in
                                    Text(item)
                                }
                            }
                        )
                    )
                }

                if let result = labResult {
                    CompanionSectionView(
                        title: "🩺 検査結果",
                        content: AnyView(
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(result.values.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                    HStack {
                                        Text(key)
                                        Spacer()
                                        Text(value)
                                            .foregroundColor(isAbnormal(key: key, value: value) ? .red : .primary)
                                    }
                                }
                                if !result.notes.isEmpty {
                                    Text("🧠 \(result.notes)")
                                        .font(.callout)
                                        .foregroundColor(.blue)
                                }
                            }
                        )
                    )
                }

                CompanionSectionView(
                    title: "🗣️ コンパニオンの案内",
                    content: AnyView(CompanionSpeechBubble())
                )
            }
            .padding()
            .onAppear {
                loadAllLogs()
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    func loadAllLogs() {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dateStr = formattedDate(date)
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let root = docs.appendingPathComponent("Calendar/\(year)年/\(month)月")

        if let data = try? Data(contentsOf: root.appendingPathComponent("感情/\(dateStr).json")),
           let log = try? JSONDecoder().decode(EmotionLog.self, from: data) {
            emotion = log
        }

        if let data = try? Data(contentsOf: root.appendingPathComponent("Nutrition/\(dateStr).json")),
           let log = try? JSONDecoder().decode(NutritionLog.self, from: data) {
            nutrition = log
        }

        if let data = try? Data(contentsOf: root.appendingPathComponent("服薬/\(dateStr).json")),
           let log = try? JSONDecoder().decode(MedicationLog.self, from: data) {
            medication = log
        }

        if let data = try? Data(contentsOf: root.appendingPathComponent("血液検査結果/\(dateStr).json")),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let values = json["values"] as? [String: String],
           let notes = json["notes"] as? String {
            labResult = LabResult(id: UUID(), date: dateStr, values: values, notes: notes)
        }
    }

    func isAbnormal(key: String, value: String) -> Bool {
        let abnormalThresholds: [String: Double] = [
            "HbA1c": 6.0,
            "血糖": 110,
            "白血球": 10000
        ]
        guard let threshold = abnormalThresholds[key],
              let val = Double(value) else { return false }
        return val > threshold
    }
}
