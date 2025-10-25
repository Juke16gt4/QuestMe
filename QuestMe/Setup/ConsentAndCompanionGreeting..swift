//
//  ConsentAndCompanionGreeting.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Setup/ConsentAndCompanionGreeting.swift
//
//  🎯 ファイルの目的:
//      初期設定時にユーザーの法的同意を取得し、選択された母語で Companion が歓迎の挨拶を行う儀式ビュー。
//      - 「利用規約に同意しますか？」という明示的な確認と、言語に応じた挨拶文の表示。
//      - LocalizedCompanionSpeech.greeting(for:) を使用して、文化的共鳴を演出。
//      - 同意が完了した場合のみ、次のステップに進行可能。
//
//  🔗 依存:
//      - LocalizedCompanionSpeech.greeting(for:)（言語別挨拶文）
//      - @Binding var language（母語コード）
//      - @Binding var consentGiven（同意状態）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月30日

import SwiftUI

public struct ConsentAndCompanionGreeting: View {
    @Binding var language: String
    @Binding var consentGiven: Bool

    public var body: some View {
        VStack(spacing: 20) {
            Text("利用規約に同意しますか？")
            Button("同意する") {
                consentGiven = true
            }
            Text(LocalizedCompanionSpeech.greeting(for: language))
                .font(.title)
        }
    }
}
