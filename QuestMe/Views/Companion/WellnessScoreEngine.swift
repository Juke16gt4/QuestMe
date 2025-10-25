//
//  WellnessScoreEngine.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/WellnessScoreEngine.swift
//
//  🎯 ファイルの目的:
//      ユーザーの1日分の記録（感情・食事・服薬・検査）をもとに、健康スコア（0〜100点）を算出するビュー。
//      - DayInsightView や ScheduleAndEventDialogView から起動。
//      - スコアは感情・栄養・服薬・検査の4要素で構成。
//      - スコアに応じてAIコンパニオンがコメントを表示。
//
//  🔗 依存:
//      - EmotionLog.swift
//      - NutritionLog.swift
//      - MedicationLog.swift
//      - LabResult.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月9日

import SwiftUI

struct WellnessScoreEngine: View {
    let date: Date
    @State private var score: Int = 0
    @State private var comment: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("💚 健康スコア")
                .font(.title2)
                .bold()

            Text("\(score) 点")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(scoreColor(score))

            Text(comment)
                .font(.body)
                .foregroundColor(.blue)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            Spacer()
        }
        .padding()
        .onAppear {
            calculateScore(for: date)
        }
    }

    func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }

    func calculateScore(for date: Date) {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dateStr = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none).replacingOccurrences(of: "/", with: "-")
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let root = docs.appendingPathComponent("Calendar/\(year)年/\(month)月")

        var total = 0

        // 感情
        if let data = try? Data(contentsOf: root.appendingPathComponent("感情/\(dateStr).json")),
           let log = try? JSONDecoder().decode(EmotionLog.self, from: data) {
            if log.mood.contains("元気") || log.mood.contains("落ち着いている") {
                total += 25
            } else {
                total += 15
            }
        }

        // 食事
        if let data = try? Data(contentsOf: root.appendingPathComponent("Nutrition/\(dateStr).json")),
           let log = try? JSONDecoder().decode(NutritionLog.self, from: data) {
            total += min(log.meals.count * 5, 25)
        }

        // 服薬
        if let data = try? Data(contentsOf: root.appendingPathComponent("服薬/\(dateStr).json")),
           let log = try? JSONDecoder().decode(MedicationLog.self, from: data) {
            total += log.items.isEmpty ? 0 : 25
        }

        // 検査
        if let data = try? Data(contentsOf: root.appendingPathComponent("血液検査結果/\(dateStr).json")),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let values = json["values"] as? [String: String] {
            let abnormalCount = values.filter { isAbnormal(key: $0.key, value: $0.value) }.count
            total += abnormalCount == 0 ? 25 : max(10, 25 - abnormalCount * 5)
        }

        score = total
        comment = generateComment(score: total)
    }

    func isAbnormal(key: String, value: String) -> Bool {
        let thresholds: [String: Double] = ["HbA1c": 6.0, "血糖": 110, "白血球": 10000]
        guard let t = thresholds[key], let v = Double(value) else { return false }
        return v > t
    }

    func generateComment(score: Int) -> String {
        switch score {
        case 80...: return "とても良い状態です。この調子で続けましょう。"
        case 60..<80: return "まずまずの状態です。少しだけ意識してみましょう。"
        default: return "少し疲れが見えるかもしれません。無理せず休息をとりましょう。"
        }
    }
}
