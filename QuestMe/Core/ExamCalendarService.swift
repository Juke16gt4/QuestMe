//
//  ExamCalendarService.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Core/ExamCalendarService.swift
//
//  🎯 ファイルの目的:
//      試験予定の提供。
//      - ObservableObject として UI と同期。
//      - 試験名／日付／場所を持つ予定を公開。
//
//  🔗 連動ファイル:
//      - CertificationView.swift
//
//  👤 作成者: 津村 淳一 (Junichi Tsumura)
//  📅 作成日: 2025年10月16日
//

import Foundation
import Combine

struct ExamEvent: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let date: Date
    let location: String
}

@MainActor
final class ExamCalendarService: ObservableObject {
    @Published var upcomingExams: [ExamEvent] = [
        ExamEvent(name: "薬剤師国家試験", date: Calendar.current.date(byAdding: .day, value: 60, to: Date())!, location: "東京"),
        ExamEvent(name: "基本情報技術者", date: Calendar.current.date(byAdding: .day, value: 40, to: Date())!, location: "大阪"),
        ExamEvent(name: "TOEIC", date: Calendar.current.date(byAdding: .day, value: 21, to: Date())!, location: "広島")
    ]

    func fetchUpcomingExams() -> [ExamEvent] {
        upcomingExams
    }
}
