//
//  UnifiedTopicClassifier.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/UnifiedTopicClassifier.swift
//
//  🎯 ファイルの目的:
//      全分野のトピック分類（資格取得含む）。
//      - ユーザー入力から ConversationSubject を返す。
//      - 資格関連は CertificationTopicClassifier に委譲。
//      - fallback は .other。
//
//  🔗 依存:
//      - Foundation
//      - Combine
//      - CertificationTopicClassifier.swift
//      - ConversationEntry.swift（ConversationSubject 定義）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月17日
//

import Foundation
import Combine

final class UnifiedTopicClassifier: ObservableObject {
    private let certifier = CertificationTopicClassifier()

    /// ユーザー入力を ConversationSubject に分類
    func classify(_ text: String) -> ConversationSubject {
        let l = text.lowercased()

        // 資格関連キーワード → CertificationTopicClassifier に委譲
        let certTopic: ConversationSubject = certifier.classify(text)
        if certTopic != .other {
            return certTopic
        }

        // 通常分類（例）
        if l.contains("健康") || l.contains("病気") {
            return .health
        }
        if l.contains("仕事") || l.contains("転職") {
            return .work
        }
        if l.contains("家族") || l.contains("育児") {
            return .family
        }
        if l.contains("不安") || l.contains("将来") {
            return .anxiety
        }
        if l.contains("映画") || l.contains("音楽") {
            return .entertainment
        }

        // fallback
        return .other
    }

    /// ユーザー入力を履歴に登録（将来的に拡張可能）
    func registerUserEntry(_ entry: ConversationEntry) {
        // 資格関連の詳細分類を保存する場合はここで拡張
    }
}
