//
//  Subject.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Domain/Subject.swift
//
//  🎯 ファイルの目的:
//      LiteratureView や DomainKnowledgeEngine にて使用される「話題・主題」を表現する構造体。
//      - ユーザー入力から生成され、ニュース取得や分類に使用。
//      - label のみを持つ軽量構造体。
//      - Hashable / Identifiable に準拠し、ForEach や辞書キーとして利用可能。
//
//  🔗 依存/連動:
//      - LiteratureView.swift（Subject(label:)）
//      - DomainKnowledgeEngine.swift（currentSubject）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月15日
//

import Foundation

public struct Subject: Identifiable, Codable, Hashable {
    public var id = UUID()
    public var label: String

    public init(label: String) {
        self.label = label
    }
}
