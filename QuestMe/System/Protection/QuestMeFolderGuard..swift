//
//  QuestMeFolderGuard.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/System/Protection/QuestMeFolderGuard.swift
//
//  🎯 ファイルの目的:
//      QuestMeフォルダーへのアクセスを検知し、警告を表示する保護ユーティリティ。
//      - 削除確認ログを ConsentLog に記録。
//      - 誤操作による記録破損を防ぎ、ユーザーに儀式的な確認を促す。
//      - ConsentStore により履歴保存。
//      - QuestMe の記憶保護と法的整合性を担保。
//
//  🔗 依存:
//      - ConsentLog.swift（記録）
//      - ConsentStore.swift（保存）
//      - UIKit（警告表示）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月3日

import Foundation
import UIKit

final class QuestMeFolderGuard {
    static let shared = QuestMeFolderGuard()

    /// 保護対象フォルダーの絶対パス（変更不可）
    private let protectedPath = "/AppData/QuestMe"

    /// アクセス試行時に呼び出す
    /// - Parameters:
    ///   - path: アクセスしようとしたパス
    ///   - viewController: 警告を表示する対象のViewController
    func attemptAccess(to path: String, from viewController: UIViewController) {
        guard path.contains(protectedPath) else { return }
        showDeletionWarning(from: viewController)
        logAccessAttempt(path: path)
    }

    /// 警告メッセージを表示する
    private func showDeletionWarning(from vc: UIViewController) {
        let alert = UIAlertController(
            title: "QuestMe保護領域へのアクセス",
            message: """
            この領域は保護されています。
            QuestMeを削除しますか？
            削除後、再インストールしてもデータは復旧しません。
            QuestMeが不要な場合は、通常画面でアイコンを長押しし「×」をクリックして削除してください。
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "閉じる", style: .cancel))
        vc.present(alert, animated: true)
    }

    /// アクセス試行をConsentLogに記録する
    private func logAccessAttempt(path: String) {
        let log = ConsentLog(
            timestamp: Date(),
            consentType: "QuestMeフォルダーアクセス",
            status: "拒否",
            method: "自動検知",
            notes: "ユーザーが保護領域 \(path) にアクセスしようとしました"
        )
        ConsentStore.shared.add(log)
    }
}
