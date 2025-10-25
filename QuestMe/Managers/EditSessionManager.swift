//
//  EditSessionManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/EditSessionManager.swift
//
//  🎯 ファイルの目的:
//      - 感情ログの編集セッションを一時的に保持・操作する。
//      - 編集中の EmotionLog を生成・更新・破棄する。
//      - EmotionReviewView などから呼び出される。
//      - Core Data の EmotionLog(NSManagedObject) を扱うため、
//        emotion は String(rawValue) で保存し、note は text に格納する。
//
//  🔗 依存:
//      - CoreData
//      - EmotionLog.swift（Core Data モデル + DTO）
//      - EmotionLogStorageManager.swift（保存・更新）
//
//  🔗 関連/連動ファイル:
//      - EmotionReviewView.swift（UIから編集開始/保存/破棄を呼び出し）
//      - ReflectionService.swift（感情ログと連動する場合）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月17日
//

import Foundation
import CoreData

final class EditSessionManager {
    static let shared = EditSessionManager()

    private var currentLog: EmotionLog?

    /// 編集セッションを開始（新規）
    func beginNewSession(withNote note: String?, context: NSManagedObjectContext) {
        let newLog = EmotionLog(context: context)
        newLog.uuid = UUID().uuidString
        newLog.timestamp = Date()
        newLog.text = note ?? ""   // note は text に保存
        newLog.emotion = EmotionType.neutral.rawValue
        newLog.ritual = nil
        newLog.metadata = nil
        currentLog = newLog
    }

    /// 編集セッションを開始（既存ログ）
    func beginEditSession(from existing: EmotionLog) {
        currentLog = existing
    }

    /// 編集中のログにメモを追加
    func updateNote(_ note: String?) {
        guard let log = currentLog else { return }
        log.text = note ?? ""
    }

    /// 編集中のログに感情タイプを設定
    func updateEmotion(_ emotion: EmotionType) {
        guard let log = currentLog else { return }
        log.emotion = emotion.rawValue
    }

    /// 編集セッションを保存
        func commit() {
            guard let log = currentLog else { return }
            // Core Data モデル → DTO に変換して保存
            let dto = log.toDTO()
            EmotionLogStorageManager.shared.save(dto)
            currentLog = nil
        }

    /// 編集セッションを破棄
    func cancel() {
        currentLog = nil
    }

    /// 現在の編集ログを取得
    func current() -> EmotionLog? {
        return currentLog
    }
}
