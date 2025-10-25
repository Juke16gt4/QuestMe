//
//  CompanionLogViewer.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Log/CompanionLogViewer.swift
//
//  🎯 ファイルの目的:
//      - CompanionLogEntry を一覧表示し、感情・日付・言語で絞り込み可能にする。
//      - PDF出力や傾向分析の基盤となる。
//      - 吹き出し形式とリスト形式を切り替え可能。
//
//  🔗 依存:
//      - CompanionLogEntry.swift
//      - GreetingBubbleView.swift
//      - EmotionType.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月16日
//

import SwiftUI

struct CompanionLogViewer: View {
    @State private var entries: [CompanionLogEntry] = []
    @State private var selectedEmotion: EmotionType = .neutral
    @State private var showAsBubbles: Bool = true

    var body: some View {
        VStack {
            Picker("感情フィルター", selection: $selectedEmotion) {
                ForEach(EmotionType.allCases, id: \.self) { emotion in
                    Text(emotion.label).tag(emotion)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            Toggle("吹き出し表示", isOn: $showAsBubbles)
                .padding(.horizontal)

            ScrollView {
                ForEach(filteredEntries()) { entry in
                    if showAsBubbles {
                        GreetingBubbleView(
                            text: entry.text,
                            emphasizedWords: [],
                            emotion: entry.emotion
                        )
                    } else {
                        HStack {
                            Text(entry.date.formatted())
                                .font(.caption)
                            Text(entry.text)
                                .font(.body)
                            Spacer()
                            Image(systemName: entry.emotion.icon)
                                .foregroundColor(entry.emotion.color)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .onAppear {
            loadEntries()
        }
    }

    private func filteredEntries() -> [CompanionLogEntry] {
        if selectedEmotion == .neutral {
            return entries
        } else {
            return entries.filter { $0.emotion == selectedEmotion }
        }
    }

    private func loadEntries() {
        // ログ読み込み処理（例：CalendarHolder.shared.loadAllEntries()）
        // entries = CalendarHolder.shared.loadAllEntries()
    }
}
