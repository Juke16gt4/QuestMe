//
//  ConversationCalendarView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Logs/ConversationCalendarView.swift
//
//  🎯 ファイルの目的:
//      保存された会話ログ（ConversationSession）を日付ごとに振り返る。
//      - カレンダーで日付を選択
//      - 該当日の会話セッションを一覧表示
//      - 各セッションの発話内容・感情・翻訳を確認
//      - CompanionEmotionManager の成長レベル・トーンを表示
//      - EmotionLogRepository の感情ログと並列表示（CoreDataEmotionLogDTO を利用）
//
//  🔗 依存:
//      - ConversationSession.swift（会話セッション定義）
//      - CompanionEmotionManager.swift（成長状態表示）
//      - Core/Repository/EmotionLogRepository.swift（感情ログ取得）
//      - CoreData/EmotionLog.swift（CoreDataEmotionLogDTO 定義）
//
//  👤 作成者: 津村 淳一
//  📅 修正版: 2025年10月24日
//

import SwiftUI
import Foundation
import QuestMe   // プロジェクトのモジュール名
import CoreData   // CoreDataEmotionLogDTO を参照するため

// MARK: - モデル拡張（Identifiable対応）
extension ConversationEntry: Identifiable {
    public var id: Date { timestamp }
}

extension CoreDataEmotionLogDTO: Identifiable {
    public var id: Date { timestamp }
}

struct ConversationCalendarView: View {
    @State private var selectedDate: Date = Date()
    @State private var allSessions: [ConversationSession] = []
    @State private var emotionLogs: [CoreDataEmotionLogDTO] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                DatePicker("📅 日付を選択", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(sessionsForSelectedDate) { session in
                            SessionCardView(session: session)
                        }

                        if !emotionLogsForSelectedDate.isEmpty {
                            EmotionLogSection(logs: emotionLogsForSelectedDate)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("🗂 会話履歴カレンダー")
            .onAppear {
                allSessions = ConversationLogManager.shared.allSessions()
                emotionLogs = EmotionLogRepository.shared.allLogs()
            }
        }
    }

    // 該当日のセッション抽出
    var sessionsForSelectedDate: [ConversationSession] {
        let key = Self.dateKey(from: selectedDate)
        return allSessions.filter { $0.sessionId.hasPrefix(key) }
    }

    // 該当日の感情ログ抽出
    var emotionLogsForSelectedDate: [CoreDataEmotionLogDTO] {
        emotionLogs.filter {
            Self.dateKey(from: $0.timestamp) == Self.dateKey(from: selectedDate)
        }
    }

    static func dateKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
}

// MARK: - サブビュー：セッションカード
struct SessionCardView: View {
    let session: ConversationSession

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🗂 セッション: \(session.sessionId)").font(.headline)
            Text("モード: \(session.mode)")
            Text("成長レベル: \(CompanionEmotionManager.shared.state.growthLevel)")
            Text("トーン: \(CompanionEmotionManager.shared.currentToneHint)")

            ForEach(session.entries) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text("👤 \(entry.speaker)")
                    Text("🗣 \(entry.text)")
                    Text("💬 感情: \(entry.emotion)")
                }
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - サブビュー：感情ログセクション
struct EmotionLogSection: View {
    let logs: [CoreDataEmotionLogDTO]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🧠 感情ログ").font(.headline)
            ForEach(logs) { log in
                VStack(alignment: .leading) {
                    Text("🕒 \(log.timestamp.formatted())")
                    Text("💬 \(log.emotion): \(log.text)")
                }
                .padding(.vertical, 4)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding(.top, 12)
    }
}
