//
//  LogEntry.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Managers/LogEntry.swift
//
//  🎯 ファイルの目的:
//      会話ログを「会話」フォルダに JSON 形式で保存・取得する管理器。
//      - insert(entry:) でログを追加
//      - saveSession(mode:) でセッション単位の JSON 保存
//      - allSessions() で全履歴を取得可能
//      - EmotionLogRepository / CompanionEmotionManager と連動
//
//  🔗 依存:
//      - Core/Model/ConversationEntry.swift（唯一の会話ログ定義）
//      - EmotionLogRepository.swift
//      - CompanionEmotionManager.swift
//      - FloatingCompanionOverlayView.swift
//      - InterpreterModeSelector.swift
//
//  👤 作成者: 津村 淳一
//  📅 修正日: 2025年10月23日
//

import Foundation

// MARK: - セッション構造体（ConversationEntry は Core/Model を参照）
public struct ConversationSession: Codable {
    public let sessionId: String
    public let mode: String
    public let participants: [Participant]
    public let entries: [ConversationEntry]
    public let summary: Summary
}

public struct Participant: Codable {
    public let role: String
    public let language: String
}

public struct Summary: Codable {
    public let totalTurns: Int
    public let languagesDetected: [String]
    public let emotions: [String]
}

// MARK: - ログ管理クラス
public final class ConversationLogManager {
    public static let shared = ConversationLogManager()
    private init() {}

    private var currentEntries: [ConversationEntry] = []

    /// 1件追加
    public func insert(entry: ConversationEntry) {
        currentEntries.append(entry)
        print("💬 [\(entry.speaker)] \(entry.text)")
    }

    /// セッション保存（JSON形式）
    public func saveSession(mode: String = "general") {
        guard !currentEntries.isEmpty else { return }

        let sessionId = Self.timestampString()
        let participants = detectParticipants(from: currentEntries)
        let summary = Summary(
            totalTurns: currentEntries.count,
            languagesDetected: Array(Set(currentEntries.map { $0.language })),
            emotions: currentEntries.map { $0.emotion }
        )

        let session = ConversationSession(
            sessionId: sessionId,
            mode: mode,
            participants: participants,
            entries: currentEntries,
            summary: summary
        )

        do {
            let data = try JSONEncoder().encode(session)
            let folderURL = Self.folderURL(named: "会話")
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            let fileURL = folderURL.appendingPathComponent("\(sessionId).json")
            try data.write(to: fileURL, options: .atomic)
            print("✅ 会話ログ保存完了: \(fileURL.lastPathComponent)")
        } catch {
            print("❌ ConversationLogManager save failed: \(error)")
        }

        currentEntries.removeAll()
    }

    /// 全セッション読み込み
    public func allSessions() -> [ConversationSession] {
        let folderURL = Self.folderURL(named: "会話")
        guard let files = try? FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil) else {
            return []
        }
        var sessions: [ConversationSession] = []
        for file in files where file.pathExtension == "json" {
            if let data = try? Data(contentsOf: file),
               let session = try? JSONDecoder().decode(ConversationSession.self, from: data) {
                sessions.append(session)
            }
        }
        return sessions.sorted { $0.sessionId < $1.sessionId }
    }

    // MARK: - 補助関数
    private func detectParticipants(from entries: [ConversationEntry]) -> [Participant] {
        var roles: [String: String] = [:]
        for e in entries {
            roles[e.speaker] = e.language
        }
        return roles.map { Participant(role: $0.key, language: $0.value) }
    }

    private static func timestampString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: Date())
    }

    private static func folderURL(named: String) -> URL {
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return doc.appendingPathComponent(named, isDirectory: true)
    }
}
