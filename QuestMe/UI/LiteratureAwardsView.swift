//
//  LiteratureAwardsView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/LiteratureAwardsView.swift
//
//  🎯 ファイルの目的:
//      文学賞受賞作の特集表示。
//      - 複数の受賞作を並べて比較。
//      - タイトル・要約・出典・発表日を表示。
//      - 出典URLがある場合はリンクを提供。
//      - 発話とログ保存を行い、吹き出しUIと連動可能にする。
//
//  🔗 依存:
//      - SwiftUI
//      - LiteratureNewsService.swift
//      - DomainKnowledgeEngine.swift
//      - EmotionType.swift
//      - CompanionSpeechBubbleView.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月15日
//

import SwiftUI

struct LiteratureAwardsView: View {
    @EnvironmentObject var engine: DomainKnowledgeEngine
    @State private var awardItems: [LiteratureNewsItem] = []

    @State private var showSpeechBubble = false
    @State private var currentEmotion: EmotionType = .gentle
    @State private var currentSpeechText: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("🏆 文学賞受賞作 特集")
                .font(.title2)
                .bold()

            if showSpeechBubble {
                CompanionSpeechBubbleView(text: currentSpeechText, emotion: currentEmotion)
                    .padding(.horizontal, 16)
            }

            if awardItems.isEmpty {
                Text("現在、文学賞の受賞作情報は取得されていません。")
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(awardItems) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.summary)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                HStack {
                                    Text("出典: \(item.source)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("発表日: \(formatted(item.published))")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                // 文学賞トピックでニュース取得
                let items = await engine.literatureNews.fetchLatest(for: .award)
                awardItems = items

                let disclaimer = "※この情報は文学賞公式サイトや文芸誌に基づきます。断定的な表現は避けています。"
                let reply = "\(disclaimer)\n文学賞受賞作の最新情報をお届けします。"

                currentEmotion = .gentle
                currentSpeechText = reply
                showSpeechBubble = true

                engine.speakAndLog(
                    text: reply,
                    emotion: .gentle,
                    ritual: "LiteratureAwardsView",
                    metadata: [
                        "literatureTopic": LiteratureTopic.award.rawValue,
                        "articlesCount": awardItems.count
                    ]
                )

                DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                    showSpeechBubble = false
                }
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
}
