//
//  ConversationEntry.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Model/ConversationEntry.swift
//
//  🎯 ファイルの目的:
//      会話ログの標準モデル定義を一本化する。
//      - すべてのサービス／UIがこの定義を参照し、重複定義を排除する。
//      - emotion は String に統一。
//      - isCommand により操作ログと対話ログを分類可能にする。
//      - language により保存時の言語を明示化する。
//

import Foundation

struct ConversationEntry: Identifiable, Codable {
    let id: UUID
    let speaker: String
    let text: String
    let emotion: String
    let topic: ConversationSubject
    let isCommand: Bool
    let language: String

    init(
        id: UUID = UUID(),
        speaker: String,
        text: String,
        emotion: String,
        topic: ConversationSubject,
        isCommand: Bool = false,
        language: String = Locale.current.language.languageCode?.identifier ?? "ja"
    ) {
        self.id = id
        self.speaker = speaker
        self.text = text
        self.emotion = emotion
        self.topic = topic
        self.isCommand = isCommand
        self.language = language
    }
}

struct ConversationSubject: Codable {
    let label: String
}
