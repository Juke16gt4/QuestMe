//
//  AvatarOrientation.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Avatar/AvatarOrientation.swift
//
//  🎯 ファイルの目的:
//      アバターの向き（正面・横）を定義。生成時に必須指定。
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import Foundation

public enum AvatarOrientation: String, Codable {
    case frontFacing = "正面"
    case sideFacing  = "横向き"
    case unknown     = "不明"
}

