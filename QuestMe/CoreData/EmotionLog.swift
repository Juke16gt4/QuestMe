//
//  EmotionLog.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/CoreData/EmotionLog.swift
//
//  🎯 ファイルの目的:
//      感情ログの Core Data モデルを定義し、DTO との相互変換を提供する。
//      - Core Data: NSManagedObject として永続化。
//      - DTO: CoreDataEmotionLogDTO との相互変換を担う。
//      - ConversationSubject を利用してトピックを保持。
//
//  🔗 依存:
//      - CoreData
//      - Foundation
//      - Core/Model/ConversationSubject.swift
//      - CoreData/CoreDataEmotionLogDTO.swift
//
//  🔗 関連/連動ファイル:
//      - Core/Repository/EmotionLogRepository.swift
//      - Managers/EmotionLogStorageManager.swift
//      - Views/Logs/ConversationCalendarView.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月24日
//

import Foundation
import CoreData

// MARK: - Core Data モデル
@objc(EmotionLog)
final class EmotionLog: NSManagedObject {
    @NSManaged var uuid: String
    @NSManaged var timestamp: Date
    @NSManaged var text: String
    @NSManaged var emotion: String
    @NSManaged var ritual: String?
    @NSManaged var metadata: String?
}

// MARK: - 相互変換
extension EmotionLog {
    func toDTO() -> CoreDataEmotionLogDTO {
        CoreDataEmotionLogDTO(
            id: UUID(uuidString: self.uuid) ?? UUID(),
            timestamp: self.timestamp,
            text: self.text,
            emotion: self.emotion,
            ritual: self.ritual,
            metadata: self.metadata,
            topic: .general
        )
    }
}

extension CoreDataEmotionLogDTO {
    func toManagedObject(context: NSManagedObjectContext) -> EmotionLog {
        let obj = EmotionLog(context: context)
        obj.uuid = self.id.uuidString
        obj.timestamp = self.timestamp
        obj.text = self.text
        obj.emotion = self.emotion
        obj.ritual = self.ritual
        obj.metadata = self.metadata
        return obj
    }
}
