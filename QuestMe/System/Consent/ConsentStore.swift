//
//  ConsentStore.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/System/Consent/ConsentStore.swift
//
//  🎯 ファイルの目的:
//      ConsentLog を保存・読み込み・一覧表示するストレージ層。
//      - QuestMe の記録保護・同意履歴・アクセス試行などを永続的に管理。
//      - JSON形式で保存し、再起動後も復元可能。
//      - QuestMeFolderGuard や AgreementView から呼び出される。
//
//  🔗 依存:
//      - ConsentLog.swift（モデル）
//      - FileManager（保存）
//      - JSONEncoder / JSONDecoder（変換）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月3日

import Foundation

final class ConsentStore {
    static let shared = ConsentStore()

    private let fileName = "consent_logs.json"
    private var logs: [ConsentLog] = []

    private init() {
        load()
    }

    /// ログを追加し、保存する
    func add(_ log: ConsentLog) {
        logs.append(log)
        save()
    }

    /// 全ログを取得
    func allLogs() -> [ConsentLog] {
        return logs.sorted(by: { $0.timestamp > $1.timestamp })
    }

    /// 保存処理（JSON形式）
    private func save() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(logs)
            let url = getFileURL()
            try data.write(to: url)
        } catch {
            print("ConsentStore保存エラー: \(error)")
        }
    }

    /// 読み込み処理
    private func load() {
        let url = getFileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([ConsentLog].self, from: data)
            logs = decoded
        } catch {
            print("ConsentStore読み込みエラー: \(error)")
        }
    }

    /// 保存先URLを取得
    private func getFileURL() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent(fileName)
    }
}
