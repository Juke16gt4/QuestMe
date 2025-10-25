//
//  UserEventHistory.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/Memory/UserEventHistory.swift
//
//  🎯 ファイルの目的:
//      ユーザーが訪れた場所（飲食店・レジャー・病院・イベントなど）の履歴を保存・取得する。
//      - Companion が「最近のお出かけは…」と語りかけるための記憶基盤。
//      - 好み学習・思い出語り・提案強化に活用可能。
//      - JSON に append-only で保存（削除不可）。
//
//  🔗 依存:
//      - Foundation
//      - CompanionOverlay.swift（語りかけ）
//      - FileManager（保存先）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月8日
//

import Foundation

struct UserEvent: Codable, Identifiable {
    let id: UUID
    let category: String       // 例: "gourmet", "leisure", "medical", "event"
    let title: String          // 例: "ケンボロー", "美又温泉まつり"
    let location: String       // 例: "浜田市三隅町"
    let date: Date             // 訪問日時
    let impression: String?    // 感想（任意）

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

final class UserEventHistory {
    static let shared = UserEventHistory()

    private let fileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("user_event_history.json")
    }()

    private var events: [UserEvent] = []

    private init() {
        load()
    }

    // MARK: - 保存
    func addEvent(category: String, title: String, location: String, impression: String? = nil) {
        let newEvent = UserEvent(
            id: UUID(),
            category: category,
            title: title,
            location: location,
            date: Date(),
            impression: impression
        )
        events.append(newEvent)
        save()
    }

    // MARK: - 取得
    func recentEvents(limit: Int = 5) -> [UserEvent] {
        return Array(events.sorted(by: { $0.date > $1.date }).prefix(limit))
    }

    func events(for category: String) -> [UserEvent] {
        return events.filter { $0.category == category }
    }

    // MARK: - 読み込み
    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([UserEvent].self, from: data)
            events = decoded
        } catch {
            print("履歴読み込み失敗: \(error.localizedDescription)")
        }
    }

    // MARK: - 保存
    private func save() {
        do {
            let data = try JSONEncoder().encode(events)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("履歴保存失敗: \(error.localizedDescription)")
        }
    }

    // MARK: - Companion に語らせる
    func narrateRecentEvents() {
        let recent = recentEvents()
        guard !recent.isEmpty else {
            CompanionOverlay.shared.speak("最近のお出かけ履歴はまだありません。", emotion: .neutral)
            return
        }

        let lines = recent.map {
            "・\($0.title)（\($0.formattedDate)）"
        }.joined(separator: "\n")

        let message = "最近のお出かけはこちらです：\n\(lines)"
        CompanionOverlay.shared.showBubble(message)
        CompanionOverlay.shared.speak(message, emotion: .happy)
    }
}
