//
//  ClassicsModels.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/ClassicsModels.swift
//
//  🎯 ファイルの目的:
//      古典文学・思想関連のトピック分類と参照モデル。
//      - ClassicsTopic: 和歌/漢詩/ギリシャ悲劇/古代哲学/その他。
//      - ClassicsReference: 出典URL付きの参照情報（青空文庫・大学資料など）。
//
//  🔗 依存:
//      - Foundation
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation

enum ClassicsTopic: String, Codable {
    case waka, kanshi, greekDrama, ancientPhilosophy, other
}

struct ClassicsReference: Codable, Hashable {
    let title: String
    let sourceURL: URL?
}
