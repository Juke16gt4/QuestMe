//
//  MotherTongueSelectionView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Setup/MotherTongueSelectionView.swift
//
//  🎯 ファイルの目的:
//      ユーザーの母語を選択するための UI ビュー。
//      - LanguageManager.shared.supportedLanguages に準拠し、言語コードの整合性を保証。
//      - 選択された言語コードは Companion の語り口や UI 表示に反映される。
//      - 初期設定儀式の入口として、文化的共鳴を生む重要な役割を担う。
//
//  🔗 依存:
//      - LanguageManager.shared.supportedLanguages（言語コード一覧）
//      - SupportedLanguage（表示名変換）
//      - @Binding var selectedLanguage（選択状態）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月30日

import SwiftUI

public struct MotherTongueSelectionView: View {
    @Binding var selectedLanguage: String

    private let supportedCodes = LanguageManager.shared.supportedLanguages

    public var body: some View {
        VStack(spacing: 16) {
            Text("あなたの母語を選んでください")
                .font(.title)
                .padding(.bottom, 8)

            ForEach(supportedCodes, id: \.self) { code in
                Button(action: {
                    selectedLanguage = code
                }) {
                    Text(displayName(for: code))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedLanguage == code ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }

    private func displayName(for code: String) -> String {
        SupportedLanguage(rawValue: code)?.displayName ?? code
    }
}
