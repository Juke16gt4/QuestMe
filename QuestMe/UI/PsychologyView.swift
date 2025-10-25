//
//  PsychologyView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/PsychologyView.swift
//
//  🎯 ファイルの目的:
//      心理・社会福祉分野の話題とニュースを表示し、感情同期と音声案内を提供する。
//      - DomainKnowledgeEngine から現在の話題（ConversationSubject）を取得
//      - 分類とニュース取得を統合
//      - CompanionOverlay による発話と吹き出し表示
//
//  🔗 依存:
//      - ConversationSubject.swift
//      - DomainKnowledgeEngine.swift
//      - EmotionType.swift
//      - CompanionSpeechBubbleView.swift
//
//  👤 製作者: 津村 淳一
//  📅 修正日: 2025年10月15日
//

import SwiftUI

struct PsychologyView: View {
    @EnvironmentObject var engine: DomainKnowledgeEngine

    @State private var showSpeechBubble = false
    @State private var currentEmotion: EmotionType = .gentle
    @State private var currentSpeechText: String = ""

    var body: some View {
        VStack(spacing: 20) {
            if showSpeechBubble {
                CompanionSpeechBubbleView(text: currentSpeechText, emotion: currentEmotion)
                    .padding(.horizontal, 16)
            }

            Text("🧠 心理・社会福祉の話題")
                .font(.title2)
                .bold()

            Text("現在の話題: \(engine.currentSubject.label)")
                .foregroundColor(.secondary)

            Divider()

            if engine.articles.isEmpty {
                Text("現在、関連ニュースは取得されていません。")
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            } else {
                List(engine.articles, id: \.self) { title in
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            let text = "心理や社会福祉の話題を表示します。気になるテーマがあれば話しかけてください。"
            currentEmotion = .gentle
            currentSpeechText = text
            showSpeechBubble = true

            engine.speakAndLog(
                text: text,
                emotion: .gentle,
                ritual: "PsychologyView",
                metadata: [
                    "classification": engine.classification,
                    "subject": engine.currentSubject.label,
                    "articlesCount": engine.articles.count
                ]
            )

            Task {
                await engine.fetchNews(for: engine.currentSubject)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                showSpeechBubble = false
            }
        }
    }
}
