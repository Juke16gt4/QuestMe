//
//  KnowledgeCheckView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Knowledge/KnowledgeCheckView.swift
//
//  🎯 ファイルの目的:
//      ユーザーが自由に質問を入力し、AIコンパニオンが正誤や補足を提示する。
//      - 入力はテキストまたは音声で可能（自動判定）。
//      - 入力開始時は1.4倍拡大表示 → 標準サイズへ戻る。
//      - AIが補足やアドバイスをテキスト＋音声で提示。
//      - アナウンス終了後に「継続しますか？」と音声で確認。
//      - 「終わります」で終了処理（印刷・保存・メール送信・終了）。
//
//  🔗 依存:
//      - EndOptionsView.swift
//      - CompanionOverlay.shared.speak()
//

import SwiftUI

struct KnowledgeCheckView: View {
    @State private var userInput: String = ""
    @FocusState private var isFocused: Bool
    @State private var scale: CGFloat = 1.0
    @State private var aiResponse: String = ""
    @State private var showContinuePrompt = false
    @State private var showEndOptions = false

    var body: some View {
        VStack(spacing: 20) {
            // ✅ 目的付きヘッダー
            VStack(spacing: 8) {
                Text("📖 知識確認")
                    .font(.title2).bold()
                Text("ここでは質問を入力し、AIコンパニオンが正誤や補足を提示します。音声入力も可能です。")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            // 入力欄
            TextField("ここに質問を入力してください（音声でも入力できます）", text: $userInput)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                .focused($isFocused)
                .scaleEffect(scale)
                .onChange(of: isFocused) { focused in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        scale = focused ? 1.4 : 1.0
                    }
                }

            // 入力があればAI応答
            if !userInput.isEmpty {
                VStack(spacing: 12) {
                    Text("AIの補足・アドバイス")
                        .font(.headline)
                    Text(aiResponse.isEmpty ? "解析中…" : aiResponse)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    Button("アナウンス終了 → 継続確認") {
                        aiResponse = "\(userInput) に関する補足やアドバイスを提示しました。"
                        CompanionOverlay.shared.speak("継続しますか？", emotion: .gentle)
                        showContinuePrompt = true
                    }
                }
            }

            // 継続確認
            if showContinuePrompt {
                Divider()
                HStack {
                    Button("続けます") {
                        CompanionOverlay.shared.speak("引き続きアドバイスを続けます。", emotion: .encouraging)
                        userInput = ""
                        aiResponse = ""
                        showContinuePrompt = false
                    }
                    Button("終わります") {
                        CompanionOverlay.shared.speak("終了処理に移ります。", emotion: .neutral)
                        showContinuePrompt = false
                        showEndOptions = true
                    }
                }
            }

            // 終了処理
            if showEndOptions {
                Divider()
                EndOptionsView(
                    folderName: "専門知識",
                    fileName: generateFileName(from: userInput),
                    content: aiResponse
                )
            }

            Spacer()
        }
        .padding()
        .onAppear {
            // ✅ 初回のみ音声案内
            let hasShownGuide = UserDefaults.standard.bool(forKey: "KnowledgeCheckGuideShown")
            if !hasShownGuide {
                CompanionOverlay.shared.speak(
                    "この画面では、質問を入力して知識を確認できます。音声でも入力できますよ。",
                    emotion: .gentle
                )
                UserDefaults.standard.set(true, forKey: "KnowledgeCheckGuideShown")
            }
        }
    }

    private func generateFileName(from text: String) -> String {
        let keyword = text.split(separator: " ").first ?? "query"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return "\(keyword)_\(formatter.string(from: Date()))"
    }
}
