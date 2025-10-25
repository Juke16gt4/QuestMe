//
//  ArtsMusicTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/ArtsMusicTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      芸術・音楽分野のトピック分類。
//      - 美術史/音楽理論/作品解説をキーワードで分類。
//      - MLモデルがあれば補強。
//
//  🔗 依存:
//      - Foundation
//      - ArtsMusicModels.swift
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月12日
//

import Foundation
import Combine

final class ArtsMusicTopicClassifier: ObservableObject {
    func classify(_ text: String) -> ArtsMusicTopic {
        let l = text.lowercased()
        if l.contains("美術史") || l.contains("印象派") || l.contains("ルネサンス") { return .artHistory }
        if l.contains("音楽理論") || l.contains("和声") || l.contains("コード進行") { return .musicTheory }
        if l.contains("作品解説") || l.contains("鑑賞") || l.contains("構成") { return .workAnalysis }
        return .other
    }
}
