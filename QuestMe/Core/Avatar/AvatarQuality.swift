//
//  AvatarQuality.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Avatar/AvatarQuality.swift
//
//  🎯 ファイルの目的:
//      アバター生成時の画質レベルを定義（高解像度が初期値）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月21日

import Foundation

public enum AvatarQuality: String, Codable {
    case standard       = "標準"
    case highResolution = "高解像度"
}
