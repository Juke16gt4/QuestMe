//
//  CompanionView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionView.swift
//
//  🎯 ファイルの目的:
//      アプリ起動中に常駐するフローティング・コンパニオンビュー。
//      - isExpanded により拡大表示に切り替え可能。
//      - 表情（CompanionExpression）と会話ログを保持。
//      - ダブルタップで拡大・表情変化・ログ表示を行う。
//      - GeometryReader により画面サイズに対応。
//      - 初回表示時に CompanionOverlay.greetOnLogin() を呼び出す。
//
//  🔗 依存:
//      - CompanionExpression.swift（表情）
//      - CompanionOverlay.swift（演出・挨拶処理）
//      - CompanionOverlayExpandedView.swift（拡張）
//      - MedicationDialog.swift（おくすり登録）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月10日
//

import SwiftUI

struct CompanionView: View {
    @State private var messages: [String] = []
    @State private var expression: CompanionExpression = .neutral
    @State private var showingMedicationDialog = false
    @State private var greeted = false   // 初回挨拶フラグ

    var body: some View {
        VStack {
            // コンパニオンの顔（表情）
            Text(expression.rawValue)
                .font(.system(size: 80))

            // メッセージログ
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(messages, id: \.self) { msg in
                        Text(msg)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding()

            // 入力欄
            HStack {
                Button("💊 おくすり登録") {
                    showingMedicationDialog = true
                }
                .sheet(isPresented: $showingMedicationDialog) {
                    MedicationDialog()
                }

                Spacer()

                Button("テスト発話") {
                    receiveUserMessage("ありがとう")
                }
            }
            .padding()
        }
        .onAppear {
            // 初回表示時のみ挨拶を呼ぶ
            if !greeted {
                CompanionOverlay.shared.greetOnLogin()
                greeted = true
            }
        }
    }

    // MARK: - メッセージ処理関数
    private func receiveUserMessage(_ text: String) {
        messages.append("🧑‍💻: \(text)")
        updateExpression(for: text)
    }

    private func updateExpression(for input: String) {
        if input.contains("?") {
            expression = .confused
        } else if input.contains("ありがとう") {
            expression = .smile
        } else if input.contains("悲しい") {
            expression = .sadness
        } else if input.contains("怒ってる") {
            expression = .anger
        } else {
            expression = .calm
        }
    }
}
