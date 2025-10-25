//
//  CertificationHistoryView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Certification/CertificationHistoryView.swift
//
//  🎯 ファイルの目的:
//      資格ごとの学習履歴を一覧表示し、検索・タグ絞り込み・お気に入り・再出題・復習リスト化を可能にする。
//
//  🔗 依存:
//      - CompanionOverlay.shared.speak()
//      - ProblemBankService.swift（再出題）
//      - ReviewQuizView.swift（復習モード）
//

import SwiftUI

struct CertificationHistoryView: View {
    let certificationName: String
    
    @State private var allFiles: [URL] = []
    @State private var filteredFiles: [URL] = []
    @State private var selectedFile: URL? = nil
    @State private var content: String = ""
    @State private var searchKeyword: String = ""
    @State private var availableTags: [String] = []
    @State private var selectedTag: String? = nil
    @State private var favorites: Set<URL> = []
    @State private var showReviewQuiz = false
    @State private var reviewKeywords: [String] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                // 検索バー
                HStack {
                    TextField("キーワードで検索", text: $searchKeyword)
                        .textFieldStyle(.roundedBorder)
                    Button("検索") { applyFilters() }
                        .buttonStyle(.borderedProminent)
                }
                
                // タグフィルター
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button("すべて") {
                            selectedTag = nil
                            applyFilters()
                        }
                        .buttonStyle(.bordered)
                        ForEach(availableTags, id: \.self) { tag in
                            Button(tag) {
                                selectedTag = tag
                                applyFilters()
                            }
                            .buttonStyle(.bordered)
                            .tint(selectedTag == tag ? .blue : .gray)
                        }
                    }
                }
                
                // 履歴一覧
                List(filteredFiles, id: \.self) { url in
                    HStack {
                        Button(action: { openFile(url) }) {
                            VStack(alignment: .leading) {
                                Text(url.lastPathComponent)
                                    .font(.headline)
                                Text(url.deletingLastPathComponent().lastPathComponent)
                                    .font(.caption).foregroundColor(.gray)
                            }
                        }
                        Spacer()
                        Button(action: { toggleFavorite(url) }) {
                            Image(systemName: favorites.contains(url) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .navigationTitle("📚 学習履歴: \(certificationName)")
                .onAppear { loadFiles() }
                
                // お気に入りから復習リスト作成
                if !favorites.isEmpty {
                    Button("⭐ お気に入りから復習リストを作成") {
                        reviewKeywords = extractKeywords(from: Array(favorites))
                        showReviewQuiz = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
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
                    Button("🔁 この履歴から再出題") {
                        reviewKeywords = extractKeywords(from: [selectedFile].compactMap { $0 })
                        showReviewQuiz = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("📣 アドバイスを読み上げ") {
                        let (title, advice) = extractTitleAndAdvice(from: content)
                        CompanionOverlay.shared.speak("履歴より。\(title)。アドバイスは次の通りです。\(advice)", emotion: .gentle)
                    }
                    .buttonStyle(.bordered)
                    
                    Button("閉じる") {
                        // Companion拡大画面へ戻る処理
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showReviewQuiz) {
            ReviewQuizView(
                weakPointName: "復習リスト（\(certificationName)）",
                reviewQuestions: generateReviewQuestions(from: reviewKeywords)
            )
        }
    }
    
    // MARK: - ファイル読み込み・検索・フィルター
    private func loadFiles() {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let folder = dir.appendingPathComponent(certificationName)
        let files = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil))?
            .filter { $0.pathExtension.lowercased() == "md" } ?? []
        allFiles = files.sorted(by: { $0.lastPathComponent > $1.lastPathComponent })
        filteredFiles = allFiles
        extractTags()
    }
    
    private func applyFilters() {
        filteredFiles = allFiles.filter { url in
            let nameMatch = url.lastPathComponent.localizedCaseInsensitiveContains(searchKeyword)
            let folderMatch = url.deletingLastPathComponent().lastPathComponent.localizedCaseInsensitiveContains(searchKeyword)
            let contentMatch: Bool = {
                if searchKeyword.isEmpty { return true }
                if let text = try? String(contentsOf: url) {
                    return text.localizedCaseInsensitiveContains(searchKeyword)
                }
                return false
            }()
            let tagMatch: Bool = {
                guard let tag = selectedTag else { return true }
                if let text = try? String(contentsOf: url),
                   let idx = text.split(separator: "\n").firstIndex(where: { $0.contains("📌 関連キーワード") }) {
                    let lines = text.split(separator: "\n").map(String.init)
                    if idx + 1 < lines.count {
                        let raw = lines[idx + 1].replacingOccurrences(of: "- ", with: "")
                        return raw.contains(tag)
                    }
                }
                return false
            }()
            return (nameMatch || folderMatch || contentMatch) && tagMatch
        }
    }
    
    private func openFile(_ url: URL) {
        selectedFile = url
        content = (try? String(contentsOf: url)) ?? ""
    }
    
    private func toggleFavorite(_ url: URL) {
        if favorites.contains(url) {
            favorites.remove(url)
        } else {
            favorites.insert(url)
        }
    }
    
    private func extractTitleAndAdvice(from text: String) -> (String, String) {
        let lines = text.split(separator: "\n")
        let title = lines.first.map(String.init) ?? "履歴"
        if let idx = lines.firstIndex(where: { $0.contains("AIからのアドバイス") }) {
            let advice = lines.dropFirst(idx + 1).joined(separator: "\n")
            return (title, advice)
        }
        return (title, "アドバイスは見つかりませんでした。")
    }
    
    private func extractTags() {
        var tagSet: Set<String> = []
        for file in allFiles {
            if let text = try? String(contentsOf: file) {
                let lines = text.split(separator: "\n").map(String.init)
                if let idx = lines.firstIndex(where: { $0.contains("📌 関連キーワード") }),
                   idx + 1 < lines.count {
                    let raw = lines[idx + 1].replacingOccurrences(of: "- ", with: "")
                    let tags = raw.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    tagSet.formUnion(tags)
                }
            }
        }
        availableTags = Array(tagSet).sorted()
    }
    
    private func extractKeywords(from urls: [URL]) -> [String] {
        var keywords: [String] = []
        for url in urls {
            if let text = try? String(contentsOf: url) {
                let lines = text.split(separator: "\n").map(String.init)
                if let idx = lines.firstIndex(where: { $0.contains("📌 関連キーワード") }),
                   idx + 1 < lines.count {
                    let raw = lines[idx + 1].replacingOccurrences(of: "- ", with: "")
                    let tags = raw.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    keywords.append(contentsOf: tags)
                }
            }
        }
        return Array(Set(keywords)).sorted()
    }
}
