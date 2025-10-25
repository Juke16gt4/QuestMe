//
//  AvatarPrompt.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Avatar/AvatarPrompt.swift
//
//  🎯 ファイルの目的:
//      ユーザーが記述する希望（prompt）を構造化して保持
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import Foundation

public struct AvatarPrompt: Codable, Equatable {
    public var description: String
    public var style: AvatarStyle
    public var realism: Bool
}
