//
//  MedicalView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/MedicalView.swift
//
//  🎯 ファイルの目的:
//      医学モードのUI。
//      - 入力を分類し、ニュース取得。
//      - 免責文を必ず前置。
//      - 音声同期とログ保存を行う。
//
//  🔗 依存:
//      - SwiftUI
//      - AVFoundation
//      - MedicalModels.swift
//      - MedicalTopicClassifier.swift
//      - MedicalNewsService.swift
//      - MedicalEthicsPolicy.swift
//      - StorageService.swift
//      - SpeechSync.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月12日
//

import SwiftUI
import AVFoundation

struct MedicalView: View {
    @EnvironmentObject var storage: StorageService
    @EnvironmentObject var speech: SpeechSync
    @StateObject var classifier = MedicalTopicClassifier()
    @StateObject var news = MedicalNewsService()
    @State private var userText: String = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("医学モード").font(.headline)

            HStack {
                TextField("医学に関する質問を入力してください", text: $userText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("確認") { handleQuery() }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(storage.loadAll().filter { $0.speaker == "companion" }, id: \.id) { entry in
                        CompanionPhraseView(phrase: entry.text, emotion: entry.emotion)
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
        let disclaimer = MedicalDisclaimerProvider.disclaimerJP()

        Task {
            let items = await news.fetchLatest(for: topic)
            let info = items.first

            var header = "\(disclaimer)\n"
            var body = "テーマ: \(topic)。最近の関連情報です。"

            if let i = info {
                let safeTitle = MedicalToneGuard.soften(i.title)
                let safeSummary = MedicalToneGuard.soften(i.summary)
                body += "『\(safeTitle)』 — \(safeSummary)（\(MedicalToneGuard.enforceSourcePrefix(i.source))）"
            } else {
                body += "公式資料に基づく確認を推奨します。"
            }

            let reply = header + body

            // 音声同期
            speech.speak(reply, language: "ja-JP", rate: 0.5)

            // ログ保存（emotion を String に統一）
            let userEntry = ConversationEntry(
                speaker: "user",
                text: trimmed,
                emotion: "neutral",
                topic: ConversationSubject(label: topic)
            )
            let companionEntry = ConversationEntry(
                speaker: "companion",
                text: reply,
                emotion: "informative",
                topic: ConversationSubject(label: topic)
            )

            storage.append(userEntry)
            storage.append(companionEntry)

            // 入力欄をリセット
            userText = ""
        }
    }
}
