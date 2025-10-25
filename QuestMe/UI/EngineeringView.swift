//
//  EngineeringView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/EngineeringView.swift
//
//  🎯 ファイルの目的:
//      工学モードのUI。
//      - 話題入力 → 分類 → ニュース取得 → 表示。
//      - StorageService / EngineeringTopicClassifier / EngineeringNewsService と連動。
//      - SwiftUI + @EnvironmentObject による依存注入。
//
//  🔗 依存:
//      - ConversationSubject.swift
//      - StorageService.swift
//      - EngineeringTopicClassifier.swift
//      - EngineeringNewsService.swift
//
//  👤 作成者: 津村 淳一
//  📅 修正日: 2025年10月23日
//

import SwiftUI
import Combine

struct EngineeringView: View {
    @EnvironmentObject var storage: StorageService
    @EnvironmentObject var classifier: EngineeringTopicClassifier
    @EnvironmentObject var newsService: EngineeringNewsService

    @State private var inputText: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("工学モード").font(.title2).bold()

            TextField("工学の話題を入力", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("分類と取得") {
                let subject = ConversationSubject(label: inputText)
                classifier.classify(subject)
                Task {
                    await newsService.fetch(for: subject)

                    // ログ保存
                    let userEntry = ConversationEntry(
                        speaker: "user",
                        text: inputText,
                        emotion: "neutral",
                        topic: subject
                    )
                    storage.append(userEntry)

                    for article in newsService.articles {
                        let compEntry = ConversationEntry(
                            speaker: "companion",
                            text: article,
                            emotion: "informative",
                            topic: subject
                        )
                        storage.append(compEntry)
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Text("分類結果: \(classifier.classification)")
                .font(.headline)
                .padding(.top, 8)

            List {
                ForEach(newsService.articles, id: \.self) { article in
                    Text("・\(article)")
                }
            }
        }
        .padding()
    }
}
