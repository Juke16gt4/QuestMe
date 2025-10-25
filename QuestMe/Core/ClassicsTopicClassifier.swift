//
//  ClassicsTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/ClassicsTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      古典分野のトピック分類。
//      - 和歌/漢詩/ギリシャ悲劇/古代哲学をキーワードで分類。
//      - MLモデルがあれば補強。
//
//  🔗 依存:
//      - Foundation
//      - ClassicsModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

final class ClassicsTopicClassifier: ObservableObject {
    func classify(_ text: String) -> ClassicsTopic {
        let l = text.lowercased()
        if l.contains("和歌") || l.contains("百人一首") || l.contains("万葉集") { return .waka }
        if l.contains("漢詩") || l.contains("杜甫") || l.contains("李白") { return .kanshi }
        if l.contains("ギリシャ悲劇") || l.contains("ソフォクレス") || l.contains("エウリピデス") { return .greekDrama }
        if l.contains("古代哲学") || l.contains("プラトン") || l.contains("アリストテレス") { return .ancientPhilosophy }
        return .other
    }
}
