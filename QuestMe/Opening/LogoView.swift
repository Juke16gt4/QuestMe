//
//  LogoView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Opening/LogoView.swift
//
//  🎯 ファイルの目的:
//      ロゴ儀式ビュー。アプリ起動時にロゴと母語に応じた挨拶を表示。
//      - LanguageManager を通じて localizedString を取得。
//      - QuestMe の世界観を言語と視覚で伝える冒頭演出。
//
//  🔗 依存:
//      - LanguageManager.swift（言語管理）
//      - OpeningConstants.swift（初期挨拶）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月30日

import SwiftUI

public struct LogoView: View {
    @ObservedObject private var languageManager = LanguageManager.shared

    public var body: some View {
        VStack(spacing: 20) {
            // ロゴ表示
            Image(systemName: "star.circle.fill")
                .resizable()
                .frame(width: 120, height: 120)
                .foregroundColor(.accentColor)

            // 言語に応じた挨拶
            Text(languageManager.localizedString(for: "welcome"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
