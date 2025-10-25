//
//  VoiceprintAuthManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/VoiceprintAuthManager.swift
//
//  🎯 ファイルの目的:
//      通訳モードにおける声紋認証の一時解除と再ロック制御。
//      - モードに応じて一時解除（temporarilyDisable）または維持（ensureEnabled）
//      - 終了時に再ロック（restoreIfNeeded）
//      - CompanionOverlay による音声通知と吹き出し表示に対応
//
//  🔗 依存:
//      - CompanionOverlay.swift（音声・吹き出し）
//
//  👤 製作者: 津村 淳一
//  📅 修正日: 2025年10月14日
//

import Foundation

final class VoiceprintAuthManager {
    static let shared = VoiceprintAuthManager()
    private init() {}

    private var isTemporarilyDisabled: Bool = false

    /// 声紋認証を一時的に解除する（通訳モード中）
    func temporarilyDisable(reason: String) {
        guard !isTemporarilyDisabled else { return }
        isTemporarilyDisabled = true
        CompanionOverlay.shared.speak("声紋認証を一時解除します。理由：\(reason)")
        CompanionOverlay.shared.showBubble("声紋認証を一時解除：\(reason)")
    }

    /// 声紋認証を維持する（解除されていれば再ロック）
    func ensureEnabled() {
        if isTemporarilyDisabled {
            restoreIfNeeded()
        }
    }

    /// 通訳モード終了時に声紋認証を再ロックする
    func restoreIfNeeded() {
        guard isTemporarilyDisabled else { return }
        isTemporarilyDisabled = false
        CompanionOverlay.shared.speak("声紋認証を再ロックしました。")
        CompanionOverlay.shared.showBubble("声紋認証を再ロックしました。")
    }

    /// 現在の状態を外部から参照可能にする（必要に応じて）
    var isDisabled: Bool {
        return isTemporarilyDisabled
    }
}
