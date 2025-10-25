//
//  TopicSearchView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Knowledge/TopicSearchView.swift
//
//  🎯 ファイルの目的:
//      ユーザーがキーワードでトピックスを検索し、必要な情報を確認する。
//      - 検索キーワードを入力（テキスト or 音声）。
//      - 結果を提示し「必要ですか？」と確認。
//      - 違う場合は「キーワードを増やすと見つかりやすい」と促す。
//      - 終了処理は知識確認と同じ（印刷・保存・メール送信・終了）。
//
//  🔗 依存:
//      - EndOptionsView.swift
//      - CompanionOverlay.shared.speak()
//

import SwiftUI

struct TopicSearchView: View {
    @State private var keyword: String = ""
    @State private var searchResult: String?
    @State private var showContinuePrompt = false
    @State private var showEndOptions = false

    var body: some View {
        VStack(spacing: 20) {
            // ✅ 目的付きヘッダー
            VStack(spacing: 8) {
                Text("🔍 トピックス検索")
                    .font(.title2).bold()
                Text("ここではキーワードでトピックスを検索できます。音声入力も可能です。")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            HStack {
                TextField("検索キーワードを入力（音声でも入力できます）", text: $keyword)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                Button("検索") {
                    searchResult = "検索結果: \(keyword) に関する情報を表示中…"
                    CompanionOverlay.shared.speak("検索結果を表示しました。必要な情報ですか？", emotion: .gentle)
                    showContinuePrompt = true
                }
            }

            if let result = searchResult {
                Text(result)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }

            // 継続確認
            if showContinuePrompt {
                Divider()
                HStack {
                    Button("はい、必要です") {
                        CompanionOverlay.shared.speak("必要な情報が見つかってよかったです。", emotion: .happy)
                        showContinuePrompt = false
                        showEndOptions = true
                    }
                    Button("いいえ、違います") {
                        CompanionOverlay.shared.speak("キーワードを増やすと、求めているトピックスが見つかりやすくなりますよ。", emotion: .encouraging)
                        keyword = ""
                        searchResult = nil
                        showContinuePrompt = false
                    }
                }
            }

            // 終了処理
            if showEndOptions {
                Divider()
                EndOptionsView(
                    folderName: "トピックス",
                    fileName: generateFileName(from: keyword),
                    content: searchResult ?? ""
                )
            }

            Spacer()
        }
        .padding()
        .onAppear {
            // ✅ 初回のみ音声案内
            let hasShownGuide = UserDefaults.standard.bool(forKey: "TopicSearchGuideShown")
            if !hasShownGuide {
                CompanionOverlay.shared.speak(
                    "この画面では、キーワードを入力してトピックスを検索できます。音声でも入力できますよ。",
                    emotion: .gentle
                )
                UserDefaults.standard.set(true, forKey: "TopicSearchGuideShown")
            }
        }
    }

    private func generateFileName(from text: String) -> String {
        let keyword = text.split(separator: " ").first ?? "topic"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return "\(keyword)_\(formatter.string(from: Date()))"
    }
}
