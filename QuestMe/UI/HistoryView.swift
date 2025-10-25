//
//  HistoryView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/HistoryView.swift
//
//  🎯 ファイルの目的:
//      歴史モードのUIを提供する。
//      - ユーザーが話題を入力し、ConversationSubject として保持。
//      - HistoryTopicClassifier による分類結果を表示。
//      - HistoryNewsService による関連ニュースを取得・表示。
//      - StorageService に保存された ConversationEntry の履歴を一覧表示。
//      - SwiftUI + Combine によるリアクティブな状態管理を実現。
//
//  🔗 依存:
//      - StorageService.swift（selectedSubject を追加）
//      - ConversationSubject.swift
//      - ConversationEntry.swift
//      - HistoryTopicClassifier.swift
//      - HistoryNewsService.swift
//
//  👤 作成者: 津村 淳一
//  📅 修正日: 2025年10月23日
//

import SwiftUI
import Foundation
import Combine

struct HistoryView: View {
    @EnvironmentObject var storage: StorageService
    @EnvironmentObject var classifier: HistoryTopicClassifier
    @EnvironmentObject var newsService: HistoryNewsService
    @Published var selectedSubject: ConversationSubject = ConversationSubject(label: "")

    @State private var inputText: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("歴史モード")
                .font(.title2)
                .bold()

            // ユーザー入力欄
            TextField("歴史の話題を入力", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            // 分類とニュース取得
            Button("分類と取得") {
                let subject = ConversationSubject(label: inputText)
                storage.selectedSubject = subject
                classifier.classify(subject)
                Task {
                    await newsService.fetch(for: subject)
                }
            }
            .buttonStyle(.borderedProminent)

            // 分類結果表示
            Text("分類結果: \(classifier.classification)")
                .font(.headline)

            // ニュース記事一覧
            List {
                ForEach(newsService.articles, id: \.self) { article in
                    Text("・\(article)")
                }
            }

            Divider()

            Text("過去の会話履歴")
                .font(.title3)

            // 会話履歴一覧
            List {
                ForEach(storage.loadAll(), id: \.id) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🗣 \(entry.speaker)")
                            .font(.subheadline)
                        Text(entry.text)
                        Text("感情: \(entry.emotion)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("話題: \(entry.topic.label)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            inputText = storage.selectedSubject.label
        }
    }
}
