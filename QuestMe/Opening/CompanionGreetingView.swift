//
//  CompanionGreetingView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Opening/CompanionGreetingView.swift
//
//  🎯 ファイルの目的:
//      - コンパニオンの起動挨拶を表示・読み上げ。
//      - 初回表示時に画面操作の説明を音声で案内。
//      - LocalizationManager による母国語対応。
//      - CompanionStyle に応じた挨拶と操作説明を生成。
//
//  🔗 依存:
//      - CompanionGreetingEngine.swift（挨拶文・操作説明）
//      - CompanionStyle.swift（スタイル定義）
//      - LocalizationManager.swift（@EnvironmentObject）
//
//  👤 製作者: 津村 淳一
//  📅 修正日: 2025年10月16日
//

import SwiftUI
import AVFoundation

struct CompanionGreetingView: View {
    let style: CompanionStyle
    @EnvironmentObject var locale: LocalizationManager
    @State private var hasSpokenIntro = false

    var body: some View {
        let greeting = CompanionGreetingEngine.shared.openingGreeting(for: style, in: locale.current)
        let instruction = CompanionGreetingEngine.shared.openingInstruction(for: style, in: locale.current)

        VStack(spacing: 24) {
            GreetingBubbleView(
                text: greeting.text,
                emphasizedWords: greeting.emphasizedWords,
                emotion: style.toEmotion()
            )

            if !hasSpokenIntro {
                GreetingBubbleView(
                    text: instruction.text,
                    emphasizedWords: instruction.emphasizedWords,
                    emotion: .gentle
                )
                .onAppear {
                    speak(instruction.text)
                    saveGreetingLog(greeting.text)
                    hasSpokenIntro = true
                }
            }
        }
        .padding()
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: locale.speechCode())
        utterance.rate = 0.5
        AVSpeechSynthesizer().speak(utterance)
    }

    private func saveGreetingLog(_ text: String) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let folderName = formatter.string(from: date)
        let fileName = folderName + "_1.txt"

        let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("QuestMe/Logs/\(folderName.prefix(4))/\(folderName.prefix(6))/\(folderName.prefix(8))")

        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        let fileURL = folderURL.appendingPathComponent(fileName)

        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
            print("✅ Greeting saved to: \(fileURL.path)")
        } catch {
            print("❌ 保存失敗: \(error.localizedDescription)")
        }
    }
}
