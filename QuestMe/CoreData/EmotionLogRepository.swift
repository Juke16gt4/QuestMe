//
//  EmotionLogRepository.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Repository/EmotionLogRepository.swift
//
//  🎯 ファイルの目的:
//      感情ログの取得・保存を統合的に扱うリポジトリ。
//      - SQLiteEmotionLogDTO（DB直列化用）と CoreDataEmotionLogDTO（UI/履歴表示用）を吸収。
//      - UI 層には常に CoreDataEmotionLogDTO を返すことで一貫性を確保。
//      - 将来的にストレージ方式を切り替えても UI 側の影響を最小化する。
//
//  🔗 依存:
//      - Core/Model/SQLiteEmotionLogDTO.swift
//      - CoreData/EmotionLog.swift（CoreDataEmotionLogDTO 定義）
//      - Core/Storage/SQLiteStorageService.swift
//      - Managers/EmotionLogStorageManager.swift
//
//  🔗 関連/連動ファイル:
//      - Views/Logs/ConversationCalendarView.swift（UI表示）
//      - CompanionEmotionManager.swift（感情成長の保存トリガ）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月24日
//

import Foundation

final class EmotionLogRepository {
    static let shared = EmotionLogRepository()
    private init() {}

    // MARK: - 全件取得（UI用）
    func allLogs() -> [CoreDataEmotionLogDTO] {
        var unified: [CoreDataEmotionLogDTO] = []

        // 1. SQLite から取得
        let group = DispatchGroup()
        group.enter()
        SQLiteStorageService.shared.fetchEmotionLogs { sqliteLogs in
            let converted = sqliteLogs.map { sqlite in
                CoreDataEmotionLogDTO(
                    id: UUID(), // SQLite の Int64 id を UUID に変換（マッピングルールは要検討）
                    timestamp: ISO8601DateFormatter().date(from: sqlite.createdAt) ?? Date(),
                    text: sqlite.note ?? "",
                    emotion: sqlite.emotionType,
                    ritual: nil,
                    metadata: nil,
                    topic: ConversationSubject(label: "general")
                )
            }
            unified.append(contentsOf: converted)
            group.leave()
        }
        group.wait()

        // 2. UserDefaults（EmotionLogStorageManager）から取得
        let localLogs = EmotionLogStorageManager.shared.loadAll()
        unified.append(contentsOf: localLogs)

        // 3. 並び替え（新しい順）
        unified.sort { $0.timestamp > $1.timestamp }

        return unified
    }

    // MARK: - 保存
    func save(_ log: CoreDataEmotionLogDTO) {
        EmotionLogStorageManager.shared.save(log)
    }

    // MARK: - 更新
    func update(_ log: CoreDataEmotionLogDTO) {
        EmotionLogStorageManager.shared.update(log)
    }

    // MARK: - 削除
    func delete(_ log: CoreDataEmotionLogDTO) {
        EmotionLogStorageManager.shared.delete(log)
    }
}
