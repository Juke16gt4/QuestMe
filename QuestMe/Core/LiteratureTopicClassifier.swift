//
//  LiteratureTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/LiteratureTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      現代文学関連の入力テキストを分類する。
//      - 小説、詩、批評、文学賞、その他に分類。
//      - 将来的にMLモデルに置換可能なルールベース分類器。
//      - DomainKnowledgeEngine / LiteratureView から利用される。
//
//  🔗 依存:
//      - Foundation
//      - Combine   ← ★ 追加
//      - LiteratureModels.swift
//
//  👤 作成者: 津村 淳一
//  📅 改変日: 2025年10月15日
//

import Foundation
import Combine   // ← ★ 追加

final class LiteratureTopicClassifier: ObservableObject {
    // 分類結果を監視可能にするため @Published を追加
    @Published var lastTopic: LiteratureTopic = .other

    /// 入力テキストを解析し、対応する LiteratureTopic を返す
    func classify(_ text: String) -> LiteratureTopic {
        let lower = text.lowercased()

        let topic: LiteratureTopic
        if lower.contains("小説") || lower.contains("novel") || lower.contains("作家") {
            topic = .novel
        } else if lower.contains("詩") || lower.contains("poem") || lower.contains("poetry") {
            topic = .poetry
        } else if lower.contains("批評") || lower.contains("評論") || lower.contains("criticism") {
            topic = .criticism
        } else if lower.contains("賞") || lower.contains("文学賞") || lower.contains("award") {
            topic = .award
        } else {
            topic = .other
        }

        // @Published プロパティを更新
        lastTopic = topic
        return topic
    }
}
