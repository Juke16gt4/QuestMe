//
//  CompanionAdviceView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/Companion/Advice/CompanionAdviceView.swift
//
//  🎯 ファイルの責任:
//      - Companion がアドバイスを語るビュー
//      - 感情タイプと語りタイミングを制御
//      - CompanionOverlay と連携して吹き出し表示
//      - LocalizationManager を利用して多言語対応
//
//  🔗 依存:
//      - EmotionType.swift
//      - CompanionOverlay.swift
//      - LocalizationManager.swift
//
//  👤 製作者: 津村 淳一
//  📅 修正版: 2025年10月24日
//

import SwiftUI

struct CompanionAdviceView: View {
    let message: String
    let emotion: EmotionType

    @EnvironmentObject var locale: LocalizationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(message)
                .font(.body)
                .padding()
                .background(emotion.backgroundColor)
                .cornerRadius(12)
                .foregroundColor(.primary)

            // 吹き出しや音声案内は CompanionOverlay と連携して制御
        }
        .padding()
    }
}

// MARK: - EmotionType に応じた背景色
extension EmotionType {
    var backgroundColor: Color {
        switch self {
        case .happy:         return Color.yellow.opacity(0.3)
        case .sad:           return Color.blue.opacity(0.2)
        case .angry:         return Color.red.opacity(0.2)
        case .neutral:       return Color.gray.opacity(0.2)
        case .thinking:      return Color.purple.opacity(0.2)
        case .sexy:          return Color.pink.opacity(0.2)
        case .encouraging:   return Color.green.opacity(0.2)
        case .gentle:        return Color.mint.opacity(0.2)
        case .surprised:     return Color.orange.opacity(0.2)
        case .lonely:        return Color.indigo.opacity(0.2)
        case .focused:       return Color.cyan.opacity(0.2)
        case .nostalgic:     return Color.brown.opacity(0.2)
        case .sleepy:        return Color.teal.opacity(0.2)
        case .poetic:        return Color.purple.opacity(0.3)
        case .philosophical: return Color.gray.opacity(0.3)
        case .childish:      return Color.yellow.opacity(0.3)
        case .elderly:       return Color.gray.opacity(0.2)
        case .robotic:       return Color.blue.opacity(0.2)
        case .romantic:      return Color.pink.opacity(0.3)
        case .playful:       return Color.orange.opacity(0.3)
        case .shy:           return Color.purple.opacity(0.2)
        case .proud:         return Color.red.opacity(0.3)
        case .confused:      return Color.gray.opacity(0.2)
        }
    }
}
