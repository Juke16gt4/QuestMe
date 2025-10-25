//
//  LiteratureAwardsComparisonView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/LiteratureAwardsComparisonView.swift
//
//  🎯 ファイルの目的:
//      複数の文学賞受賞作を横並びで比較表示する。
//      - タイトル、要約、出典、発表日を比較。
//      - テーマや作風の違いを視覚的に把握可能。
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

struct LiteratureAwardsComparisonView: View {
    @EnvironmentObject var engine: DomainKnowledgeEngine
    @State private var awardItems: [LiteratureNewsItem] = []

    @State private var showSpeechBubble = false
    @State private var currentEmotion: EmotionType = .gentle
    @State private var currentSpeechText: String = ""

    // レイアウト用：横並び比較
    private let columns = [
        GridItem(.flexible(minimum: 150), spacing: 12),
        GridItem(.flexible(minimum: 150), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("🏆 文学賞受賞作 比較ビュー")
                .font(.title2)
                .bold()

            if showSpeechBubble {
                CompanionSpeechBubbleView(text: currentSpeechText, emotion: currentEmotion)
                    .padding(.horizontal, 16)
            }

            if awardItems.isEmpty {
                Text("現在、比較可能な文学賞受賞作は取得されていません。")
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(awardItems) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(item.summary)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(3)
                                Text("出典: \(item.source)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("発表日: \(formatted(item.published))")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
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
                awardItems = items + [
                    LiteratureNewsItem(
                        title: "新人文学賞受賞作",
                        summary: "新進作家による革新的なテーマの小説が受賞しました。",
                        source: "Demo Award Source",
                        published: Date(),
                        topic: .award
                    ),
                    LiteratureNewsItem(
                        title: "詩の文学賞受賞作",
                        summary: "現代詩の新しい潮流を示す作品が高く評価されました。",
                        source: "Demo Poetry Award",
                        published: Date(),
                        topic: .award
                    )
                ]

                let disclaimer = "※この情報は文学賞公式サイトや文芸誌に基づきます。断定的な表現は避けています。"
                let reply = "\(disclaimer)\n複数の文学賞受賞作を比較表示します。"

                currentEmotion = .gentle
                currentSpeechText = reply
                showSpeechBubble = true

                engine.speakAndLog(
                    text: reply,
                    emotion: .gentle,
                    ritual: "LiteratureAwardsComparisonView",
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
