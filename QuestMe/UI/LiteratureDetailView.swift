//
//  LiteratureDetailView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/LiteratureDetailView.swift
//
//  🎯 ファイルの目的:
//      現代文学ニュース記事の詳細表示。
//      - タイトル、要約、出典、発表日を表示。
//      - 出典URLがある場合は Safari で開けるようにする。
//      - 発話とログ保存を行い、吹き出しUIと連動可能にする。
//
//  🔗 依存:
//      - SwiftUI
//      - LiteratureNewsService.swift
//      - DomainKnowledgeEngine.swift
//      - EmotionType.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月15日
//

import SwiftUI

struct LiteratureDetailView: View {
    let item: LiteratureNewsItem
    @EnvironmentObject var engine: DomainKnowledgeEngine

    @State private var showSpeechBubble = false
    @State private var currentEmotion: EmotionType = .gentle
    @State private var currentSpeechText: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(item.title)
                    .font(.title2)
                    .bold()

                Text(item.summary)
                    .font(.body)
                    .foregroundColor(.primary)

                HStack {
                    Text("出典: \(item.source)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("発表日: \(formatted(item.published))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let url = extractURL(from: item) {
                    Link("🔗 出典を開く", destination: url)
                        .font(.body)
                        .foregroundColor(.blue)
                }

                if showSpeechBubble {
                    CompanionSpeechBubbleView(text: currentSpeechText, emotion: currentEmotion)
                        .padding(.top, 20)
                }
            }
            .padding()
        }
        .onAppear {
            let disclaimer = "※この情報は公開情報に基づきます。断定的な表現は避けています。"
            let reply = "\(disclaimer)\n『\(item.title)』 — \(item.summary)（出典: \(item.source)）"

            currentEmotion = .gentle
            currentSpeechText = reply
            showSpeechBubble = true

            engine.speakAndLog(
                text: reply,
                emotion: .gentle,
                ritual: "LiteratureDetailView",
                metadata: [
                    "literatureTopic": item.topic.rawValue,
                    "source": item.source
                ]
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                showSpeechBubble = false
            }
        }
    }

    private func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }

    private func extractURL(from item: LiteratureNewsItem) -> URL? {
        // 将来的に LiteratureReference と連携して出典URLを返す
        return nil
    }
}
