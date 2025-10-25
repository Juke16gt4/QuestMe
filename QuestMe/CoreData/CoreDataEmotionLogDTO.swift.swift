//
//  CoreDataEmotionLogDTO.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/CoreData/CoreDataEmotionLogDTO.swift
//
//  🎯 ファイルの目的:
//      Core Data 由来の感情ログを UI/Repository 層で扱うための DTO を定義。
//      - Identifiable, Codable, Hashable に準拠。
//      - ConversationSubject を利用してトピックを保持。
//      - EmotionLog.swift との相互変換に利用される。
//
//  🔗 依存:
//      - Foundation
//      - Core/Model/ConversationSubject.swift
//
//  🔗 関連/連動ファイル:
//      - CoreData/EmotionLog.swift（相互変換）
//      - Core/Repository/EmotionLogRepository.swift
//      - Managers/EmotionLogStorageManager.swift
//      - Views/Logs/ConversationCalendarView.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月24日
//

import Foundation

public struct CoreDataEmotionLogDTO: Identifiable, Codable, Hashable {
    public var id: UUID
    public var timestamp: Date
    public var text: String
    public var emotion: String
    public var ritual: String?
    public var metadata: String?
    public var topic: ConversationSubject

    public init(id: UUID = UUID(),
                timestamp: Date = Date(),
                text: String,
                emotion: String,
                ritual: String? = nil,
                metadata: String? = nil,
                topic: ConversationSubject = .general) {
        self.id = id
        self.timestamp = timestamp
        self.text = text
        self.emotion = emotion
        self.ritual = ritual
        self.metadata = metadata
        self.topic = topic
    }
}
