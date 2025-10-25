//
//  LanguageSetupView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Setup/LanguageSetupView.swift
//
//  🎯 ファイルの目的:
//      初回起動時の言語選択儀式ビュー。
//      - 最小構成で言語選択を行い、onComplete() により次のステップへ進行。
//      - 今後のローカライズ対応に備えた構造。
//      - Companion の母語設定や挨拶文に反映される。
//
//  🔗 依存:
//      - CompanionSetupView.swift（初期設定フロー）
//      - CompanionGreetingEngine.swift（挨拶文生成）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月6日

import SwiftUI

struct LanguageSetupView: View {
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("言語を選択してください")
                .font(.title2)
                .bold()

            // 仮の選択肢（将来ローカライズに差し替え）
            Button("日本語") { onComplete() }
                .buttonStyle(.borderedProminent)

            Button("English") { onComplete() }
                .buttonStyle(.bordered)
        }
        .padding()
    }
}

struct LanguageSetupView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageSetupView(onComplete: {})
    }
}
