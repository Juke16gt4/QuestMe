//
//  DashboardView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Certification/DashboardView.swift
//
//  🎯 ファイルの目的:
//      資格モードのダッシュボード。
//      - Markdown ファイルの統計表示
//      - タグ別統計 (TagStat)
//      - ユーザー入力と分類
//
//  🔗 連動ファイル:
//      - Core/Model/TagStat.swift
//      - CertificationTopicClassifier.swift
//      - StorageService.swift
//      - ConversationEntry.swift
//
//  👤 作成者: 津村 淳一
//  📅 修正日: 2025年10月16日
//

import SwiftUI
import Foundation

struct DashboardView: View {
    @EnvironmentObject var storage: StorageService
    @EnvironmentObject var classifier: CertificationTopicClassifier

    @State private var subjectText: String = ""
    @State private var markdownFiles: [URL] = []
    @State private var tagStats: [TagStat] = []

    var body: some View {
        VStack(spacing: 16) {
            Text("📊 ダッシュボード")
                .font(.title2).bold()

            // 入力欄
            TextField("資格関連の話題を入力", text: $subjectText)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("分類") {
                // ✅ String を渡すだけ
                classifier.classify(subjectText)

            }
            .buttonStyle(.borderedProminent)

            // 分類結果の表示（Published を監視）
            Text("分類結果: \(classifier.classification)")
                .font(.headline)

            Divider()

            // Markdown ファイル一覧
            VStack(alignment: .leading) {
                Text("📂 Markdown ファイル一覧").font(.headline)
                let safeFiles = markdownFiles
                Text("ファイル数: \(safeFiles.count)")
                List {
                    ForEach(safeFiles, id: \.self) { file in
                        Text(file.lastPathComponent)
                    }
                }
                .frame(height: 200)
            }

            Divider()

            // タグ統計
            VStack(alignment: .leading) {
                Text("🏷️ タグ統計").font(.headline)
                if tagStats.isEmpty {
                    Text("タグデータがありません").foregroundColor(.gray)
                } else {
                    ForEach(tagStats) { stat in
                        HStack {
                            Text(stat.name)
                            Spacer()
                            Text("\(stat.count) 件 (\(String(format: "%.1f", stat.correctRate))%)")
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            loadMarkdownFiles()
            loadDummyTagStats()
        }
    }

    private func loadMarkdownFiles() {
        let fm = FileManager.default
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            markdownFiles = []
            return
        }
        let files = (try? fm.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil)) ?? []
        markdownFiles = files.filter { $0.pathExtension.lowercased() == "md" }
    }

    private func loadDummyTagStats() {
        tagStats = [
            TagStat(name: "医療", count: 3, correctRate: 70.0),
            TagStat(name: "法律", count: 2, correctRate: 60.0),
            TagStat(name: "IT", count: 5, correctRate: 80.0)
        ]
    }
}
