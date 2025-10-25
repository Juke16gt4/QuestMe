//
//  InteractiveCompanionAdviceView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/InteractiveCompanionAdviceView.swift
//
//  🎯 ファイルの目的:
//      ユーザーの1日分の記録（感情・食事・服薬・検査結果）をもとに、AIコンパニオンが語りかけるアドバイスを生成・表示するビュー。
//      - DayInsightView や カレンダーから遷移可能。
//      - CompanionSpeechBubble と連携し、感情に寄り添った語りかけを行う。
//      - 異常値や偏りがある場合は優しく指摘し、改善提案を行う。
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

struct InteractiveCompanionAdviceView: View {
    let date: Date
    let emotionLog: EmotionLog?
    let nutritionLog: NutritionLog?
    let medicationLog: MedicationLog?
    let labResult: LabResult?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("コンパニオンからのアドバイス")
                .font(.title2)
                .bold()

            Text(generateAdvice())
                .font(.body)
                .foregroundColor(.blue)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            Spacer()
        }
        .padding()
        .navigationTitle(formattedDate(date))
    }

    func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .long
        f.locale = Locale(identifier: "ja_JP")
        return f.string(from: date)
    }

    func generateAdvice() -> String {
        var message = ""

        // 感情
        if let mood = emotionLog?.mood {
            switch mood {
            case "元気":
                message += "今日は元気そうですね。この調子で過ごしましょう。\n"
            case "疲れた":
                message += "少しお疲れのようですね。無理せず休息をとりましょう。\n"
            case "落ち着いている":
                message += "穏やかな一日だったようですね。心の安定は大切です。\n"
            default:
                message += "今日の気分、しっかり記録されていますね。\n"
            }
        }

        // 食事
        if let meals = nutritionLog?.meals {
            if meals.count < 2 {
                message += "食事が少なめのようです。栄養バランスを意識してみましょう。\n"
            } else {
                message += "食事の記録、ありがとうございます。バランスよく摂れているようですね。\n"
            }
        }

        // 服薬
        if let meds = medicationLog?.items, meds.isEmpty {
            message += "服薬記録がありません。飲み忘れがないか確認してみましょう。\n"
        } else if let meds = medicationLog?.items {
            message += "服薬記録、しっかり残されていますね。\n"
        }

        // 検査
        if let lab = labResult {
            for (key, value) in lab.values {
                if isAbnormal(key: key, value: value) {
                    message += "検査結果「\(key)」が少し高めです。生活習慣を見直してみましょう。\n"
                }
            }
            if lab.notes.isEmpty == false {
                message += "AI解析コメント：\(lab.notes)\n"
            }
        }

        if message.isEmpty {
            message = "今日も記録ありがとうございます。明日も一緒に振り返りましょう。"
        }

        return message
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
