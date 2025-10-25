//
//  CertificationReminderService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/CertificationReminderService.swift
//
//  🎯 ファイルの目的:
//      進捗と残日数から簡易リマインダー文言を生成。
//      - 未達の項目に注意喚起。
//      - 期日が近いものを強調。
//
//  🔗 連動ファイル:
//      - CertificationView.swift
//      - CertificationProgressTracker.swift
//
//  👤 作成者: 津村 淳一 (Junichi Tsumura)
//  📅 作成日: 2025年10月16日
//

import Foundation

final class CertificationReminderService {
    func checkReminders(for items: [ProgressItem]) -> [String] {
        var reminders: [String] = []
        let now = Date()
        for item in items {
            let daysLeft = Calendar.current.dateComponents([.day], from: now, to: item.goalDate).day ?? 0
            if item.completedPercent < 50.0 {
                reminders.append("「\(item.name)」は達成率が\(Int(item.completedPercent))%。早めに進めましょう。")
            }
            if daysLeft <= 14 {
                reminders.append("「\(item.name)」の期日まで残り\(daysLeft)日です。計画を再確認しましょう。")
            }
        }
        return reminders
    }
}
