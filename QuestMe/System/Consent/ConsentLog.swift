//
//  ConsentLog.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/System/Consent/ConsentLog.swift
//
//  🎯 ファイルの目的:
//      ユーザーの同意・拒否・アクセス試行などを記録する構造体。
//      - 法的整合性と記録保護を担保。
//      - QuestMeフォルダーへのアクセス試行や削除確認など、重要な操作に対する記録を残す。
//      - ConsentStore により保存・一覧表示可能。
//
//  🔗 依存:
//      - Codable（保存）
//      - ConsentStore.swift（保存先）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月3日

import Foundation

/// ユーザーの同意・拒否・アクセス試行などを記録する構造体
struct ConsentLog: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let consentType: String       // 例: "QuestMeフォルダーアクセス", "音声使用同意"
    let status: String            // 例: "同意", "拒否", "保留"
    let method: String            // 例: "タップ", "音声", "自動検知"
    let notes: String             // 補足メモ（例: "ユーザーが保護領域にアクセスしようとした"）

    init(
        timestamp: Date,
        consentType: String,
        status: String,
        method: String,
        notes: String
    ) {
        self.id = UUID()
        self.timestamp = timestamp
        self.consentType = consentType
        self.status = status
        self.method = method
        self.notes = notes
    }
}
