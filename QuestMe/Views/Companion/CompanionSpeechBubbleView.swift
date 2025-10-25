//
//  CompanionSpeechBubbleView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionSpeechBubbleView.swift
//
//  🎯 目的:
//      コンパニオンの発話を吹き出しで表示する。
//      最大4行、1.4倍拡大アニメーション、長文は自動スクロールで進行する。
//      EmotionType に応じて吹き出し背景色・アイコンを揃える。
//
//  🔗 依存:
//      - EmotionType.swift（色・アイコン）
//      - SwiftUI（UI表示）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月11日
//

import SwiftUI

struct CompanionSpeechBubbleView: View {
    let text: String
    let emotion: EmotionType

    private var bubbleColor: Color {
        switch emotion {
        case .happy: return .yellow
        case .sad: return .blue.opacity(0.6)
        case .angry: return .red.opacity(0.7)
        case .surprised: return .purple.opacity(0.6)
        case .gentle, .encouraging: return .green.opacity(0.6)
        case .thinking: return .mint
        case .neutral: return .gray.opacity(0.5)
        }
    }

    var body: some View {
        Text(text)
            .padding(12)
            .background(bubbleColor)
            .cornerRadius(12)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
