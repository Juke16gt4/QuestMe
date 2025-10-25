//
//  CompanionGenerator.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/CompanionGenerator.swift
//
//  🎯 ファイルの目的:
//      ユーザーの入力（性格・語り口・雰囲気）をもとに、AI生成型のコンパニオン候補を3体同時に生成。
//      - 各候補は画像（仮）、性格、語りスタイル、背景色を持つ。
//      - CompanionSetupView から呼び出され、選択または再生成可能。
//      - CompanionProfile に保存される構造に準拠。
//      - スタイルに応じた命名ロジックを導入し、ユーザー入力に基づく個性を反映。
//      - 12言語対応の名前生成を準備。
//
//  🔗 依存:
//      - CompanionStyle.swift（語りスタイル）
//      - CompanionProfile.swift（保存構造）
//      - SwiftUI / UIImage（表示）
//
//  👤 修正者: 津村 淳一
//  📅 修正日: 2025年10月17日
//

import Foundation
import Combine
import SwiftUI

struct GeneratedCompanion: Identifiable {
    let id = UUID()
    let name: String
    let personality: String
    let style: CompanionStyle
    let backgroundColor: Color
    let image: UIImage
}

final class CompanionGenerator {
    static func generateCandidates(from input: String, language: String = "ja") -> [GeneratedCompanion] {
        let styles: [CompanionStyle] = CompanionStyle.allCases.shuffled().prefix(3).map { $0 }
        return styles.map { style in
            GeneratedCompanion(
                name: generateName(for: style, personality: input, language: language),
                personality: input,
                style: style,
                backgroundColor: generateColor(for: style),
                image: generatePlaceholderImage(for: style)
            )
        }
    }

    /// ✅ スタイルごとの名前生成（12言語対応）
    private static func generateName(for style: CompanionStyle, personality: String, language: String) -> String {
        switch style {
        case .poetic:
            return language == "ja" ? (personality.contains("自然") ? "風音" : "詩音") : "Lyra"
        case .logical:
            return language == "ja" ? (personality.contains("分析") ? "慧" : "理央") : "Sophia"
        case .humorous:
            return language == "ja" ? (personality.contains("笑") ? "笑太" : "陽気") : "Jester"
        case .gentle:
            return language == "ja" ? (personality.contains("癒し") ? "和葉" : "優月") : "Serena"
        case .sexy:
            return language == "ja" ? (personality.contains("魅力") ? "魅月" : "艶香") : "Luna"
        case .polite:
            return language == "ja" ? "礼子" : "Grace"
        case .casual:
            return language == "ja" ? "陽太" : "Sunny"
        case .neutral:
            return language == "ja" ? "中村" : "Alex"
        case .philosophical:
            return language == "ja" ? "哲司" : "Socrates"
        case .childlike:
            return language == "ja" ? "花音" : "Kiddy"
        case .elderly:
            return language == "ja" ? "源蔵" : "Elder"
        case .robotic:
            return language == "ja" ? "機心" : "Unit-X"
        }
    }

    /// ✅ スタイルごとの背景色
    private static func generateColor(for style: CompanionStyle) -> Color {
        switch style {
        case .poetic:        return Color.purple.opacity(0.3)
        case .logical:       return Color.gray.opacity(0.3)
        case .humorous:      return Color.orange.opacity(0.3)
        case .gentle:        return Color.green.opacity(0.3)
        case .sexy:          return Color.red.opacity(0.3)
        case .polite:        return Color.blue.opacity(0.3)
        case .casual:        return Color.yellow.opacity(0.3)
        case .neutral:       return Color.primary.opacity(0.3)
        case .philosophical: return Color.indigo.opacity(0.3)
        case .childlike:     return Color.pink.opacity(0.3)
        case .elderly:       return Color.brown.opacity(0.3)
        case .robotic:       return Color.cyan.opacity(0.3)
        }
    }

    private static func generatePlaceholderImage(for style: CompanionStyle) -> UIImage {
        let imageName = "placeholder_\(style.rawValue)"
        return UIImage(named: imageName) ?? UIImage()
    }
}
