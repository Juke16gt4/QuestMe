//
//  EntityOperator.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/EntityOperator.swift
//
//  🎯 ファイルの目的:
//      VoiceIntent に基づき、実際のモデル更新を行う処理を担う。
//      - apply(intent:userId:) により更新を実行。
//      - 結果を EntityOperationResult として返却。
//      - 現状はスタブ実装であり、将来的に UserProfileStorage や MedicationManager と連携予定。
//
//  🔗 依存:
//      - VoiceIntent.swift（意図定義）
//      - ChangeLogManager.swift（履歴保存）
//      - LogEntry.swift（会話記録）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月7日
//

import Foundation

struct EntityOperationResult {
    let entityId: String
    let oldValue: String?
    let newValue: String?
    let reason: String
}

final class EntityOperator {
    static let shared = EntityOperator()
    private init() {}

    func apply(intent: VoiceIntent, userId: Int) -> EntityOperationResult {
        // TODO: 実際のモデル更新処理を実装
        // 現状はスタブとして UUID を返す
        return EntityOperationResult(
            entityId: UUID().uuidString,
            oldValue: nil,
            newValue: intent.value,
            reason: "voice"
        )
    }
}
