//
//  AvatarStyle.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Avatar/AvatarStyle.swift
//
//  🎯 ファイルの目的:
//      アバター生成時のスタイル選択肢を定義（Pickerで使用）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import Foundation

public enum AvatarStyle: String, Codable, CaseIterable {
    case photoRealistic = "写実"
    case illustration   = "イラスト"
    case anime          = "アニメ"
    case sketch         = "スケッチ"
}
