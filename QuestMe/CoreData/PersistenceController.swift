//
//  PersistenceController.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/CoreData/PersistenceController.swift
//
//  🎯 目的:
//      Core Data スタック（NSPersistentContainer）を構築し、
//      .xcdatamodeld に依存せずコードで EmotionLog エンティティを定義。
//      アプリ削除時のみ消える、削除不可の“心臓部”ストレージを提供。
//
//  🔗 依存:
//      - Foundation
//      - CoreData
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月15日
//

import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    private init() {
        // 1) モデルをコードで構築
        let model = Self.makeModel()
        // 2) コンテナ作成
        container = NSPersistentContainer(name: "QuestMeEmotionStore", managedObjectModel: model)

        // 3) ストア記述（アプリサンドボックス内、ユーザーが直接削除しづらい）
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = NSSQLiteStoreType
        storeDescription.configuration = nil
        storeDescription.url = Self.defaultStoreURL()
        storeDescription.shouldAddStoreAsynchronously = false
        storeDescription.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
        storeDescription.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)

        container.persistentStoreDescriptions = [storeDescription]

        // 4) ロード
        container.loadPersistentStores { _, error in
            if let error = error {
                assertionFailure("Core Data store failed to load: \(error)")
            }
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.container.viewContext.undoManager = nil
        }
    }

    // 端末内の保存先（アプリ専用領域）
    private static func defaultStoreURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("QuestMe", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("EmotionLogs.sqlite")
    }

    // EmotionLog モデル定義（コード生成）
    private static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        // Attributes
        let timestamp = NSAttributeDescription()
        timestamp.name = "timestamp"
        timestamp.attributeType = .dateAttributeType
        timestamp.isOptional = false

        let text = NSAttributeDescription()
        text.name = "text"
        text.attributeType = .stringAttributeType
        text.isOptional = false

        let emotion = NSAttributeDescription()
        emotion.name = "emotion"
        emotion.attributeType = .stringAttributeType
        emotion.isOptional = false

        let metadata = NSAttributeDescription()
        metadata.name = "metadata"
        metadata.attributeType = .stringAttributeType
        metadata.isOptional = true

        let ritual = NSAttributeDescription()
        ritual.name = "ritual"
        ritual.attributeType = .stringAttributeType
        ritual.isOptional = true

        let uuid = NSAttributeDescription()
        uuid.name = "uuid"
        uuid.attributeType = .stringAttributeType
        uuid.isOptional = false

        // Entity
        let entity = NSEntityDescription()
        entity.name = "EmotionLog"
        entity.managedObjectClassName = NSStringFromClass(EmotionLog.self)
        entity.properties = [uuid, timestamp, text, emotion, metadata, ritual]

        // Model
        model.entities = [entity]
        return model
    }
}
