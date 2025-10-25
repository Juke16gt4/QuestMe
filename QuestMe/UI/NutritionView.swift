//
//  NutritionView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/NutritionView.swift
//
//  🎯 ファイルの目的:
//      栄養学モードのUI。
//      - 入力を分類し、ニュース取得。
//      - 免責文を必ず前置し、断定表現を弱めて安全化。
//      - 音声同期と追記専用ログ保存を行う。
//
//  🔗 依存:
//      - SwiftUI
//      - AVFoundation
//      - NutritionModels.swift
//      - NutritionTopicClassifier.swift
//      - NutritionNewsService.swift
//      - NutritionEthicsPolicy.swift
//      - StorageService.swift
//      - SpeechSync.swift
//      - CompanionViews.swift
//
//  👤 修正者: 津村 淳一
//  📅 修正日: 2025年10月23日
//

import SwiftUI
import AVFoundation

struct NutritionView: View {
    @EnvironmentObject var storage: StorageService
    @EnvironmentObject var speech: SpeechSync
    @StateObject var classifier = NutritionTopicClassifier()
    @StateObject var news = NutritionNewsService()
    @State private var userText: String = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("栄養学モード").font(.headline)

            HStack {
                TextField("栄養に関する質問を入力してください", text: $userText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("確認") { handleQuery() }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(storage.loadAll().filter { $0.speaker == "companion" }, id: \.id) { entry in
                        CompanionPhraseView(
                            phrase: entry.text,
                            emotion: EmotionType(rawValue: entry.emotion) ?? .neutral
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }

    private func handleQuery() {
        let trimmed = userText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let topic = classifier.classify(trimmed)
        let disclaimer = NutritionDisclaimerProvider.disclaimerJP()

        Task {
            let items = await news.fetchLatest(for: topic)
            let info = items.first

            var header = "\(disclaimer)\n"
            var body = "テーマ: \(topic)。最近の関連情報です。"

            if let i = info {
                let safeTitle = NutritionToneGuard.soften(i.title)
                let safeSummary = NutritionToneGuard.soften(i.summary)
                body += "『\(safeTitle)』 — \(safeSummary)（\(NutritionToneGuard.enforceSourcePrefix(i.source))）"
            } else {
                body += "公式資料に基づく確認を推奨します。"
            }

            let reply = header + body

            speech.speak(reply, language: "ja-JP", rate: 0.5)

            let userEntry = ConversationEntry(
                speaker: "user",
                text: trimmed,
                emotion: EmotionType.neutral.rawValue,
                topic: ConversationSubject(label: topic.rawValue)
            )
            let companionEntry = ConversationEntry(
                speaker: "companion",
                text: reply,
                emotion: "thinking", // ← informative ではなく既存の EmotionType に置き換え
                topic: ConversationSubject(label: topic.rawValue)
            )

            storage.append(userEntry)
            storage.append(companionEntry)

            userText = ""
        }
    }
}
