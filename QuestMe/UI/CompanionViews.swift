//
//  CompanionViews.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/CompanionViews.swift
//
//  🎯 ファイルの目的:
//      コンパニオン吹き出しUI。
//      - 発話を1.4倍で表示。
//      - 感情ごとの色・グラデーション・アニメーションを適用。
//
//  🔗 依存:
//      - SwiftUI
//      - Models.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import SwiftUI

struct CompanionPhraseView: View {
    let phrase: String
    let emotion: CompanionEmotion
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Text(phrase)
            .font(fontForEmotion())
            .foregroundColor(colorForEmotion())
            .scaleEffect(1.4)
            .padding(10)
            .background(gradientForEmotion())
            .cornerRadius(12)
            .shadow(color: shadowColor(), radius: reduceMotion ? 0 : 4)
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.7),
                       value: phrase)
            .accessibilityLabel("コンパニオン発言")
    }

    private func fontForEmotion() -> Font {
        switch emotion {
        case .joy: return .system(size: 20, weight: .semibold)
        case .sad: return .system(size: 18, weight: .light)
        case .anger: return .system(size: 20, weight: .bold)
        default: return .system(size: 18, weight: .regular)
        }
    }

    private func colorForEmotion() -> Color {
        switch emotion {
        case .joy: return .orange
        case .sad: return .blue
        case .anger: return .red
        default: return .primary
        }
    }

    private func gradientForEmotion() -> LinearGradient {
        switch emotion {
        case .joy:
            return LinearGradient(colors: [.yellow.opacity(0.6), .orange.opacity(0.6)],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sad:
            return LinearGradient(colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        case .anger:
            return LinearGradient(colors: [.red.opacity(0.6), .red.opacity(0.9)],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.gray.opacity(0.2), .white.opacity(0.4)],
                                  startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private func shadowColor() -> Color {
        switch emotion {
        case .joy: return .orange.opacity(0.4)
        case .sad: return .blue.opacity(0.3)
        case .anger: return .red.opacity(0.5)
        default: return .black.opacity(0.2)
        }
    }
}
