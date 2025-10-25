//
//  CompanionGrowthView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionGrowthView.swift
//
//  🎯 ファイルの目的:
//      コンパニオンの現在の感情スコアと成長レベルを可視化。
//      - joy / sadness / anger / surprise / trust の数値を表示
//      - growthLevel を段階バーで表示
//      - currentToneHint を吹き出し風に表示
//
//  🔗 依存:
//      - CompanionEmotionManager.swift
//      - EmotionType.swift
//      - CompanionSpeechBubbleView.swift（任意）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月23日
//

import SwiftUI

struct CompanionGrowthView: View {
    @State private var state = CompanionEmotionManager.shared.state
    @State private var toneHint = CompanionEmotionManager.shared.currentToneHint

    var body: some View {
        VStack(spacing: 16) {
            Text("🧠 コンパニオンの感情状態")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 8) {
                EmotionBar(label: "😊 喜び", value: state.joy, color: .yellow)
                EmotionBar(label: "😢 悲しみ", value: state.sadness, color: .blue)
                EmotionBar(label: "😠 怒り", value: state.anger, color: .red)
                EmotionBar(label: "😲 驚き", value: state.surprise, color: .purple)
                EmotionBar(label: "🤝 信頼", value: state.trust, color: .green)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("📈 成長レベル: \(state.growthLevel)")
                ProgressView(value: Double(state.growthLevel), total: 10.0)
                    .accentColor(.orange)
            }

            VStack(spacing: 8) {
                Text("🗣 現在のトーンヒント")
                    .font(.headline)
                Text(toneHintDescription(toneHint))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            state = CompanionEmotionManager.shared.state
            toneHint = CompanionEmotionManager.shared.currentToneHint
        }
    }

    func toneHintDescription(_ hint: String) -> String {
        switch hint {
        case "bright": return "明るく元気な雰囲気です。"
        case "soothe": return "落ち着いた優しいトーンです。"
        case "calm_down": return "少し怒り気味かも。落ち着かせてあげましょう。"
        case "curious": return "好奇心旺盛な状態です。"
        case "neutral_caring": return "穏やかで思いやりのある状態です。"
        default: return "中立的な状態です。"
        }
    }

    struct EmotionBar: View {
        let label: String
        let value: Double
        let color: Color

        var body: some View {
            VStack(alignment: .leading) {
                Text(label)
                ProgressView(value: value, total: 5.0)
                    .accentColor(color)
            }
        }
    }
}
