//
//  Item.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Models/Item.swift
//
//  🎯 ファイルの目的:
//      SwiftData による汎用的な記録モデル。
//      - timestamp のみを保持する軽量構造。
//      - 今後の記録分類やタグ付けのベースとして拡張可能。
//      - SwiftData の @Model 属性により自動永続化対象となる。
//
//  🔗 依存:
//      - SwiftData（@Model）
//      - Foundation（Date）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年9月27日/

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
