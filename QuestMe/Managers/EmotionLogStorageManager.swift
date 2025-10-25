//
//  EmotionLogStorageManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/EmotionLogStorageManager.swift
//
//  🎯 ファイルの目的:
//      CoreDataEmotionLogDTO の保存・読み込み・削除・更新を統一管理。
//      - UserDefaults を利用した簡易永続化。
//      - Core Data の EmotionLog モデルと相互変換可能。
//      - EmotionReviewView / EditSessionManager から利用される。
//      - SQLiteEmotionLogDTO とは分離し、責務を明確化。
//
//  🔗 依存:
//      - Foundation
//      - CoreData/EmotionLog.swift（CoreDataEmotionLogDTO 定義 + モデル）
//
//  🔗 関連/連動ファイル:
//      - EditSessionManager.swift（編集セッションから保存呼び出し）
//      - EmotionReviewView.swift（UIから読み込み/削除呼び出し）
//      - Core/Repository/EmotionLogRepository.swift（ユースケース層での統合）
//
//  👤 作成者: 津村 淳一
//  📅 修正版: 2025年10月24日
//

import Foundation

final class EmotionLogStorageManager {
    static let shared = EmotionLogStorageManager()
    private init() {}

    private let storageKey = "emotion_logs"

    // MARK: - 保存
    func save(_ log: CoreDataEmotionLogDTO) {
        var logs = loadAll()
        logs.append(log)
        persist(logs)
    }

    // MARK: - 全件読み込み
    func loadAll() -> [CoreDataEmotionLogDTO] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return [] }
        if let decoded = try? JSONDecoder().decode([CoreDataEmotionLogDTO].self, from: data) {
            return decoded
        }
        return []
    }

    // MARK: - 削除
    func delete(_ log: CoreDataEmotionLogDTO) {
        var logs = loadAll()
        logs.removeAll { $0.id == log.id }
        persist(logs)
    }

    // MARK: - 更新
    func update(_ log: CoreDataEmotionLogDTO) {
        var logs = loadAll()
        if let index = logs.firstIndex(where: { $0.id == log.id }) {
            logs[index] = log
            persist(logs)
        }
    }

    // MARK: - 内部保存処理
    private func persist(_ logs: [CoreDataEmotionLogDTO]) {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
