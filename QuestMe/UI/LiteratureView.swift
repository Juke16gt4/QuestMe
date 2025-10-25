//
//  LiteratureView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/LiteratureView.swift
//
//  🎯 ファイルの目的:
//      現代文学モードのUI。
//      - 入力を分類し、ニュース取得。
//      - 免責文を必ず前置し、断定表現を弱めて安全化。
//      - 音声同期と追記専用ログ保存を行う。
//      - DomainKnowledgeEngine を利用して記事を取得。
//      - CompanionSpeechBubbleView と連動して吹き出し表示。
//
//  🔗 依存:
//      - SwiftUI
//      - AVFoundation
//      - DomainKnowledgeEngine.swift
//      - EmotionType.swift
//      - CompanionSpeechBubbleView.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月15日
//

import SwiftUI
import AVFoundation

struct LiteratureView: View {
    @EnvironmentObject var engine: DomainKnowledgeEngine

    @State private var userText: String = ""
    @State private var showSpeechBubble = false
    @State private var currentEmotion: EmotionType = .gentle
    @State private var currentSpeechText: String = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("現代文学モード").font(.headline)

            HStack {
                TextField("文学に関する質問や作家名を入力してください", text: $userText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("確認") { handleQuery() }
            }

            if showSpeechBubble {
                CompanionSpeechBubbleView(text: currentSpeechText, emotion: currentEmotion)
                    .padding(.horizontal, 16)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(engine.articles, id: \.self) { title in
                        Text("・\(title)")
                            .font(.body)
                            .foregroundColor(.primary)
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

        // Subject を設定
        engine.currentSubject = ConversationSubject(label: trimmed)
        Task {
            await engine.fetchNews(for: engine.currentSubject)

            let disclaimer = "※この情報は文学賞や文芸誌などの公開情報に基づきます。断定的な表現は避けています。"
            let reply = "\(disclaimer)\nテーマ: \(engine.currentSubject.label)。最近の関連情報です。"

            // 吹き出し表示
            currentEmotion = .gentle
            currentSpeechText = reply
            showSpeechBubble = true

            // 発話＋ログ保存
            engine.speakAndLog(
                text: reply,
                emotion: .gentle,
                ritual: "LiteratureView",
                metadata: [
                    "classification": engine.classification,
                    "subject": engine.currentSubject.label,
                    "articlesCount": engine.articles.count
                ]
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                showSpeechBubble = false
            }
        }
    }
}
