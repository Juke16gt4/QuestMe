//
//  EmotionType.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/Emotion/EmotionType.swift
//
//  🎯 ファイルの目的:
//      - アプリ全体で利用する感情タイプを定義する（UI・ログ保存共通）。
//      - UI 表示用の色・ラベル・アイコンを提供する。
//      - CompanionAvatarView / CompanionSpeechBubbleView / FloatingCompanionOverlayView と連動。
//      - CompanionStyle に対応する拡張感情も含む（poetic, philosophical など）。
//
//  🔗 依存:
//      - Foundation
//      - SwiftUI
//
//  👤 作成者: 津村 淳一
//  📅 改変日: 2025年10月16日
//

import Foundation
import SwiftUI

/// アプリ全体で利用する感情タイプ
enum EmotionType: String, CaseIterable, Codable {
    case neutral
    case happy
    case sad
    case angry
    case thinking
    case sexy
    case encouraging
    case gentle
    case surprised
    case lonely
    case focused
    case nostalgic
    case sleepy

    // 拡張感情タイプ（CompanionStyle 対応）
    case poetic
    case philosophical
    case childish
    case elderly
    case robotic
    case romantic
    case playful
    case shy
    case proud
    case confused
}

// MARK: - UI 表示用拡張
extension EmotionType {
    /// 表示ラベル（日本語）
    var label: String {
        switch self {
        case .neutral:       return "ふつう"
        case .happy:         return "うれしい"
        case .sad:           return "かなしい"
        case .angry:         return "おこってる"
        case .thinking:      return "かんがえ中"
        case .sexy:          return "セクシー"
        case .encouraging:   return "おうえん"
        case .gentle:        return "やさしい"
        case .surprised:     return "びっくり"
        case .lonely:        return "さびしい"
        case .focused:       return "しゅうちゅう"
        case .nostalgic:     return "なつかしい"
        case .sleepy:        return "ねむい"
        case .poetic:        return "しとやか"
        case .philosophical: return "しさつてき"
        case .childish:      return "むじゃき"
        case .elderly:       return "おだやか"
        case .robotic:       return "むきしつ"
        case .romantic:      return "ときめき"
        case .playful:       return "あそびごころ"
        case .shy:           return "てれくさい"
        case .proud:         return "じしんまんまん"
        case .confused:      return "とまどい"
        }
    }

    /// 表示色（枠線・背景・アイコン）
    var color: Color {
        switch self {
        case .neutral:       return .gray
        case .happy:         return .yellow
        case .sad:           return .blue
        case .angry:         return .red
        case .thinking:      return .purple
        case .sexy:          return .pink
        case .encouraging:   return .green
        case .gentle:        return .mint
        case .surprised:     return .orange
        case .lonely:        return .indigo
        case .focused:       return .cyan
        case .nostalgic:     return .brown
        case .sleepy:        return .teal
        case .poetic:        return .purple.opacity(0.7)
        case .philosophical: return .gray.opacity(0.6)
        case .childish:      return .yellow.opacity(0.8)
        case .elderly:       return .gray.opacity(0.4)
        case .robotic:       return .blue.opacity(0.5)
        case .romantic:      return .pink.opacity(0.7)
        case .playful:       return .orange.opacity(0.7)
        case .shy:           return .purple.opacity(0.5)
        case .proud:         return .red.opacity(0.6)
        case .confused:      return .gray.opacity(0.3)
        }
    }

    /// 表示アイコン（SF Symbols）
    var icon: String {
        switch self {
        case .neutral:       return "circle"
        case .happy:         return "sun.max.fill"
        case .sad:           return "cloud.rain.fill"
        case .angry:         return "flame.fill"
        case .thinking:      return "brain.head.profile"
        case .sexy:          return "heart.fill"
        case .encouraging:   return "hands.sparkles.fill"
        case .gentle:        return "leaf.fill"
        case .surprised:     return "exclamationmark.triangle.fill"
        case .lonely:        return "person.fill.questionmark"
        case .focused:       return "scope"
        case .nostalgic:     return "clock.arrow.circlepath"
        case .sleepy:        return "moon.zzz.fill"
        case .poetic:        return "sparkles"
        case .philosophical: return "books.vertical.fill"
        case .childish:      return "face.smiling"
        case .elderly:       return "person.crop.circle.badge.clock"
        case .robotic:       return "cpu.fill"
        case .romantic:      return "heart.circle.fill"
        case .playful:       return "gamecontroller.fill"
        case .shy:           return "eye.slash.fill"
        case .proud:         return "star.fill"
        case .confused:      return "questionmark.circle.fill"
        }
    }
    var defaultPhrase: String {
            switch self {
            case .happy: return "嬉しい気持ちです！"
            case .sad: return "少し落ち込んでいます…"
            case .angry: return "ちょっと怒ってるかも。"
            case .thinking: return "考え中です。"
            case .surprised: return "びっくりしました！"
            case .gentle: return "穏やかな気持ちです。"
            case .encouraging: return "あなたを応援しています！"
            case .neutral: return "落ち着いています。"
            case .sexy: return "魅力的な気分です。"
            default: return "今の気持ちを整理しています。"
            }
        }
    }
