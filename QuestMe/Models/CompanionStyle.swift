//
//  CompanionStyle.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/Companion/CompanionStyle.swift
//
//  🎯 目的:
//      CompanionAvatar に対応するスタイル定義。
//      - EmotionType と連動し、UI・音声・表情を統一
//
//  🔗 依存:
//      - EmotionType.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月23日

import Foundation

public enum CompanionStyle: String, CaseIterable, Codable {
    case gentle
    case encouraging
    case proud
    case philosophical
    case poetic
    case robotic
    case elderly
    case childish
    case romantic
    case playful
    case shy
    case confused

    public var defaultEmotion: EmotionType {
        switch self {
        case .gentle:        return .gentle
        case .encouraging:   return .encouraging
        case .proud:         return .proud
        case .philosophical: return .philosophical
        case .poetic:        return .poetic
        case .robotic:       return .robotic
        case .elderly:       return .elderly
        case .childish:      return .childish
        case .romantic:      return .romantic
        case .playful:       return .playful
        case .shy:           return .shy
        case .confused:      return .confused
        }
    }
}
