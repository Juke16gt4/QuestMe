//
//  DayInsightEntryView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Calendar/DayInsightEntryView.swift
//
//  🎯 ファイルの目的:
//      ユーザーが1日分の記録（感情・食事・服薬）を入力・保存するビュー。
//      - 保存形式は Calendar/年/月/カテゴリ/日.json に準拠。
//      - DayInsightView で統合表示される。
//      - CompanionAdviceView に連携可能。
//
//  🔗 依存:
//      - EmotionLog.swift
//      - NutritionLog.swift
//      - MedicationLog.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月9日

import SwiftUI

struct DayInsightEntryView: View {
    let date: Date
    @State private var mood: String = ""
    @State private var emotionNotes: String = ""
    @State private var meals: [String] = ["", "", "", ""]
    @State private var medications: [String] = [""]

    var body: some View {
        Form {
            Section("感情ログ") {
                TextField("気分（例：元気、疲れた）", text: $mood)
                ZStack(alignment: .topLeading) {
                    if emotionNotes.isEmpty {
                        Text("例：今日は少し眠かったけど、午後から元気になった")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }
                    TextEditor(text: $emotionNotes)
                        .frame(height: 100)
                }
            }

            Section("食事記録") {
                ForEach(0..<meals.count, id: \.self) { index in
                    TextField("食事 \(index + 1)（例：朝食：納豆ご飯）", text: $meals[index])
                }
            }

            Section("服薬記録") {
                ForEach(0..<medications.count, id: \.self) { index in
                    TextField("服薬 \(index + 1)（例：ロサルタン 50mg）", text: $medications[index])
                }
                Button("服薬項目を追加") {
                    medications.append("")
                }
            }

            Button("記録を保存") {
                saveLogs()
            }
        }
        .navigationTitle("1日の記録")
    }

    func saveLogs() {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dateStr = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none).replacingOccurrences(of: "/", with: "-")
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let root = docs.appendingPathComponent("Calendar/\(year)年/\(month)月")

        // 感情ログ
        let emotion = EmotionLog(mood: mood, notes: emotionNotes)
        let emotionData = try? JSONEncoder().encode(emotion)
        try? fm.createDirectory(at: root.appendingPathComponent("感情"), withIntermediateDirectories: true)
        try? emotionData?.write(to: root.appendingPathComponent("感情/\(dateStr).json"))

        // 食事記録
        let nutrition = NutritionLog(meals: meals.filter { !$0.isEmpty })
        let nutritionData = try? JSONEncoder().encode(nutrition)
        try? fm.createDirectory(at: root.appendingPathComponent("Nutrition"), withIntermediateDirectories: true)
        try? nutritionData?.write(to: root.appendingPathComponent("Nutrition/\(dateStr).json"))

        // 服薬記録
        let medication = MedicationLog(items: medications.filter { !$0.isEmpty })
        let medicationData = try? JSONEncoder().encode(medication)
        try? fm.createDirectory(at: root.appendingPathComponent("服薬"), withIntermediateDirectories: true)
        try? medicationData?.write(to: root.appendingPathComponent("服薬/\(dateStr).json"))
    }
}
