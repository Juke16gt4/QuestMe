//
//  SummaryViewerView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Certification/SummaryViewerView.swift
//
//  🎯 ファイルの目的:
//      保存済みの「弱点克服まとめ（.md）」を一覧表示・閲覧・音声要約再生する。
//      - フォルダは各弱点命題（例: 薬理学、計算問題）。
//      - ファイル名は「yyyyMMdd_NN.md」（日付＋連番）を想定。
//      - 選択したまとめのタイトル＋アドバイスを音声で読み上げる。
//      - フォルダ横断検索（簡易）。
//
//  🔗 依存:
//      - CompanionOverlay.shared.speak()
//      - MarkdownTextView（任意：Markdown整形用。なければTextで表示）
//

import SwiftUI

struct SummaryViewerView: View {
    @State private var folders: [URL] = []
    @State private var files: [URL] = []
    @State private var selectedFile: URL? = nil
    @State private var content: String = ""
    @State private var searchKeyword: String = ""

    var body: some View {
        NavigationView {
            VStack {
                // フォルダ横断の簡易検索
                HStack {
                    TextField("キーワード（弱点命題 or ファイル名）で検索", text: $searchKeyword)
                        .textFieldStyle(.roundedBorder)
                    Button("検索") { loadFiles(keyword: searchKeyword) }
                        .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)

                List(files, id: \.self) { url in
                    Button(action: { openFile(url) }) {
                        VStack(alignment: .leading) {
                            Text(url.lastPathComponent)
                                .font(.headline)
                            Text(url.deletingLastPathComponent().lastPathComponent)
                                .font(.caption).foregroundColor(.gray)
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("📖 弱点克服まとめ 一覧")
            }
            .onAppear { loadFolders(); loadFiles(keyword: "") }

            // 閲覧ビュー
            VStack(alignment: .leading, spacing: 8) {
                Text(selectedFile?.lastPathComponent ?? "ファイル未選択")
                    .font(.headline)
                ScrollView {
                    Text(content.isEmpty ? "ここにMarkdownが表示されます。" : content)
                        .font(.footnote)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }

                HStack {
                    Button("タイトル＋アドバイスを読み上げ") {
                        let (title, advice) = extractTitleAndAdvice(from: content)
                        CompanionOverlay.shared.speak("前回のまとめです。\(title)。アドバイスは次の通りです。\(advice)", emotion: .gentle)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("閉じる") {
                        // Companion拡大画面へ戻る処理（モーダルならdismiss）
                    }
                    .buttonStyle(.bordered)
                }
                Spacer()
            }
            .padding()
        }
    }

    // MARK: - フォルダ＆ファイル読み込み
    private func loadFolders() {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                folders = contents.filter { $0.hasDirectoryPath }
            } catch { folders = [] }
        }
    }

    private func loadFiles(keyword: String) {
        files = []
        for folder in folders {
            do {
                let mdFiles = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    .filter { $0.pathExtension.lowercased() == "md" }
                let filtered = keyword.isEmpty
                    ? mdFiles
                    : mdFiles.filter { $0.lastPathComponent.localizedCaseInsensitiveContains(keyword) || folder.lastPathComponent.localizedCaseInsensitiveContains(keyword) }
                files.append(contentsOf: filtered.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }))
            } catch { continue }
        }
    }

    // MARK: - ファイルオープン
    private func openFile(_ url: URL) {
        selectedFile = url
        content = (try? String(contentsOf: url)) ?? ""
    }

    // MARK: - タイトル＋アドバイス抽出
    private func extractTitleAndAdvice(from text: String) -> (String, String) {
        let lines = text.split(separator: "\n")
        let title = lines.first.map(String.init) ?? "弱点克服まとめ"
        if let idx = lines.firstIndex(where: { $0.contains("AIからのアドバイス") }) {
            let advice = lines.dropFirst(idx + 1).joined(separator: "\n")
            return (title, advice)
        }
        return (title, "アドバイスは見つかりませんでした。")
    }
}
