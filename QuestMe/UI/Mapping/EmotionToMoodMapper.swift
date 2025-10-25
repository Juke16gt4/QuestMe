//
//  EmotionToMoodMapper.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/UI/Mapping/EmotionToMoodMapper.swift
//
//  🎯 ファイルの目的:
//      - EmotionType を UI層の簡易ムード (Mood) に変換する純粋関数群を提供する。
//      - 既存UI差異（mood を必要とする箇所と emotion を直接渡す箇所）の橋渡しを行う。
//      - すべての EmotionType ケースを網羅して、将来の拡張でも落ちない安全な既定値を用意する。
//
//  🔗 関連/連動ファイル:
//      - Models/Emotion/EmotionType.swift（感情定義・色/ラベル/アイコン拡張）
//      - Views/Companion/CompanionSpeechBubbleView.swift（吹き出しUI。現状 EmotionType を受け取る実装と一部で mood の参照あり）
//      - Views/Emotion/EmotionReviewView.swift（overlay.currentMood を利用するUI）
//      - Managers/CompanionEmotionManager.swift（UIトーンヒント生成）
//      - Models/CompanionStyle.swift（スタイル→EmotionType 変換）
//
//  👤 作成者: Tsumura Junichi
//  📅 作成日時: 2025/10/22 JST
//

import Foundation
import SwiftUI

/// UI層での簡易ムード。吹き出し色・トーン・強調度などの視覚表現に使用する。
public enum Mood: String, CaseIterable, Codable {
    case neutral     // 落ち着き・標準
    case happy       // 明るさ・祝福
    case gentle      // 優しさ・安心
    case sad         // 静けさ・沈静
    case angry       // 注意・警告
    case surprised   // 強調・注意喚起
    case thinking    // 熟考・探索
    case romantic    // 温かさ・親密
    case playful     // 軽快・遊び心
    case poetic      // しとやか・余韻
    case philosophical// 思索・静観
    case childish    // 無邪気・子供心
    case elderly     // 穏やか・年輪
    case robotic     // 無機・冷静
    case proud       // 自信・凛然
    case shy         // 控えめ・繊細
    case confused    // 逡巡・曖昧
    case nostalgic   // 郷愁・温もり
    case focused     // 集中・緊張
    case sleepy      // 休息・緩和
    case sexy        // センシュアル（表現上は romantic に近似）
}

/// EmotionType → Mood の正規変換（全ケース網羅）
public func emotionToMood(_ emotion: EmotionType) -> Mood {
    switch emotion {
    case .neutral:       return .neutral
    case .happy:         return .happy
    case .sad:           return .sad
    case .angry:         return .angry
    case .thinking:      return .thinking
    case .sexy:          return .sexy       // 表層ムードはセクシー扱い（色表現は romantic に近似させることも可）
    case .encouraging:   return .happy      // 前向き・励ましは happy に寄せる
    case .gentle:        return .gentle
    case .surprised:     return .surprised
    case .lonely:        return .sad        // 寂しさは悲しみ系のトーンへ
    case .focused:       return .focused
    case .nostalgic:     return .nostalgic
    case .sleepy:        return .sleepy

    case .poetic:        return .poetic
    case .philosophical: return .philosophical
    case .childish:      return .childish
    case .elderly:       return .elderly
    case .robotic:       return .robotic
    case .romantic:      return .romantic
    case .playful:       return .playful
    case .shy:           return .shy
    case .proud:         return .proud
    case .confused:      return .confused
    }
}

/// Mood → 表示色（吹き出し背景などの推奨カラー）
public func moodColor(_ mood: Mood) -> Color {
    switch mood {
    case .neutral:       return .gray.opacity(0.5)
    case .happy:         return .yellow
    case .gentle:        return .mint
    case .sad:           return .blue.opacity(0.6)
    case .angry:         return .red.opacity(0.7)
    case .surprised:     return .orange
    case .thinking:      return .purple.opacity(0.6)
    case .romantic:      return .pink.opacity(0.7)
    case .playful:       return .orange.opacity(0.7)
    case .poetic:        return .purple.opacity(0.7)
    case .philosophical: return .gray.opacity(0.6)
    case .childish:      return .yellow.opacity(0.8)
    case .elderly:       return .gray.opacity(0.4)
    case .robotic:       return .blue.opacity(0.5)
    case .proud:         return .red.opacity(0.6)
    case .shy:           return .purple.opacity(0.5)
    case .confused:      return .gray.opacity(0.3)
    case .nostalgic:     return .brown
    case .focused:       return .cyan
    case .sleepy:        return .teal
    case .sexy:          return .pink.opacity(0.7)
    }
}

/// EmotionType を直接受ける UI のためのブリッジ（Color取得）
public func emotionToBubbleColor(_ emotion: EmotionType) -> Color {
    moodColor(emotionToMood(emotion))
}

/// Mood → 推奨 SF Symbols（必要なら利用）
public func moodIconName(_ mood: Mood) -> String {
    switch mood {
    case .neutral:       return "circle"
    case .happy:         return "sun.max.fill"
    case .gentle:        return "leaf.fill"
    case .sad:           return "cloud.rain.fill"
    case .angry:         return "flame.fill"
    case .surprised:     return "exclamationmark.triangle.fill"
    case .thinking:      return "brain.head.profile"
    case .romantic, .sexy: return "heart.circle.fill"
    case .playful:       return "gamecontroller.fill"
    case .poetic:        return "sparkles"
    case .philosophical: return "books.vertical.fill"
    case .childish:      return "face.smiling"
    case .elderly:       return "person.crop.circle.badge.clock"
    case .robotic:       return "cpu.fill"
    case .proud:         return "star.fill"
    case .shy:           return "eye.slash.fill"
    case .confused:      return "questionmark.circle.fill"
    case .nostalgic:     return "clock.arrow.circlepath"
    case .focused:       return "scope"
    case .sleepy:        return "moon.zzz.fill"
    }
}

/// 既存の CompanionSpeechBubbleView が mood を受ける形に移行したい場合のヘルパー適用（オプション）
/// - この拡張は UI 実装に合わせて利用。既存が EmotionType を受け取るなら未使用でも問題なし。
public extension CompanionSpeechBubbleView {
    /// 推奨背景色（Moodに基づく）
    static func backgroundColor(for mood: Mood) -> Color {
        moodColor(mood)
    }
}
