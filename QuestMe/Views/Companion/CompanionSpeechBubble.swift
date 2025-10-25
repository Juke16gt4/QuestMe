//
//  CompanionSpeechBubble.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionSpeechBubble.swift
//
//  🎯 ファイルの目的:
//      血液検査読み取り時に、AIコンパニオンがユーザーに案内する吹き出しビュー。
//      - 文字サイズ1.4倍の強調表示を含む。
//      - カレンダー保存場所とアクセス方法を丁寧に説明。
//      - UserProfileView.swift から呼び出される。
//
//  🔗 依存:
//      - SwiftUI（UI構築）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月9日

import SwiftUI

struct CompanionSpeechBubble: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("血液検査結果の読み取りを")
                .font(.body)

            Text("開始します。")
                .font(.body.weight(.semibold))
                .scaleEffect(1.4, anchor: .leading)

            Text("読み取ったデータは、カレンダーの当日フォルダーに保存されますので、いつでもご覧いただけます。")
                .font(.body)

            Text("カレンダー機能は、AIコンパニオンの拡大画面下部にある「ユーザープロファイル設定」ボタンからアクセスできます。")
                .font(.body)

            Text("そちらにある「カレンダー」ボタンを押していただくと、保存された検査結果をご確認いただけます。")
                .font(.body)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .padding()
    }
}
