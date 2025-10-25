//
//  CompanionDialogueView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionDialogueView.swift
//
//  🎯 ファイルの目的:
//      AIコンパニオンの語りかけに対して、ユーザーが返信できる対話型ビュー。
//      - ユーザーの返信は日付付きで保存され、振り返りに活用可能。
//      - CompanionAdviceView から遷移可能。
//      - 保存形式: Calendar/年/月/対話/日.json
//
//  🔗 依存:
//      - AVFoundation（音声）
//      - FileManager（保存）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月9日

import SwiftUI
import AVFoundation

struct CompanionDialogueView: View {
    let date: Date
    let advice: String
    @State private var userReply: String = ""
    @State private var saved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("コンパニオンの語りかけ")
                .font(.headline)
            Text(advice)
                .font(.body)
                .foregroundColor(.blue)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            Button("音声で聞く") {
                let utterance = AVSpeechUtterance(string: advice)
                utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
                utterance.rate = 0.5
                AVSpeechSynthesizer().speak(utterance)
            }

            Divider()

            Text("あなたの返信")
                .font(.headline)
            TextEditor(text: $userReply)
                .frame(height: 120)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))

            Button("返信を保存") {
                saveReply()
                saved = true
            }

            if saved {
                Text("✅ 返信を保存しました")
                    .foregroundColor(.green)
            }

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

    func saveReply() {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dateStr = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none).replacingOccurrences(of: "/", with: "-")
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let folder = docs.appendingPathComponent("Calendar/\(year)年/\(month)月/対話")
        try? fm.createDirectory(at: folder, withIntermediateDirectories: true)

        let payload: [String: Any] = [
            "date": dateStr,
            "advice": advice,
            "reply": userReply
        ]

        if let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]) {
            try? data.write(to: folder.appendingPathComponent("\(dateStr).json"))
        }
    }
}
